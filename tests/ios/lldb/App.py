import tests.ios.lldb.lldb_test as lldb_test
import argparse
import os
parser = argparse.ArgumentParser()
parser.add_argument("--app")
parser.add_argument("--sdk")
parser.add_argument("--device")
parser.add_argument("--spec")

args = parser.parse_args()

root_dir = os.path.dirname(os.path.dirname(os.environ["GTEST_TMP_DIR"]))
app_path = os.path.join(root_dir, args.app)
spec_path = os.path.join(root_dir, args.spec)
lldb_test.run_lldb_test(ipa_path=app_path, sdk=args.sdk,
                        device=args.device, spec_path=spec_path)
