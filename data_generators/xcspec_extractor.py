#!/usr/bin/env python

"""
Extracts xcspec info from a given Xcode developer dir
and prints out a bzl file that contains a single constant, `SETTINGS`,
that can be used to access the xcspecs from starlark.

Usage: bazel run //data_generators:extract_xcspecs
Alternate: xcspec_extractor.py /Application/Xcode.app/Contents/Developer 11.2.1 ../data/xcspecs.bzl  ../data/xcspec_evals.bzl
"""

import plistlib
import pprint
import subprocess
import os
import re
import sys


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
xcode_plugins = os.path.join(
    xcode, "Contents/PlugIns/XCBSpecifications.ideplugin/Contents/Resources"
)

xcspecs = [
    os.path.join(xcode_plugins, plugin)
    for plugin in [
        "Ld.xcspec",
        "Clang LLVM 1.0.xcspec",
        "Core Data.xcspec",
        "IBCompiler.xcspec",
        "Swift.xcspec",
    ]
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

header = """\"""
############################################################################
#                   THIS IS GENERATED CODE                                 #
# Extracted from Xcode {xcode_version}                                     #
# To update, in rules_ios run `bazel run data_generators:extract_xcspecs`  #
############################################################################
\"""
""".format(
    xcode_version=xcode_version
)

xcpec_evals_bzl_contents = """
{header}

""".format(
    header=header
)

xcspecs_bzl_contents = """
{header}

SETTINGS = """.format(header=header)

eval_methods = {}

XCCONFIG_EXPANSION = re.compile("\$\(([^\$)]+)\)")
STRING_FORMAT_EVAL_VAL_REFERENCE = re.compile('{(eval_val_\d+)}')
CONDITION_EVAL_VAL_REFERENCE = re.compile(
    "(?:^|[(&|!= ])(?!eval_val_\d+)([A-Za-z0-9_]+)")


def generate_method_body_for_expression(string, key):
    if not XCCONFIG_EXPANSION.search(string):
        return 'return (False, %s)' % repr(string)

    expanded_variables = {}

    def record_substitution(match):
        name = match[1]
        if name not in expanded_variables:
            expanded_variables[name] = (
                'eval_val_%s' % len(expanded_variables),
                name,
                'eval_key_%s' % len(expanded_variables),
            )
        if key == "DefaultValue":
            return "{%s}" % expanded_variables[name][0]
        return expanded_variables[name][0]

    while True:
        (string, subs_made) = XCCONFIG_EXPANSION.subn(
            repl=record_substitution, string=string)
        if not subs_made:
            break

    def format_str(s):
        val_references = STRING_FORMAT_EVAL_VAL_REFERENCE.findall(s)
        if not val_references:
            return '"%s"' % s
        if len(val_references) == 1:
            if s == '{%s}' % val_references[0]:
                # directly return the variable, without using an format string
                return val_references[0]

        return '"{string}".format({format})'.format(
            string=s,
            format=', '.join(('{var} = {var}'.format(var=v) for v in val_references)))

    method_body = "\n    used_user_content = False\n"
    method_body += "\n".join((
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
        for (name, (var, _i, key)) in expanded_variables.items()
    ))

    if key == 'DefaultValue':
        return method_body + '\n\n    return (used_user_content, %s)' % (format_str(string), )
    elif key == 'Condition':
        string = CONDITION_EVAL_VAL_REFERENCE.sub(
            repl=lambda m: repr(m[1]), string=string)
        string = re.sub(
            # Find all implicit boolean conditionals and replace them with an explict `== "YES"`
            '(eval_val_[0-9]+)(\s+([&|]{2})|\s*\)|\s*$)', '\\1 == "YES"\\2', string
            ).replace('&&', 'and').replace('||', 'or'
            ).replace('!=', '__NEQ__').replace('!', 'not ').replace('__NEQ__', '!=')
        return method_body + \
            '\n\n    return (used_user_content, ({}))'.format(string)

    raise "Unknown key %s" % key


def add_eval(id, name, key, string, eval_methods):
    method_name = '__'.join(
        (id.replace('.', '_'), name.replace('.', '_'), key))
    if method_name in eval_methods:
        raise "Duplicate method {}".format(method_name)

    eval_methods[method_name] = """
def _{method_name}(xcconfigs, id_configs):
    # {string}
    {expr}
""".format(method_name=method_name, string=string, expr=generate_method_body_for_expression(string, key))

    return method_name


to_print = {
    x['Identifier']:
        {k: ({o['Name']:
              {ok: (add_eval(x['Identifier'], o['Name'], ok, ov, eval_methods) if ok in (
                  'DefaultValue', 'Condition') else ov) for (ok, ov) in o.items() if ok not in ('Name',)}
              for o in v if o['Name'] not in ('SDKROOT',)} if k == 'Options' else v)
         for (k, v) in x.items()}
    for x in a if x['Identifier'] in ids
}

for (m, s) in eval_methods.items():
    xcpec_evals_bzl_contents += s

xcpec_evals_bzl_contents += "\nXCSPEC_EVALS = {\n%s\n}\n" % "\n".join(
    sorted(('  "{k}": _{k},'.format(k=k)) for k in eval_methods))

# stop sorting dictionary entries
# both of these are needed to be compatible with various python versions
pprint._sorted = lambda x: x
pprint.sorted = lambda x, key: x

xcspecs_bzl_contents += pprint.pformat(to_print, width=150)
xcspecs_bzl_contents = re.sub(
    r"([\"'])(\n\s*['\"])", r"\1 +\2", xcspecs_bzl_contents)


def buildifier(input):
    try:
        return subprocess.check_output(
            ['buildifier', '-lint', 'fix', '-type', 'bzl'], input=input, text=True)
    except FileNotFoundError:
        return input


with open(xcspec_bzl_path, 'w') as f:
    print(buildifier(xcspecs_bzl_contents), file=f, end='')

with open(eval_bzl_path, 'w') as f:
    print(buildifier(xcpec_evals_bzl_contents), file=f, end='')
