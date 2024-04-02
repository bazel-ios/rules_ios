# This program is a library for constructing iOS LLDB command line automation,
# oriented around testing. It orchestrates a simulator thread, LLDB thread, to
# run simulators and debuggers concurrently. see run_lldb_test
import rules.test.lldb.sim_template as sim_template
import subprocess
import os
import logging
import time
import threading
import traceback
import contextlib

logging.basicConfig(
    format="%(asctime)s.%(msecs)03d %(levelname)s %(message)s",
    datefmt="%Y-%m-%d %H:%M:%S",
    level=logging.INFO)
logger = logging.getLogger(__name__)


def find_pid(app_name, udid):
    """ Find the PID for the app and the udid of the simulator"""
    system_processes = subprocess.Popen(
        ['ps', '-aU', '0'], stdout=subprocess.PIPE).communicate()[0]
    out_pid = None
    needle = app_name + ".app"
    for misc_p in system_processes.decode("utf8").split("\n"):
        if needle in misc_p and udid in misc_p:
            pid_line = misc_p.strip()
            accum = ""
            for c in pid_line:
                if c == " ":
                    break
                else:
                    accum += c
            return int(accum)
    return None


def boot_simulator(simctl_path, udid):
    """Launches the iOS simulator for the given identifier.

    Unlike the rules_apple runner we don't foreground it because of concurrency
    problems
    """
    logger.info("Launching simulator with udid: %s", udid)
    subprocess.run(
        ["xcrun", "simctl", "boot",  udid],
        check=True)
    logger.debug("Simulator launched.")
    if not sim_template.wait_for_sim_to_boot(simctl_path, udid):
        raise Exception("Failed to launch simulator with UDID: " + udid)


@contextlib.contextmanager
def temporary_ios_simulator(ctx, simctl_path, device, version):
    """Creates a temporary iOS simulator, cleaned up automatically upon close.

    Args:
      simctl_path: The path to the `simctl` binary.
      device: The name of the device (e.g. "iPhone 8 Plus").
      version: The version of the iOS runtime (e.g. "13.2").

    Yields:
      The UDID of the newly-created iOS simulator.
    """
    runtime_version_name = version.replace(".", "-")
    logger.info("Creating simulator, device=%s, version=%s", device, version)
    simctl_create_result = subprocess.run([
        simctl_path, "create", "TestDevice", device,
        "com.apple.CoreSimulator.SimRuntime.iOS-" + runtime_version_name
    ],
        encoding="utf-8",
        check=True,
        stdout=subprocess.PIPE)
    udid = simctl_create_result.stdout.rstrip()
    ctx.SetStartedSimUDID(udid)
    yield udid


def pack_tree_artifact(ios_application_output_path, app_name):
    """This slows it down a bit to copy and zip up the app, make it handle a .app
    in another way
    """
    archive_root = os.environ.get("TEST_UNDECLARED_OUTPUTS_DIR", os.path.join(os.path.dirname(
        ios_application_output_path), "lldb-test-intermediate"))
    archive_app_path = os.path.join(archive_root, "Payload")
    ipa_path = os.path.join(archive_root, app_name + ".ipa")
    subprocess.run(["mkdir", "-p", archive_app_path], check=True)
    subprocess.run(["/usr/bin/rsync",
                    "--archive",
                    "--delete",
                    "--checksum",
                    "--chmod=u+w",
                    os.path.realpath(ios_application_output_path),
                    archive_app_path
                    ], check=True)
    subprocess.run(["zip", "-rq", ipa_path, "Payload", ],
                   check=True, cwd=archive_root)

    return ipa_path


def run_app_in_simulator(ctx, simctl_path, simulator_udid,
                         ios_application_output_path, app_name):
    """Installs and runs an app in the specified simulator.
    """
    logger.info("Booting simulator")
    try:
        boot_simulator(simctl_path, simulator_udid)
    except:
        logger.info("Second attempt to boot simulator")
        boot_simulator(simctl_path, simulator_udid)

    with sim_template.extracted_app(pack_tree_artifact(ios_application_output_path, app_name), app_name) as app_path:
        logger.debug("Installing app %s to simulator %s",
                     app_path, simulator_udid)
        subprocess.run([simctl_path, "install", simulator_udid, app_path],
                       check=True)
        app_bundle_id = sim_template.bundle_id(app_path)
        logger.info("Launching app %s in simulator %s", app_bundle_id,
                    simulator_udid)
        args = [
            simctl_path, "launch", "--wait-for-debugger", simulator_udid, app_bundle_id
        ]

        # This returns the pid of the process
        simctl_process = subprocess.Popen(args, env=sim_template.simctl_launch_environ(
        ),  stdout=subprocess.PIPE, stderr=subprocess.PIPE)
        sim_pid = simctl_process.pid

        # Stream the simctl output to stdout, consider moving to a file
        reader_tstdout = threading.Thread(
            target=monitor_output, args=(simctl_process.stdout, "simctl"))
        reader_tstdout.daemon = True
        reader_tstdout.start()

        reader_tstderr = threading.Thread(
            target=monitor_output, args=(simctl_process.stderr, "simctl"))
        reader_tstderr.daemon = True
        reader_tstderr.start()

        logger.info("Find simctl PID %s", sim_pid)

        # After it boots, notify the `ctx` by calling SetStartedAppPid
        app_started_pid = None
        while not app_started_pid:
            logger.info("Poll simulator %s", simctl_process.poll())
            # Wait for it to post via ps because it doesn't work otherwise
            app_started_pid = find_pid(ctx.app_name, simulator_udid)
            poll_stat = simctl_process.poll()
            if app_started_pid:
                logger.info("Got PID %s", app_started_pid)
                ctx.SetStartedAppPid(app_started_pid)
            if simctl_process.returncode and simctl_process.returncode != 0:
                break
            time.sleep(1)
        logger.info("Sim exited return code %d", simctl_process.returncode)
        if simctl_process.returncode != 0:
            ctx.Fail()


def sim_thread_main(ctx, sim_device, sim_os_version, ios_application_output_path, app_name,
                    minimum_os):
    with temporary_ios_simulator(ctx, ctx.simctl_path, sim_device,
                                 sim_os_version) as simulator_udid:
        run_app_in_simulator(ctx, ctx.simctl_path, simulator_udid,
                             ios_application_output_path, app_name)


class TestContext():
    def __init__(self, pid, app_name, test_root):
        self.app_name = app_name
        self.test_root = test_root
        self.status = None
        self.pid = None
        self.udid = None
        self.simctl_path = subprocess.run(
            ["xcrun", "-f", "simctl"], encoding="utf-8", check=True, stdout=subprocess.PIPE).stdout.rstrip()
    def SetStartedAppPid(self, app_pid):
        self.pid = app_pid

    def SetStartedSimUDID(self, udid):
        self.udid = udid

    def GetStartedSimUDID(self):
        return self.udid

    def GetStartedAppPid(self):
        return self.pid

    def Fail(self):
        traceback.print_exc()
        logger.error("FAIL")
        self.status = -1

    # Returns None for in progress, -1 fail, 1 pass
    def GetCompletionStatus(self):
        return self.status

    def SetLLDBCompletionStatus(self, status):
        self.status = status
        if status != 0:
            self.Fail()

    def GetTestRoot(self):
        return self.test_root


def monitor_output(out, prefix, dupe_file_path=None):
    # Copy these lines to a file
    dupe_file = open(dupe_file_path, "w") if dupe_file_path else None
    for line in iter(out.readline, b''):
        str_line = line.decode("utf8")
        logger.info(prefix + " " + str_line.rstrip("\n"))
        if dupe_file:
            dupe_file.write(str_line)

    out.close()
    if dupe_file:
        dupe_file.close()

    logger.info(prefix + " output stream Closed")


def attach_debugger(ctx, test_root, pid, lldbinit, stdout):
    args = ["xcrun", "lldb", "-p", str(pid)]
    lldb_desc = " ".join(args)
    src_str = "command source " + str(lldbinit) + "\n"
    logger.info("spawning LLDB with args: cd %s && %s - init %s",
                test_root, lldb_desc + " - " + src_str, lldbinit)
    lldb_process = subprocess.Popen(
        args, cwd=test_root, stdin=subprocess.PIPE, stdout=subprocess.PIPE, stderr=subprocess.PIPE)

    # Stream the LLDB output to stdout, consider moving to a file
    reader_t = threading.Thread(
        target=monitor_output, args=(lldb_process.stdout, "LLDB", stdout))
    reader_t.daemon = True
    reader_t.start()

    reader_tstderr = threading.Thread(
        target=monitor_output, args=(lldb_process.stderr, "LLDB"))
    reader_tstderr.daemon = True
    reader_tstderr.start()

    if not os.path.exists(lldbinit):
        ctx.Fail()

    # Source the test lldbinit - ideally this can fail faster if it breaks
    lldb_process.stdin.write(
        ("command source " + str(lldbinit) + "\n").encode('utf-8'))
    lldb_process.stdin.flush()

    while lldb_process.poll() == None:
        logger.info("Poll LLDB %s", lldb_process.poll())
        time.sleep(1)

    logger.info("LLDB Completed return code %d", lldb_process.returncode)
    ctx.SetLLDBCompletionStatus(lldb_process.returncode)


def cleanup(ctx):
    udid = ctx.udid

    subprocess.run([ctx.simctl_path, "shutdown", udid],
                   stderr=subprocess.DEVNULL,
                   check=False)
    logger.info("Deleting simulator with udid: %s", udid)
    subprocess.run([ctx.simctl_path, "delete", udid], check=True)


def run_lldb(app_path, sdk, device, lldbinit_path, test_root, lldb_stdout):
    """ Spawns a simulator with the `app_path`, `sdk`, device wit the `.lldbinit`

        It waits for LLDB to exit and retuns the exit code

        stdout is written to lldb.stdout in the test_root
    """
    if not os.path.exists(app_path) or not app_path.endswith(".app"):
        raise Exception(f"Missing .app / [ --app ] %s", app_path)

    # Consider handling other IPAs here or types
    app_name = os.path.basename(app_path).replace(".app", "")
    if not sdk:
        raise Exception(f"Missing SDK / [ --sdk ]")

    if not device:
        raise Exception(f"Missing device / [ --device ] ")

    if not os.path.exists(lldbinit_path):
        raise Exception(f"Missing lldbinit / [ --lldbinit]", lldbinit_path)

    exit_code = None
    ctx = None
    logger.info("Got app name %s", app_name)
    try:
        ctx = TestContext(None, app_name, str(test_root))
        sim_thread_main(ctx, device, sdk, app_path, ctx.app_name, sdk)
        attach_debugger(ctx, test_root=ctx.GetTestRoot(),
                        pid=ctx.GetStartedAppPid(), lldbinit=lldbinit_path, stdout=lldb_stdout)

        exit_code = ctx.GetCompletionStatus()
    except Exception:
        traceback.print_exc()
    finally:
        cleanup(ctx)
    if exit_code != 0:
        raise Exception(f"LLDB exited with non-zero status %d", exit_code)
    return exit_code
