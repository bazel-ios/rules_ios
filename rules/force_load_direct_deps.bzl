load("@bazel_skylib//lib:paths.bzl", "paths")
load("@bazel_tools//tools/cpp:toolchain_utils.bzl", "find_cpp_toolchain", "use_cpp_toolchain")
load("//rules:providers.bzl", "AvoidDepsInfo")
load("//rules:transition_support.bzl", "transition_support")

def _objc_provider_static_libraries(dep):
    """Returns the ObjcProvider static libraries (.a) that should be force loaded.
    """
    if not apple_common.Objc in dep:
        return []

    return dep[apple_common.Objc].library.to_list()

def _cc_info_static_libraries(dep):
    """Returns the CcInfo static libraries (.a) that should be force loaded.

    NOTE: CcInfo, unlike ObjcProvider, does not encode where the static library came from.
    In the existing `_objc_provider_static_libraries` we only collect `.library` from ObjcProvider.
    ObjcProvider `.library` list static library dependencies of the current target,
    it does not include imported static libraries (such as those from `.framework` files).
    CcInfo only provides `.static_library` and does not make this distinction.
    To match this behavior, we only collect `.static_library` from CcInfo that are not from `.framework`s.
    """
    if not CcInfo in dep:
        return []

    static_cc_libraries = []
    for linker_input in dep[CcInfo].linking_context.linker_inputs.to_list():
        for library_to_link in linker_input.libraries:
            if not library_to_link.static_library:
                continue
            containing_path = paths.dirname(library_to_link.static_library.path)
            if containing_path.endswith(".framework"):
                continue
            static_cc_libraries.append(library_to_link.static_library)

    return static_cc_libraries
