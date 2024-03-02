#!/usr/bin/env python3

import subprocess
import sys
import re
import time
import json
import os
from pkg_resources import packaging

_DEVICE_NAME = "BazeliOSPhone"
_DEVICE_TYPE = os.getenv('TEST_DEVICE_MODEL') if os.getenv(
    'TEST_DEVICE_MODEL') else "com.apple.CoreSimulator.SimDeviceType.iPhone-15"
_BOOT_TIMEOUT = 180

_IMPLEMENTED_IN_BOTH_ERROR_STRING = "is implemented in both"
_EXTENSION_POINT_ERROR_STRING = "did not find extension point"

def run_flaky_simctl_process(args, **process_args):
    attempts = 5
    result = None
    scaled_timeout = process_args.get("timeout", None)

    for attempt in range(1, attempts + 1):
        try:
            result = subprocess.run(args, **process_args)
            # Assume we're giving it valid simctl commands here: the command is
            # flaky if it returns 1 but will succeed in the future. Less than
            # ideal in an error case: we should inspect logs to figure out what
            # is wrong here
            if result.returncode == 0:
                return result
            print("[WARN] flaky simctl process retuned non-zero exit status\n{}".format(result.stderr), file=sys.stderr)
        except subprocess.TimeoutExpired as e:
            if attempt == attempts:
                raise e
            print("[WARN] flaky simctl process raised {}".format(e), file=sys.stderr)

        # Scale subprocess timeouts
        if scaled_timeout:
            scaled_timeout = scaled_timeout * attempt
            process_args["timeout"] = scaled_timeout

        # Adding some linear backoff
        time.sleep(2 * attempt)
    return result


def get_current_runtime_version():
    runtimes_command = ['xcrun', 'simctl', 'list', 'runtimes', '-j']
    result = run_flaky_simctl_process(
        runtimes_command,
        stdout=subprocess.PIPE,
        stderr=subprocess.PIPE,
        encoding='utf-8'
    )

    if result.stderr and contains_errors_requiring_exception(result.stderr):
        raise Exception(result.stderr)

    runtimes = json.loads(result.stdout)["runtimes"]

    # we only care about the iOS runtimes for now
    ios_runtimes = [
        runtime for runtime in runtimes if runtime["platform"] == "iOS"]

    # find the newest runtime. Apple uses semver, so packaging.version allows for stable sorting.
    ios_runtimes.sort(key=lambda runtime: packaging.version.parse(
        runtime["version"]), reverse=True)

    if len(ios_runtimes) == 0:
        raise Exception(
            "Cannot determine the most recent runtime for the selected Xcode version")

    return ios_runtimes[0]["identifier"]


def create_device(device_name, device_type, runtime_version):
    create_command = ['xcrun', 'simctl', 'create',
                      device_name, device_type, runtime_version]
    result = run_flaky_simctl_process(
        create_command,
        stdout=subprocess.PIPE,
        stderr=subprocess.PIPE,
        encoding='utf-8'
    )

    if result.stderr:
        raise Exception(result.stderr)

    device_id_matches = re.search("[-A-Z0-9]+", result.stdout)
    if not device_id_matches.group():
        raise Exception('Could not obtain the device id')
    return device_id_matches.group()


def print_sims():
    print("[INFO] print sims..", file=sys.stderr)
    result = run_flaky_simctl_process(
        ['xcrun', 'simctl', 'list'],
        stdout=subprocess.PIPE,
        stderr=subprocess.PIPE,
        encoding='utf-8'
    )
    if result.returncode != 0:
        raise Exception("[ERROR] Cannot print sims {}".format(result.stderr))


def boot_device(device_id):
    boot_command = ['xcrun', 'simctl', 'boot', device_id]
    result = run_flaky_simctl_process(
        boot_command,
        stdout=subprocess.PIPE,
        stderr=subprocess.PIPE,
        encoding='utf-8'
    )
    if result.stderr and contains_errors_requiring_exception(result.stderr):
        raise Exception(result.stderr)


def wait_for_device_to_boot(device_id, timeout):
    wait_command = ['xcrun', 'simctl', 'bootstatus', device_id]
    result = run_flaky_simctl_process(
        wait_command,
        stdout=subprocess.PIPE,
        stderr=subprocess.PIPE,
        encoding='utf-8',
        timeout=timeout
    )

    # add an arbitrary delay, since bootstatus, sadly, might not wait long enough.
    time.sleep(3)

    if result.stderr and contains_errors_requiring_exception(result.stderr):
        raise Exception(result.stderr)


def contains_errors_requiring_exception(stderr):
    for line in stderr.splitlines():
        if _IMPLEMENTED_IN_BOTH_ERROR_STRING in line:
            continue
        if _EXTENSION_POINT_ERROR_STRING in line:
            continue
        return True
    return False


def create_sim_device_and_boot():
    device_runtime = get_current_runtime_version()
    device_id = create_device(_DEVICE_NAME, _DEVICE_TYPE, device_runtime)
    boot_device(device_id)
    wait_for_device_to_boot(device_id, _BOOT_TIMEOUT)
    return device_id


def handle_bootstatus_timeout(e):
    print(
        "[warning] Sim failed to boot because 'subprocess.TimeoutExpired', likely should restart the machine",
        file=sys.stderr
    )
    raise e


def main():
    print_sims()

    try:
        device_id = create_sim_device_and_boot()
        print(f'{device_id}')
    except subprocess.TimeoutExpired as e:
        # On the last attempt raise an exception
        handle_bootstatus_timeout(e)

main()
