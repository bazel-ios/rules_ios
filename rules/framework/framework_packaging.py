"""Framework packaging tool.

This tool takes a manifest json file and
packages a framework folder.
"""
import argparse
import os
import shutil
import subprocess
import sys

def _mkdir(path):
    if not os.path.exists(path):
        os.makedirs(path)

def _cp(src, dest):
    shutil.copyfile(src, dest)

def _merge_binaries(framework_root, framework_name, binary_in):
    """Process built binaries.

    libtool is used to merge multiple libs.

    Args:
        framework_root: root folder of the framework
        framework_name: name of the framework
        binary_in: a list of binary paths
    """
    output_path = os.path.join(framework_root, framework_name)
    if len(binary_in) == 1:
        # avoid unnecessary invocation,
        # ensure the same object is used so the CAS is not unecessarily bloated
        _cp(binary_in[0], output_path)
    else:
        commands = ["libtool",
                    "-static",
                    "-D",
                    "-no_warning_for_no_symbols",
                    "-o", output_path
                    ] + binary_in
        subprocess.check_call(commands)

def _copy_modulemap(framework_root, modulemap_path):
    """Copy modulemaps to its destination.
    Args:
        framework_root: root folder of the framework
        modulemap_path: path of the original modulemap
    """
    dest = os.path.join(framework_root, "Modules", "module.modulemap")
    _mkdir(os.path.dirname(dest))
    _cp(modulemap_path, dest)

def _clean(framework_root, manifest_file, output_manifest_file):
    """Remove stale files from the framework root.

    Args:
        framework_root: root folder of the framework
        manifest_file: path to the input manifest file
        output_manifest_file: path to the output manifest file
    """

    _cp(manifest_file, output_manifest_file)

    if not os.path.exists(framework_root):
        return

    with open(manifest_file) as f:
        manifest_lines = (line.rstrip() for line in f)

        files_to_keep = set()
        dirs_to_keep = set((framework_root,))
        for file in manifest_lines:
            files_to_keep.add(file)

            dir = os.path.dirname(file)
            while dir not in dirs_to_keep:
                dirs_to_keep.add(dir)
                dir = os.path.dirname(dir)

    for root, dirs, files in os.walk(framework_root):
        for d in dirs:
            path = os.path.join(root, d)
            if path not in dirs_to_keep:
                shutil.rmtree(path)
        for f in files:
            path = os.path.join(root, f)
            if path not in files_to_keep:
                os.remove(path)


class Args(argparse.Namespace):
    def input(self):
        assert len(self.inputs) == 1
        return self.inputs[0]

    def output(self):
        assert len(self.outputs) == 1
        return self.outputs[0]

def main():
    """Main function."""
    actions = {
        "binary":
            lambda args: _merge_binaries(args.framework_root, args.framework_name, args.inputs),
        "modulemap":
            lambda args: _copy_modulemap(args.framework_root, args.input()),
        "swiftmodule":
            lambda args: _cp(args.input(), args.output()),
        "swiftinterface":
            lambda args: _cp(args.input(), args.output()),
        "swiftdoc":
            lambda args: _cp(args.input(), args.output()),
        "clean":
            lambda args: _clean(args.framework_root, args.input(), args.output()),
    }

    parser = argparse.ArgumentParser(description="Packages files into a framework", fromfile_prefix_chars = '@')
    parser.add_argument('--framework_name', type = str, required=True)
    parser.add_argument('--framework_root', type = str, required=True)
    parser.add_argument('--action', choices = actions.keys() , required=True)
    parser.add_argument('--inputs', type = str, nargs='*')
    parser.add_argument('--outputs', type = str, nargs='*')
    args = parser.parse_args(namespace=Args())

    action = actions[args.action]
    action(args)


if __name__ == '__main__':
    main()
