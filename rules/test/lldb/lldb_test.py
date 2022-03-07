# This program is a library for constructing iOS LLDB command line automation,
# oriented around testing. It orchestrates a simulator thread, LLDB thread, to
# run simulators and debuggers concurrently. It transmits information between
# Bazel, the test, and the LLDB process with JSON files
import rules.test.lldb.sim_template as sim_template
import subprocess
import os
import logging
import time
import threading
import traceback
import tempfile
import shutil
import json

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


def run_app_in_simulator(ctx, simulator_udid, developer_path, simctl_path,
                         ios_application_output_path, app_name):
    """Installs and runs an app in the specified simulator.
    """
    logger.info("Booting simulator App with path %s", developer_path)
    try:
        sim_template.boot_simulator(
            developer_path, simctl_path, simulator_udid)
    except:
        logger.info(
            "Second attempt to boot simulator App with path %s", developer_path)
        # This is a hack - when rapidly iterating locally it can fail with:
        # Simulator.app cannot be opened for an unexpected reason,
        # error=Error Domain=NSOSStatusErrorDomain Code=-600 "procNotFound: no
        # eligible process with specified descriptor" UserInfo={_LSLine=379,
        # _LSFunction=_LSAnnotateAndSendAppleEventWithOptions}
        sim_template.boot_simulator(
            developer_path, simctl_path, simulator_udid)

    with sim_template.extracted_app(ios_application_output_path, app_name) as app_path:
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
        process = subprocess.Popen(args, env=sim_template.simctl_launch_environ(
        ),  stdout=subprocess.PIPE, stderr=subprocess.PIPE)
        sim_pid = process.pid

        # Stream the simctl output to stdout, consider moving to a file
        reader_t = threading.Thread(
            target=monitor_output, args=(process.stdout, "simctl"))
        reader_t.daemon = True
        reader_t.start()

        logger.info("Find simctl PID %s", sim_pid)

        # After it boots, notify the `ctx` by calling SetStartedAppPid
        app_started_pid = None
        while not process.returncode and ctx.GetCompletionStatus() == None:
            if not app_started_pid:
                app_started_pid = find_pid(ctx.app_name, simulator_udid)
                if app_started_pid:
                    logger.info("Got PID %s", app_started_pid)
                    ctx.SetStartedAppPid(app_started_pid)

            logger.info("Poll simulator %s", process.poll())
            time.sleep(1)

        logger.info("Sim exited return code %d", process.returncode)


def sim_thread_main(ctx, sim_device, sim_os_version, ios_application_output_path, app_name,
                    minimum_os):
    xcode_select_result = subprocess.run(["xcode-select", "-p"],
                                         encoding="utf-8",
                                         check=True,
                                         stdout=subprocess.PIPE)
    developer_path = xcode_select_result.stdout.rstrip()
    simctl_path = os.path.join(developer_path, "usr", "bin", "simctl")
    with sim_template.ios_simulator(simctl_path, minimum_os, sim_device,
                                    sim_os_version) as simulator_udid:
        run_app_in_simulator(ctx, simulator_udid, developer_path, simctl_path,
                             ios_application_output_path, app_name)


def sim_thread_entry(ctx, device, sdk, ipa_path):
    try:
        sim_thread_main(ctx, device, sdk, ipa_path, ctx.app_name, sdk)
    except Exception:
        traceback.print_exc()
        ctx.Fail()


ctxlock = threading.RLock()


class TestContext():
    def __init__(self, pid, app_name, test_root):
        self.app_name = app_name
        self.test_root = test_root

        # Not thread safe
        self.status = None
        self.pid = None

    def SetStartedAppPid(self, app_pid):
        with ctxlock:
            self.pid = app_pid

    def GetStartedAppPid(self):
        with ctxlock:
            return self.pid

    def Fail(self):
        traceback.print_exc()
        logger.error("FAIL")
        with ctxlock:
            self.status = -1

    # Returns None for in progress, -1 fail, 1 pass
    def GetCompletionStatus(self):
        with ctxlock:
            if self.status == -1:
                return -1

        test_result = get_test_result(self.test_root)
        if test_result != None:
            return 1
        return None

    def GetTestResult(self):
        return get_test_result(self.test_root)

    def GetTestRoot(self):
        return self.test_root


def get_test_result(test_root):
    lpath = test_root + "/test_result.json"
    if not os.path.exists(lpath):
        return None

    with open(lpath, 'r') as test_result:
        return json.load(test_result)


def setup_test_root(test_spec):
    test_root = tempfile.mkdtemp()
    logger.info("Setup test root: " + test_root)

    # Write an LLDB init in the temp dir
    write_lldbinit(test_spec, test_root)
    write_lldb_helpers(test_root)

    # LLDB needs to read this file later
    os.symlink(test_spec, os.path.join(test_root, "test_spec.json"))
    return test_root


def lldb_thread_entry(ctx, x):
    while not ctx.GetStartedAppPid() and ctx.GetCompletionStatus() == None:
        logger.info(
            "Waiting for %s.app to post to start debugger", ctx.app_name)
        time.sleep(1)
    try:
        attach_debugger(ctx, ctx.GetTestRoot(), ctx.GetStartedAppPid())
    except Exception:
        traceback.print_exc()
        ctx.Fail()


def monitor_output(out, prefix):
    for line in iter(out.readline, b''):
        logger.info(prefix + " " + line.decode("utf8").rstrip("\n"))
    out.close()


def attach_debugger(ctx, test_root, pid):
    # TODO: ideally use Bazel's configured Xcode's LLDB if it exists
    args = ["xcrun", "lldb", "-p", str(pid), "--local-lldbinit"]

    logger.info("spawning LLDB with args %s", str(args))
    lldb_process = subprocess.Popen(
        args, cwd=test_root, stdin=subprocess.PIPE, stdout=subprocess.PIPE, stderr=subprocess.PIPE)

    # Stream the LLDB output to stdout, consider moving to a file
    reader_t = threading.Thread(
        target=monitor_output, args=(lldb_process.stdout, "LLDB"))
    reader_t.daemon = True
    reader_t.start()

    # Source the test_setup script
    lldb_process.stdin.write(
        "command source test_setup.lldbinit\n".encode('utf-8'))
    lldb_process.stdin.flush()

    # Consider validating this here
    logger.info("LLDB Completed return code %s", str(lldb_process.poll()))


def write_lldb_helpers(test_root):
    # Copy in the breakpoint JSON extractor
    source_file = os.path.realpath(__file__)
    breakpoint_file = os.path.join(
        os.path.dirname(source_file), "breakpoint.py")
    os.symlink(breakpoint_file, os.path.join(test_root, "breakpoint.py"))


def write_lldbinit(test_spec, test_root):
    """"
    This LLDB init sets the breakpoint_cmd and LLDB detaches after it runs dumping output into the `test_result.json` as a `TestResult`.

    See breakpoint.py for how that file is used.
    """
    lpath = test_root + "/test_setup.lldbinit"
    test_spec_dict = None
    with open(test_spec, 'r') as test_spec:
        test_spec_dict = json.load(test_spec)

    cmd = test_spec_dict["breakpoint_cmd"]

    logger.info("Write inting lldbinit to %s ", lpath)
    with open(lpath, 'w') as initfile:
        initfile.write("""
command script import --allow-reload ./breakpoint.py
""" + cmd + """
breakpoint command add --python-function breakpoint.breakpoint_info_fn  1
continue
""")


def emit_test_result(ctx, spec_path):
    status = ctx.GetCompletionStatus()
    if status == -1:
        return 1

    # This should check the exit code here?
    test_result = ctx.GetTestResult()
    logger.info("Got result" + str(test_result))

    test_spec_dict = None
    with open(spec_path, 'r') as test_spec:
        test_spec_dict = json.load(test_spec)

    expected_value = test_spec_dict["expected_value"]
    # Possibly use a python testing library or matcher here, but keep it simple
    # for now
    if test_result["expression_result"] != expected_value:
        logger.error("Failed Expected", expected_value, "Got",
                     test_result["expression_result"])
        return 1

    logger.debug("SUCCESS")
    return 0


def cleanup(ctx):
    shutil.rmtree(ctx.test_root)


def run_lldb_test(ipa_path, sdk, device, spec_path):
    if not os.path.exists(ipa_path) or not ipa_path.endswith(".ipa"):
        logger.error("Missing IPA / [ --app ] %s", ipa_path)
        exit(1)

    # Consider handling other IPAs here or types
    ipa_name = os.path.basename(ipa_path)
    app_name = ipa_name.replace(".ipa", "")

    if not sdk:
        logger.error("Missing SDK / [ --sdk ]")
        exit(1)

    if not device:
        logger.error("Missing device / [ --device ] ")
        exit(1)

    if not os.path.exists(spec_path):
        logger.error("Missing spec / [ --spec]", spec_path)
        exit(1)

    with open(spec_path, 'r') as test_spec:
        test_spec_dict = json.load(test_spec)
        cmd = test_spec_dict["breakpoint_cmd"]

        # Do some level of validation here - mainly to help the users figure out to
        # use this. Warning: for now there is no timeout if the breakpoint
        # doesn't resolve - consider failing fast here with a better message.
        # Regardless, it's a broken state. The failure mode is the users
        # timeout..
        if (cmd.startswith("br ") or cmd.startswith("breakpoint ")) == False:
            logger.error(
                "breakpoint_cmd needs some breakpoint set to run to %s ", spec_path)
            exit(1)

    exit_code = None
    ctx = None
    logger.info("Got app name %s", app_name)
    try:
        test_root = setup_test_root(spec_path)
        ctx = TestContext(None, app_name, str(test_root))

        # Main runloop - polls completion status
        sim_thread = threading.Thread(
            target=sim_thread_entry, args=(ctx, device, sdk, ipa_path))
        debugger_thread = threading.Thread(
            target=lldb_thread_entry, args=(ctx, 1))
        sim_thread.start()
        debugger_thread.start()
        while ctx.GetCompletionStatus() == None:
            logger.debug('Main thread...')
            time.sleep(1)
        sim_thread.join()
        debugger_thread.join()
        exit_code = emit_test_result(ctx, spec_path)
    except Exception:
        traceback.print_exc()
    finally:
        cleanup(ctx)

    exit(exit_code if exit_code == 0 else 1)
