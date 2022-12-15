# !/bin/bash
set -e

usage() {
cat  <<EOL
bazel run vmd cmd [-e,-n,-u,-p] -- echo "hello vm"

This program runs a command in a VM with tart for iOS testing

-n|--name - The name of the VM it will run

-p|--port - [Optional] - a port to forward

-d|--disk - [Optional] - attach a disk to tart ( passthrough )

-e|--entrypoint - [Optional] The entrypoint to run.
This entrypoint supplements the arvg invocation if provided, you need to do all the work handled here ( like running from .runfiles, untarring --upload, etc

-u|--upload - [Optional] Upload data to the runner
Examples of this are a .xctest bundle and xctestrunner python code

-z|--no-ephemeral [Optional] By default the VMs are thrown away, turn that off

Consider this an implementation of rules_ios for now. A segment of this program
can be added to tart directly
e.g https://github.com/cirruslabs/tart/issues/150
EOL
}

# Push a few known paths on here ( it shouldn't rely on external software but
# for now socat is loaded externally )
PATH=$PWD/tools/vmd/bin:/opt/bazel-rbe-worker/bin:/opt/homebrew/bin:$PATH

run_vm() {
    # Run the entrypoint
    CMD_EXIT_STATUS=1

    if test $EPHEMERAL -eq 1; then
        # By default we make these ephemeral

        # Assign the VM name to the work_dir
        TMP_VM="${VM_NAME}-$(basename $VM_TMPDIR)"

        # This VM is required to be already pulled locally. The VMs are massive:
        # 40gb or so. For now, they will likely need to externally pulled
        # https://github.com/cirruslabs/tart/issues/150
        # Use `tart pull` as a dep to this rule if you'd like to do it with
        # Bazel or add an optional CLI argument
        tart clone $VM_NAME $TMP_VM
        local run_vm_name=$TMP_VM
    else
        local run_vm_name=$VM_NAME
    fi

    # Spinup tart in the background
    tart run ${TART_RUN_ARGS[@]} \
        $run_vm_name --no-graphics &2>> $VM_TMPDIR/tart.log  &
    # Save the PID of tart
    echo $(expr $! - 1) > $VM_TMPDIR/tart.pid

    # We need to ensure that tart has ran before calling tart ip. We need to
    # wait for the VM to boot so waiting 2 seconds here isn't a huge problem
    sleep 2

    # Note: If the concurrency is too much we'll get:
    # Error Domain=VZErrorDomain Code=6 "The maximum supported number of active virtual machines has been reached.
    # Possibly manage this better and adding a flag for no-graphics. We don't want this with Bazel
    ps -p $PID  $(cat $VM_TMPDIR/tart.pid) > /dev/null || exit 1

    # Consider adding a timeout here
    IP=$(tart ip $run_vm_name --wait 30)
    if [[ -z "${IP}" ]]; then
        echo "Missing IP" && exit 1
    fi

    # Get a PID to port forward: This is useful for longer lived VMs
    # We may consider configuring pf instead of this
    if [[ ! -z ${PORT_FORWARD} ]]; then
        socat -d -d  TCP-LISTEN:${PORT_FORWARD},fork,reuseaddr TCP:$IP:${PORT_FORWARD} &
        # Save the PID of socat
        echo $! > $VM_TMPDIR/socat.pid
    fi

    ## After this it's going to connect
    echo "connected $IP" >>  $VM_TMPDIR/vm.log

    ## First we want to upload the entrypoint
    # This is the path on the VM ( not the host )
    local VM_CMD=/tmp/cmd.sh

    sshpass -p admin scp -o StrictHostKeyChecking=no -o ConnectTimeout=30 $VM_TMPDIR/cmd.sh admin@${IP}:$VM_CMD

    ## Upload test inputs if they provide it
    if [[ ! -z "$RUNNER_UPLOAD" ]]; then
        sshpass -p admin scp -o StrictHostKeyChecking=no -o ConnectTimeout=30 $RUNNER_UPLOAD admin@${IP}:RUNNER_UPLOAD.tar
    fi

    sshpass -p admin ssh -o StrictHostKeyChecking=no -o ConnectTimeout=30 admin@${IP} "chmod +x $VM_CMD && $VM_CMD"
    CMD_EXIT_STATUS=$?
}

exit_handler() {
    # Remove the VMs and tmp dirs. Consider an opt to keep for debug
    if test $EPHEMERAL -eq 1; then
        tart delete $TMP_VM || true
    fi

    # Terminate the pids
    find $VM_TMPDIR -name \*.pid \
        -exec /bin/bash -c "kill -9 \$(cat {}) 2> /dev/null || true" 2> /dev/null \;
    rm -rf $VM_TMPDIR

    # We want to dump out the log if it fails
    test $CMD_EXIT_STATUS -eq 0 || cat $VM_TMPDIR/tart.log 2> /dev/null
}

main() {
    VM_TMPDIR=$(mktemp -d)
    trap "exit_handler 2> /dev/null" EXIT

    ## Program defaults ( see arguments for details )
    ENTRYPOINT=""
    VM_NAME=""
    PORT_FORWARD=""
    EPHEMERAL=1

    # Note: we want to break-up the parsing to validate arguments and
    # distingush from the users CLI arguments
    BREAK_PARSE=0
    POSITIONAL_ARGS=()
    TART_RUN_ARGS=()
    while [[ $# -gt 0 ]]; do
      case $1 in
        -e|--entrypoint)
          ENTRYPOINT="$2"
          shift
          shift
          ;;
        -u|--upload)
          RUNNER_UPLOAD="$2"
          shift
          shift
          ;;
        -p|--port)
          PORT_FORWARD="$2"
          shift
          shift
          ;;
        -n|--name)
          VM_NAME="$2"
          shift
          shift
          ;;
        -z|--no-ephemeral)
          EPHEMERAL=0
          shift
          ;;
        -d|--disk)
          TART_RUN_ARGS+=("--disk=$2")
          shift
          shift
          ;;
        --)
          if test $BREAK_PARSE -eq 1; then
              POSITIONAL_ARGS+=("$1")
          else
              BREAK_PARSE=1
          fi
          shift
          ;;
        *)
          POSITIONAL_ARGS+=("$1") # save positional arg
          shift # past argument
          ;;
      esac
    done

    if [[ -z "$VM_NAME" ]]; then
        echo "Missing --name" && usage && exit 1;
    fi

    # Initialize the entrypoint to a defualt. The default is opinionated for
    # "Bazel run"
    if [[ -z "$ENTRYPOINT" ]]; then
        ENTRYPOINT=$VM_TMPDIR/cmd.sh
        cat > $VM_TMPDIR/cmd.sh <<EOL
#!/bin/bash
# By default in Bazel land unpack to the runfiles
mkdir runner.runfiles && mkdir /tmp/TEST_OUTPUTS_DIR
cd runner.runfiles

# Determine to setup DNS within a VPC at "common" cloud providers
# For now, it kind of looks like the host
# sudo echo -e "\$(cat /etc/resolv.conf)" > /tmp/resolv.conf
# sudo mv /tmp/resolv.conf  /etc/resolv.conf
# sudo scutil --set HostName $(hostname)
# sudo killall -QUIT -u _mdnsresponder

# If they give it a runner upload - then we untar it for them on laucnh
if [[ ! -z "$RUNNER_UPLOAD" ]]; then
   tar -xvf ~/RUNNER_UPLOAD.tar
fi
${POSITIONAL_ARGS[@]}
EOL
    else
        cp $ENTRYPOINT $VM_TMPDIR/cmd.sh
    fi

    # tart is not hermetic ATM - we'll need to make chages for this
    touch $HOME/.tart/vms || (echo "Run with standalone - not hermetic ATM" || exit 1)
    run_vm
}

main "$@"
