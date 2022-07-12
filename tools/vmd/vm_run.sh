# !/bin/bash
# vm_runner.sh - This program runs a command in VM_IMG:
#
# vm_runner "echo \$(whoami)"
#
# A segment of this program can be fundamentally simplified into a higher level
# swift CLI or upstreamed into tart dirctly.
set -e

# This VM is required to be already pulled locally. The VMs are massive: 40gb or
# so. For now, they will likely need to externally pulled
VM_IMG=macos-monterey-xcode:13.3.1

# Push a few known paths on here
PATH=$PWD/tools/vmd/bin:/opt/bazel-rbe-worker/bin:$PATH

run_vm() {
    tart clone $VM_IMG latest

    # Shut down tart - this assumes concurrency is 1. There should be a better
    # way to verify this when running locally
    killall SIGTERM tart 2> /dev/null || true

    # Spinup tart in the background
    $(tart run --no-graphics latest 2>&1 | cat > /tmp/tart.log)&

    # We need to ensure that tart has ran before calling tart ip. We need to
    # wait for the VM to boot so waiting 7 seconds here isn't a huge problem
    sleep 7
    IP=$(tart ip latest --wait 30)

    ## After this it's going to connect
    echo "connected $IP"

    ## Upload test inputs - note - we rely on SSH pass here
    local VM_CMD=/tmp/cmd.sh
    sshpass -p admin scp -o StrictHostKeyChecking=no -o ConnectTimeout=30 cmd.sh admin@${IP}:$VM_CMD
    sshpass -p admin scp -o StrictHostKeyChecking=no -o ConnectTimeout=30 RUNNER_UPLOAD.tar admin@${IP}:RUNNER_UPLOAD.tar

    # Run the entrypoint
    CMD_EXIT_STATUS=1
    sshpass -p admin ssh -o StrictHostKeyChecking=no -o ConnectTimeout=30 admin@${IP} "chmod +x $VM_CMD && $VM_CMD"
    CMD_EXIT_STATUS=$?
}

exit_handler() {
    killall SIGTERM tart 2> /dev/null
    # We want to dump out the log if it fails
    test $CMD_EXIT_STATUS -eq 0 || cat /tmp/tart.log
}

main() {
    # FIXME: this should be refactored into the runner script
    # most of this program will be re-written overall
    echo -e "mkdir runner.runfiles && mkdir /tmp/TEST_OUTPUTS_DIR" > cmd.sh
    echo -e "pushd runner.runfiles" >> cmd.sh
    echo -e "tar -xvf ~/RUNNER_UPLOAD.tar" >> cmd.sh
    echo -e "$@" >> cmd.sh
    echo -e "running vm $VM_IMG"

    ## Smoke the VM after it's done running
    trap exit_handler EXIT
    run_vm
}

main "$@"