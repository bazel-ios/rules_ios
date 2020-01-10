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


def _copy_private_headers(framework_root, header_paths):
    _copy_headers(framework_root, header_paths, "PrivateHeaders")

def _copy_headers(framework_root, header_paths, dir = "Headers"):
    """Copy header from source to framework/Header folder.

    Args:
        framework_root: root path of the framework
        header_paths: a list of paths of headers
    """
    if not header_paths: return

    header_folder = os.path.join(framework_root, dir)
    _mkdir(header_folder)
    basenames = {}
    for path in header_paths:
        basename = os.path.basename(path)
        if basename in basenames and path != basenames[basename]:
            print(
                "Error: Multiple files with the same name {} exists\n"
                "New path: {}\n Existing path: {}\n"
                "in the same module. Please double "
                "check".format(basename, path, basenames[basename]))
            sys.exit(1)
        else:
            basenames[basename] = path
            dest = os.path.join(header_folder, basename)
            _cp(path, dest)


def _merge_binaries(framework_root, framework_name, binary_in):
    """Process built binaries.

    libtool is used to merge multiple libs.

    Args:
        framework_root: root folder of the framework
        framework_name: name of the framework
        binary_in: a list of binary paths
    """
    output_path = os.path.join(framework_root, framework_name)
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

class Args(argparse.Namespace):
    def input(self):
        assert len(self.inputs) == 1
        return self.inputs[0]

    def output(self):
        assert len(self.output) == 1
        return self.output[0]

def main():
    """Main function."""
    actions = {
        "header": 
            lambda args: _copy_headers(args.framework_root, args.inputs),
        "private_header":
            lambda args: _copy_private_headers(args.framework_root, args.inputs),
        "binary":
            lambda args: _merge_binaries(args.framework_root, args.framework_name, args.inputs),
        "modulemap":
            lambda args: _copy_modulemap(args.framework_root, args.input()),
        "swiftmodule":
            lambda args: _cp(args.inputs, args.outputs),
        "swiftdoc":
            lambda args: _cp(args.inputs, args.outputs),
    }

    parser = argparse.ArgumentParser(description="Packages files into a framework", fromfile_prefix_chars = '@')
    parser.add_argument('--framework_name', type = str, required=True)
    parser.add_argument('--framework_root', type = str, required=True)
    parser.add_argument('--action', choices = actions.keys() , required=True)
    parser.add_argument('--inputs', type = str, nargs='*')
    parser.add_argument('--outputs', type = str, nargs='*')
    args = parser.parse_args(namespace=Args())
    if args.framework_name == 'RegisterUI':
        print(args)
    
    action = actions[args.action]
    action(args)


if __name__ == '__main__':
    main()
