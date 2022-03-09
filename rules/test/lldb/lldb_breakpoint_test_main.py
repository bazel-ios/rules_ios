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


def setup_test_root(test_root, test_spec):
    source_file = os.path.realpath(__file__)
    breakpoint_file = os.path.join(
        os.path.dirname(source_file), "breakpoint.py")

    os.symlink(breakpoint_file, os.path.join(test_root, "breakpoint.py"))
    logging.info("Symlinking breakpoint %s",
                 os.path.join(test_root, "breakpoint.py"))
    logger.info("Setup test root: " + test_root)
    # LLDB needs to read this file later
    os.symlink(test_spec, os.path.join(test_root, "test_spec.json"))
    return test_root


def get_test_result(test_root):
    lpath = test_root + "/test_result.json"
    if not os.path.exists(lpath):
        raise Exception(f"Test exited without result %s", test_root)

    with open(lpath, 'r') as test_result:
        return json.load(test_result)


tmp_dir = os.environ["GTEST_TMP_DIR"]
test_root = os.path.dirname(os.path.dirname(tmp_dir))
test_tmp_dir = setup_test_root(test_root, args.spec)
app_path = os.path.join(test_root, args.app)

exit_code = lldb_sim_runner.run_lldb(ipa_path=app_path, sdk=args.sdk,
                                     device=args.device, lldbinit_path=os.path.join(
                                         test_root, args.lldbinit),
                                     test_root=test_tmp_dir)
if exit_code != 0:
    exit(exit_code)

# Check to ensure that stdout was written
stdout_path = os.path.join(test_root, "lldb.stdout")
if not os.path.exists(stdout_path):
    raise Exception(f"Test exited without lldb.stdout %s", stdout_path)

result = get_test_result(test_tmp_dir)
exit(exit_code if result["status"] == 0 else 1)
