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
xcspec_bzl_path = sys.argv[3]
eval_bzl_path = sys.argv[4]
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

cond_contents = """
# foo

"""

bzl_contents = """
# Extracted from Xcode %s
# To update, in rules_ios run `bazel run data_generators:extract_xcspecs`

SETTINGS = """ % xcode_version

meths = {}

def str_to_thing(string, key):
    r = re.compile("\$\(([^\$)]+)\)")
    if not r.search(string):
        return 'return (False, %s)' % repr(string)

    d = {}

    def record_substitution(match):
        name = match[1]
        if name not in d:
            d[name] = (
                'eval_val_%s' % len(d),
                name,
                'eval_key_%s' % len(d),
            )
        if key == "DefaultValue":
            return "{%s}" % d[name][0]
        return d[name][0]

    while True:
        (string, subs_made) = r.subn(repl=record_substitution, string=string)
        if not subs_made:
            break

    def format_str(s):
        f = re.findall('{(eval_val_\d+)}', s)
        if not f:
            return '"%s"' % s
        if len(f) == 1:
            if s == '{%s}' % f[0]:
                return f[0]
        return '"%s".format(%s)' % (s, ', '.join(('{var} = {var}'.format(var = v) for v in f)))

    s = "\n    used_user_content = False\n" + "\n".join((
        """
    {var} = ""
    {key} = {key_value}
    if {key} in xcconfigs:
        {var} = xcconfigs[{key}]
        used_user_content = True
    elif {key} in id_configs:
        opt = id_configs[{key}]
        if "DefaultValue" in opt:
            ({var}_used_user_content, {var}) = XCSPEC_EVALS[opt["DefaultValue"]](xcconfigs, id_configs)
            used_user_content = used_user_content or {var}_used_user_content""".format(var=var, name=name, key=key, key_value=format_str(name))
        for (name, (var, _i, key)) in d.items()
    ))

    if key == 'DefaultValue':
        return s + '\n\n    return (used_user_content, %s)' % (format_str(string), )
    elif key == 'Condition':
        string = re.sub(pattern="(?:^|[(&|!= ])(?!eval_val_\d+)([A-Za-z0-9_]+)", repl= lambda m: repr(m[1]), string=string)
        return s + '\n\n    return (used_user_content, (%s))' % string.replace('||', 'or').replace('!=', '__NEQ__').replace('!', 'not ').replace('&&', 'and').replace('__NEQ__', '!=')
    
    raise "Unknown key %s" % key

def _add_eval(id: str, name, key, string, meths):
    meth = '__'.join((id.replace('.', '_'), name.replace('.', '_'), key))
    if meth in meths:
        raise "Dup"

    meths[meth] = """
def _{meth}(xcconfigs, id_configs):
    # {string}
    {expr}
""".format(meth=meth, string=string, expr=str_to_thing(string, key))

    return meth

to_print = {
    x['Identifier']:
        {k: ({o['Name']: {ok: (_add_eval(x['Identifier'], o['Name'], ok, ov, meths) if ok in ('DefaultValue', 'Condition') else ov) for (ok, ov) in o.items() if ok not in ('Name',)} for o in v if o['Name'] not in ('SDKROOT',)} if k == 'Options' else v)
         for (k, v) in x.items()}
    for x in a if x['Identifier'] in ids
}

for (m, s) in meths.items():
    cond_contents += s
cond_contents += "\nXCSPEC_EVALS = {\n%s\n}\n" % "\n".join(
    sorted(('  "{k}": _{k},'.format(k=k)) for k in meths))

# stop sorting dictionary entries
# both of these are needed to be compatible with various python versions
pprint._sorted = lambda x: x
pprint.sorted = lambda x, key: x

bzl_contents += pprint.pformat(to_print, width=150)
bzl_contents = re.sub(r"([\"'])(\n\s*['\"])", r"\1 +\2", bzl_contents)

def buildifier(input):
    try:
        return subprocess.check_output(
            ['buildifier', '-lint', 'fix', '-type', 'bzl'], input=input, text=True)
    except FileNotFoundError:
        return input

with open(xcspec_bzl_path, 'w') as f:
    print(buildifier(bzl_contents), file=f, end='')

with open(eval_bzl_path, 'w') as f:
    print(buildifier(cond_contents), file=f, end='')
