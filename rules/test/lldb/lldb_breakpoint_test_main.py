# This program is a thin driver to connect the lldb_test to Bazel

import rules.test.lldb.lldb_sim_runner as lldb_sim_runner
import argparse
import os
import logging
import json

logging.basicConfig(
    format="%(asctime)s.%(msecs)03d %(levelname)s %(message)s",
    datefmt="%Y-%m-%d %H:%M:%S",
    level=logging.INFO)
logger = logging.getLogger(__name__)


parser = argparse.ArgumentParser()
parser.add_argument("--app")
parser.add_argument("--sdk")
parser.add_argument("--spec")
parser.add_argument("--device")
parser.add_argument("--lldbinit")

args = parser.parse_args()


def setup_test_tmp_dir(exec_root, test_tmp_dir, test_spec):
    logger.info("Setup test root: " + test_tmp_dir)
    # LLDB needs to read this file later
    os.symlink(test_spec, os.path.join(test_tmp_dir, "test_spec.json"))
    logging.info("Symlinking spec %s to %s", test_spec,
                 os.path.join(test_tmp_dir, "test_spec.json"))

    return test_tmp_dir


def get_test_result(test_root):
    lpath = test_root + "/test_result.json"
    if not os.path.exists(lpath):
        raise Exception(f"Test exited without result %s", test_root)
    with open(lpath, 'r') as test_result:
        return json.load(test_result)


tmp_dir = os.environ["TEST_TMPDIR"]
exec_root = os.path.dirname(os.path.dirname(tmp_dir))
test_spec = os.path.join(exec_root, args.spec)
test_tmp_dir = setup_test_tmp_dir(exec_root, tmp_dir, test_spec)
app_path = os.path.join(exec_root, args.app)
logger.info("Test Root " + test_tmp_dir)

stdout_path = os.path.join(test_tmp_dir, "lldb.stdout")
exit_code = lldb_sim_runner.run_lldb(app_path=app_path, sdk=args.sdk,
                                     device=args.device, lldbinit_path=os.path.join(
                                         exec_root, args.lldbinit),
                                     test_root=exec_root, lldb_stdout=stdout_path)
if exit_code != 0:
    exit(exit_code)

# Check to ensure that stdout was written
if not os.path.exists(stdout_path):
    raise Exception(f"Test exited without lldb.stdout %s", stdout_path)


def match_test_spec(stdout, test_spec):
    with open(test_spec, 'r') as test_spec:
        test_spec_dict = json.load(test_spec)
        if not "substrs" in test_spec_dict:
            logging.info(f"Skipping matching for spec %s", test_spec)

        substrs = test_spec_dict["substrs"]
        matches = {}
        for substr in substrs:
            logging.info("Load match: (" + substr + ")")
            matches[substr] = 0

        match_count = 0
        for line in stdout:
            match = line.strip()
            logging.debug("Try match: (" + match + ")")
            if match in matches:
                logging.debug("Got match:" + match)
                match_count += 1
                matches[match] = matches[match] = 1

        # Could add better output here, but use stdout for now
        if match_count != len(substrs):
            raise Exception(f"Invalid matches lldb.stdout %s", str(matches))


with open(stdout_path, "r") as stdout:
    match_test_spec(stdout, test_spec)

result = get_test_result(test_tmp_dir)
exit(exit_code if result["status"] == 0 else 1)
