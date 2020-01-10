import json
import os
import sys

class VFS():
    def __init__(self):
        self.roots = {}
        self.case_sensitive = False
        self.use_external_names = None
        self.ignore_contents = False
        self.overlay_dir = None

    def add_file_mapping(self, virtual_path, real_path):
        # assert os.path.isabs(virtual_path), "%s is not absolute" % virtual_path
        # assert os.path.isabs(real_path), "%s is not absolute" % real_path
        dir, name = virtual_path.rsplit("/", maxsplit = 1)
        if not dir in self.roots:
            self.roots[dir] = []
        self.roots[dir].append({"name": name, "external-contents": real_path, "type": "file"})
    
    def set_case_sensitivity(self, case_sensitive):
        self.case_sensitive = case_sensitive

    def set_use_external_names(self, use_external_names):
        self.use_external_names = use_external_names

    def set_ignore_non_existent_contents(self, ignore_contents):
        self.ignore_contents = ignore_contents

    def set_overlay_dir(self, overlay_dir):
        self.overlay_dir = overlay_dir

    def write(self, output):
        overlay = {
            "version": 0,
            "roots": [],
        }
        if self.case_sensitive is not None: overlay["case-sensitive"] = str(self.case_sensitive)
        if self.use_external_names is not None: overlay["use-external-names"] = str(self.use_external_names)
        if self.ignore_contents is not None: overlay["ignore-non-existent-contents"] = str(self.ignore_contents)
        for dir in self.roots:
            entries = self.roots[dir]
            overlay["roots"].append({
                "type": "directory",
                "name": os.path.abspath(dir),
                "contents": entries
            })

        json.dump(overlay, output, indent = 2)


def main():
    """Main function."""
    # check args
    if len(sys.argv) != 3:
        print('Invalid arguments. usage: vfs_overlay vfs_path params_file')
        sys.exit(1)

    params_file = sys.argv[2]
    vfs = VFS()

    with open(params_file, 'r') as f:
        for l in f:
            real, virtual = l.strip().split('|')
            vfs.add_file_mapping(virtual, real)

    with open(sys.argv[1], 'w') as f:
        vfs.write(f)

if __name__ == '__main__':
    main()
