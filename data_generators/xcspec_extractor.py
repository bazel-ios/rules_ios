#!/usr/bin/env python

"""
Extracts xcspec info from a given Xcode developer dir
and prints out a bzl file that contains a single constant, `SETTINGS`,
that can be used to access the xcspecs from starlark.

Usage: xcspec_extractor.py /Application/Xcode.app/Contents/Developer 11.2.1
"""

import plistlib
import pprint
import subprocess
import os
import re
import sys

try:
    from StringIO import BytesIO  # for Python 2
except ImportError:
    from io import BytesIO  # for Python 3


def xcspec_from_file(path):
    xml = subprocess.check_output(
        ['plutil', '-convert', 'xml1', '-o', '-', '--', path])
    plist = plistlib.loads(xml, fmt=plistlib.FMT_XML)
    if not isinstance(plist, list):
        plist = [plist]
    return plist


developer_dir = sys.argv[1]
xcode_version = sys.argv[2]
xcode = os.path.dirname(os.path.dirname(developer_dir))
xcode3plusgins = os.path.join(
    xcode, 'Contents/PlugIns/Xcode3Core.ideplugin/Contents/SharedSupport/Developer/Library/Xcode/Plug-ins')

xcspecs = [
    os.path.join(xcode3plusgins,
                 "CoreBuildTasks.xcplugin/Contents/Resources/Ld.xcspec"),
    os.path.join(
        xcode3plusgins, "Clang LLVM 1.0.xcplugin/Contents/Resources/Clang LLVM 1.0.xcspec"),
    os.path.join(xcode3plusgins,
                 "Core Data.xcplugin/Contents/Resources/Core Data.xcspec"),
    os.path.join(
        xcode3plusgins, "IBCompilerPlugin.xcplugin/Contents/Resources/IBCompiler.xcspec"),
    os.path.join(xcode3plusgins,
                 "XCLanguageSupport.xcplugin/Contents/Resources/Swift.xcspec"),
]

a = []
for path in xcspecs:
    a.extend(xcspec_from_file(path))
a.sort(key=lambda x: x['Identifier'])

ids = (
    "com.apple.compilers.llvm.clang.1_0",
    "com.apple.compilers.model.coredata",
    "com.apple.compilers.model.coredatamapping",
    "com.apple.pbx.linkers.ld",
    "com.apple.xcode.tools.ibtool.compiler",
    "com.apple.xcode.tools.swift.compiler",
)

bzl_contents = """
# Extracted from Xcode %s
# To update, in rules_ios run `bazel run data_generators:extract_xcspecs`

SETTINGS = """ % xcode_version

to_print = {
    x['Identifier']:
        {k: ({o['Name']: o for o in v} if k == 'Options' else v)
         for (k, v) in x.items()}
    for x in a if x['Identifier'] in ids
}

# stop sorting dictionary entried
# both of these are needed to be compatible with various python versions
pprint._sorted = lambda x: x
pprint.sorted = lambda x, key: x

bzl_contents += pprint.pformat(to_print, width=150)
bzl_contents = re.sub(r"([\"'])(\n\s*['\"])", r"\1 +\2", bzl_contents)
try:
    bzl_contents = subprocess.check_output(
        ['buildifier', '-lint', 'fix', '-type', 'bzl'], input=bzl_contents, text=True)
except FileNotFoundError:
    pass  # buildifier not found
print(bzl_contents, end='')
