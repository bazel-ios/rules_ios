"""
############################################################################
#                   THIS IS GENERATED CODE                                 #
# Extracted from Xcode 15.2                                     #
# To update, in rules_ios run `bazel run data_generators:extract_xcspecs`  #
############################################################################
"""

def _com_apple_compilers_llvm_clang_1_0__CLANG_TARGET_TRIPLE_ARCHS__DefaultValue(xcconfigs, id_configs):
    # $(CURRENT_ARCH)

    used_user_content = False

    eval_val_0 = ""
    eval_key_0 = "CURRENT_ARCH"
    if eval_key_0 in xcconfigs:
        eval_val_0 = xcconfigs[eval_key_0]
        used_user_content = True
    elif eval_key_0 in id_configs:
        opt = id_configs[eval_key_0]
        if "DefaultValue" in opt:
            (eval_val_0_used_user_content, eval_val_0) = XCSPEC_EVALS[opt["DefaultValue"]](xcconfigs, id_configs)
            used_user_content = used_user_content or eval_val_0_used_user_content

    return (used_user_content, eval_val_0)

def _com_apple_compilers_llvm_clang_1_0__diagnostic_message_length__DefaultValue(xcconfigs, id_configs):
    # 0
    return (False, "0")

def _com_apple_compilers_llvm_clang_1_0__print_note_include_stack__DefaultValue(xcconfigs, id_configs):
    # YES
    return (False, "YES")

def _com_apple_compilers_llvm_clang_1_0__CLANG_MACRO_BACKTRACE_LIMIT__DefaultValue(xcconfigs, id_configs):
    # 0
    return (False, "0")

def _com_apple_compilers_llvm_clang_1_0__CLANG_RETAIN_COMMENTS_FROM_SYSTEM_HEADERS__DefaultValue(xcconfigs, id_configs):
    # NO
    return (False, "NO")

def _com_apple_compilers_llvm_clang_1_0__CLANG_COLOR_DIAGNOSTICS__DefaultValue(xcconfigs, id_configs):
    # $(COLOR_DIAGNOSTICS)

    used_user_content = False

    eval_val_0 = ""
    eval_key_0 = "COLOR_DIAGNOSTICS"
    if eval_key_0 in xcconfigs:
        eval_val_0 = xcconfigs[eval_key_0]
        used_user_content = True
    elif eval_key_0 in id_configs:
        opt = id_configs[eval_key_0]
        if "DefaultValue" in opt:
            (eval_val_0_used_user_content, eval_val_0) = XCSPEC_EVALS[opt["DefaultValue"]](xcconfigs, id_configs)
            used_user_content = used_user_content or eval_val_0_used_user_content

    return (used_user_content, eval_val_0)

def _com_apple_compilers_llvm_clang_1_0__GCC_INPUT_FILETYPE__DefaultValue(xcconfigs, id_configs):
    # automatic
    return (False, "automatic")

def _com_apple_compilers_llvm_clang_1_0__GCC_OPERATION__DefaultValue(xcconfigs, id_configs):
    # compile
    return (False, "compile")

def _com_apple_compilers_llvm_clang_1_0__GCC_USE_STANDARD_INCLUDE_SEARCHING__DefaultValue(xcconfigs, id_configs):
    # YES
    return (False, "YES")

def _com_apple_compilers_llvm_clang_1_0__GCC_C_LANGUAGE_STANDARD__DefaultValue(xcconfigs, id_configs):
    # compiler-default
    return (False, "compiler-default")

def _com_apple_compilers_llvm_clang_1_0__CLANG_CXX_LANGUAGE_STANDARD__DefaultValue(xcconfigs, id_configs):
    # compiler-default
    return (False, "compiler-default")

def _com_apple_compilers_llvm_clang_1_0__CLANG_CXX_LIBRARY__DefaultValue(xcconfigs, id_configs):
    # compiler-default
    return (False, "compiler-default")

def _com_apple_compilers_llvm_clang_1_0__CLANG_ENABLE_OBJC_ARC__DefaultValue(xcconfigs, id_configs):
    # NO
    return (False, "NO")

def _com_apple_compilers_llvm_clang_1_0__CLANG_ENABLE_OBJC_WEAK__DefaultValue(xcconfigs, id_configs):
    # NO
    return (False, "NO")

def _com_apple_compilers_llvm_clang_1_0__CLANG_LINK_OBJC_RUNTIME__DefaultValue(xcconfigs, id_configs):
    # $(LINK_OBJC_RUNTIME)

    used_user_content = False

    eval_val_0 = ""
    eval_key_0 = "LINK_OBJC_RUNTIME"
    if eval_key_0 in xcconfigs:
        eval_val_0 = xcconfigs[eval_key_0]
        used_user_content = True
    elif eval_key_0 in id_configs:
        opt = id_configs[eval_key_0]
        if "DefaultValue" in opt:
            (eval_val_0_used_user_content, eval_val_0) = XCSPEC_EVALS[opt["DefaultValue"]](xcconfigs, id_configs)
            used_user_content = used_user_content or eval_val_0_used_user_content

    return (used_user_content, eval_val_0)

def _com_apple_compilers_llvm_clang_1_0__CLANG_ENABLE_MODULES__DefaultValue(xcconfigs, id_configs):
    # NO
    return (False, "NO")

def _com_apple_compilers_llvm_clang_1_0__CLANG_ENABLE_MODULE_DEBUGGING__DefaultValue(xcconfigs, id_configs):
    # YES
    return (False, "YES")

def _com_apple_compilers_llvm_clang_1_0__CLANG_DEBUG_MODULES__Condition(xcconfigs, id_configs):
    # $(GCC_GENERATE_DEBUGGING_SYMBOLS)  &&  ! $(INDEX_ENABLE_BUILD_ARENA)  &&  ( $(CLANG_ENABLE_MODULES)  ||  ( $(GCC_PREFIX_HEADER) != ''  &&  $(GCC_PRECOMPILE_PREFIX_HEADER) ) )

    used_user_content = False

    eval_val_0 = ""
    eval_key_0 = "GCC_GENERATE_DEBUGGING_SYMBOLS"
    if eval_key_0 in xcconfigs:
        eval_val_0 = xcconfigs[eval_key_0]
        used_user_content = True
    elif eval_key_0 in id_configs:
        opt = id_configs[eval_key_0]
        if "DefaultValue" in opt:
            (eval_val_0_used_user_content, eval_val_0) = XCSPEC_EVALS[opt["DefaultValue"]](xcconfigs, id_configs)
            used_user_content = used_user_content or eval_val_0_used_user_content

    eval_val_1 = ""
    eval_key_1 = "INDEX_ENABLE_BUILD_ARENA"
    if eval_key_1 in xcconfigs:
        eval_val_1 = xcconfigs[eval_key_1]
        used_user_content = True
    elif eval_key_1 in id_configs:
        opt = id_configs[eval_key_1]
        if "DefaultValue" in opt:
            (eval_val_1_used_user_content, eval_val_1) = XCSPEC_EVALS[opt["DefaultValue"]](xcconfigs, id_configs)
            used_user_content = used_user_content or eval_val_1_used_user_content

    eval_val_2 = ""
    eval_key_2 = "CLANG_ENABLE_MODULES"
    if eval_key_2 in xcconfigs:
        eval_val_2 = xcconfigs[eval_key_2]
        used_user_content = True
    elif eval_key_2 in id_configs:
        opt = id_configs[eval_key_2]
        if "DefaultValue" in opt:
            (eval_val_2_used_user_content, eval_val_2) = XCSPEC_EVALS[opt["DefaultValue"]](xcconfigs, id_configs)
            used_user_content = used_user_content or eval_val_2_used_user_content

    eval_val_3 = ""
    eval_key_3 = "GCC_PREFIX_HEADER"
    if eval_key_3 in xcconfigs:
        eval_val_3 = xcconfigs[eval_key_3]
        used_user_content = True
    elif eval_key_3 in id_configs:
        opt = id_configs[eval_key_3]
        if "DefaultValue" in opt:
            (eval_val_3_used_user_content, eval_val_3) = XCSPEC_EVALS[opt["DefaultValue"]](xcconfigs, id_configs)
            used_user_content = used_user_content or eval_val_3_used_user_content

    eval_val_4 = ""
    eval_key_4 = "GCC_PRECOMPILE_PREFIX_HEADER"
    if eval_key_4 in xcconfigs:
        eval_val_4 = xcconfigs[eval_key_4]
        used_user_content = True
    elif eval_key_4 in id_configs:
        opt = id_configs[eval_key_4]
        if "DefaultValue" in opt:
            (eval_val_4_used_user_content, eval_val_4) = XCSPEC_EVALS[opt["DefaultValue"]](xcconfigs, id_configs)
            used_user_content = used_user_content or eval_val_4_used_user_content

    return (used_user_content, (eval_val_0 == "YES" and not eval_val_1 == "YES" and (eval_val_2 == "YES" or (eval_val_3 != "" and eval_val_4 == "YES"))))

def _com_apple_compilers_llvm_clang_1_0__CLANG_DEBUG_MODULES__DefaultValue(xcconfigs, id_configs):
    # $(CLANG_ENABLE_MODULE_DEBUGGING)

    used_user_content = False

    eval_val_0 = ""
    eval_key_0 = "CLANG_ENABLE_MODULE_DEBUGGING"
    if eval_key_0 in xcconfigs:
        eval_val_0 = xcconfigs[eval_key_0]
        used_user_content = True
    elif eval_key_0 in id_configs:
        opt = id_configs[eval_key_0]
        if "DefaultValue" in opt:
            (eval_val_0_used_user_content, eval_val_0) = XCSPEC_EVALS[opt["DefaultValue"]](xcconfigs, id_configs)
            used_user_content = used_user_content or eval_val_0_used_user_content

    return (used_user_content, eval_val_0)

def _com_apple_compilers_llvm_clang_1_0__CLANG_MODULE_CACHE_PATH__Condition(xcconfigs, id_configs):
    # $(CLANG_ENABLE_MODULES)

    used_user_content = False

    eval_val_0 = ""
    eval_key_0 = "CLANG_ENABLE_MODULES"
    if eval_key_0 in xcconfigs:
        eval_val_0 = xcconfigs[eval_key_0]
        used_user_content = True
    elif eval_key_0 in id_configs:
        opt = id_configs[eval_key_0]
        if "DefaultValue" in opt:
            (eval_val_0_used_user_content, eval_val_0) = XCSPEC_EVALS[opt["DefaultValue"]](xcconfigs, id_configs)
            used_user_content = used_user_content or eval_val_0_used_user_content

    return (used_user_content, (eval_val_0 == "YES"))

def _com_apple_compilers_llvm_clang_1_0__CLANG_MODULE_CACHE_PATH__DefaultValue(xcconfigs, id_configs):
    # $(MODULE_CACHE_DIR)

    used_user_content = False

    eval_val_0 = ""
    eval_key_0 = "MODULE_CACHE_DIR"
    if eval_key_0 in xcconfigs:
        eval_val_0 = xcconfigs[eval_key_0]
        used_user_content = True
    elif eval_key_0 in id_configs:
        opt = id_configs[eval_key_0]
        if "DefaultValue" in opt:
            (eval_val_0_used_user_content, eval_val_0) = XCSPEC_EVALS[opt["DefaultValue"]](xcconfigs, id_configs)
            used_user_content = used_user_content or eval_val_0_used_user_content

    return (used_user_content, eval_val_0)

def _com_apple_compilers_llvm_clang_1_0__CLANG_MODULE_LSV__Condition(xcconfigs, id_configs):
    # $(CLANG_ENABLE_MODULES)

    used_user_content = False

    eval_val_0 = ""
    eval_key_0 = "CLANG_ENABLE_MODULES"
    if eval_key_0 in xcconfigs:
        eval_val_0 = xcconfigs[eval_key_0]
        used_user_content = True
    elif eval_key_0 in id_configs:
        opt = id_configs[eval_key_0]
        if "DefaultValue" in opt:
            (eval_val_0_used_user_content, eval_val_0) = XCSPEC_EVALS[opt["DefaultValue"]](xcconfigs, id_configs)
            used_user_content = used_user_content or eval_val_0_used_user_content

    return (used_user_content, (eval_val_0 == "YES"))

def _com_apple_compilers_llvm_clang_1_0__CLANG_MODULE_LSV__DefaultValue(xcconfigs, id_configs):
    # NO
    return (False, "NO")

def _com_apple_compilers_llvm_clang_1_0__CLANG_MODULES_AUTOLINK__Condition(xcconfigs, id_configs):
    # $(CLANG_ENABLE_MODULES)

    used_user_content = False

    eval_val_0 = ""
    eval_key_0 = "CLANG_ENABLE_MODULES"
    if eval_key_0 in xcconfigs:
        eval_val_0 = xcconfigs[eval_key_0]
        used_user_content = True
    elif eval_key_0 in id_configs:
        opt = id_configs[eval_key_0]
        if "DefaultValue" in opt:
            (eval_val_0_used_user_content, eval_val_0) = XCSPEC_EVALS[opt["DefaultValue"]](xcconfigs, id_configs)
            used_user_content = used_user_content or eval_val_0_used_user_content

    return (used_user_content, (eval_val_0 == "YES"))

def _com_apple_compilers_llvm_clang_1_0__CLANG_MODULES_AUTOLINK__DefaultValue(xcconfigs, id_configs):
    # YES
    return (False, "YES")

def _com_apple_compilers_llvm_clang_1_0__CLANG_MODULES_DISABLE_PRIVATE_WARNING__Condition(xcconfigs, id_configs):
    # $(CLANG_ENABLE_MODULES)

    used_user_content = False

    eval_val_0 = ""
    eval_key_0 = "CLANG_ENABLE_MODULES"
    if eval_key_0 in xcconfigs:
        eval_val_0 = xcconfigs[eval_key_0]
        used_user_content = True
    elif eval_key_0 in id_configs:
        opt = id_configs[eval_key_0]
        if "DefaultValue" in opt:
            (eval_val_0_used_user_content, eval_val_0) = XCSPEC_EVALS[opt["DefaultValue"]](xcconfigs, id_configs)
            used_user_content = used_user_content or eval_val_0_used_user_content

    return (used_user_content, (eval_val_0 == "YES"))

def _com_apple_compilers_llvm_clang_1_0__CLANG_MODULES_DISABLE_PRIVATE_WARNING__DefaultValue(xcconfigs, id_configs):
    # NO
    return (False, "NO")

def _com_apple_compilers_llvm_clang_1_0__CLANG_MODULES_PRUNE_INTERVAL__Condition(xcconfigs, id_configs):
    # $(CLANG_ENABLE_MODULES)

    used_user_content = False

    eval_val_0 = ""
    eval_key_0 = "CLANG_ENABLE_MODULES"
    if eval_key_0 in xcconfigs:
        eval_val_0 = xcconfigs[eval_key_0]
        used_user_content = True
    elif eval_key_0 in id_configs:
        opt = id_configs[eval_key_0]
        if "DefaultValue" in opt:
            (eval_val_0_used_user_content, eval_val_0) = XCSPEC_EVALS[opt["DefaultValue"]](xcconfigs, id_configs)
            used_user_content = used_user_content or eval_val_0_used_user_content

    return (used_user_content, (eval_val_0 == "YES"))

def _com_apple_compilers_llvm_clang_1_0__CLANG_MODULES_PRUNE_INTERVAL__DefaultValue(xcconfigs, id_configs):
    # 86400
    return (False, "86400")

def _com_apple_compilers_llvm_clang_1_0__CLANG_MODULES_PRUNE_AFTER__Condition(xcconfigs, id_configs):
    # $(CLANG_ENABLE_MODULES)

    used_user_content = False

    eval_val_0 = ""
    eval_key_0 = "CLANG_ENABLE_MODULES"
    if eval_key_0 in xcconfigs:
        eval_val_0 = xcconfigs[eval_key_0]
        used_user_content = True
    elif eval_key_0 in id_configs:
        opt = id_configs[eval_key_0]
        if "DefaultValue" in opt:
            (eval_val_0_used_user_content, eval_val_0) = XCSPEC_EVALS[opt["DefaultValue"]](xcconfigs, id_configs)
            used_user_content = used_user_content or eval_val_0_used_user_content

    return (used_user_content, (eval_val_0 == "YES"))

def _com_apple_compilers_llvm_clang_1_0__CLANG_MODULES_PRUNE_AFTER__DefaultValue(xcconfigs, id_configs):
    # 345600
    return (False, "345600")

def _com_apple_compilers_llvm_clang_1_0__CLANG_MODULES_IGNORE_MACROS__Condition(xcconfigs, id_configs):
    # $(CLANG_ENABLE_MODULES)

    used_user_content = False

    eval_val_0 = ""
    eval_key_0 = "CLANG_ENABLE_MODULES"
    if eval_key_0 in xcconfigs:
        eval_val_0 = xcconfigs[eval_key_0]
        used_user_content = True
    elif eval_key_0 in id_configs:
        opt = id_configs[eval_key_0]
        if "DefaultValue" in opt:
            (eval_val_0_used_user_content, eval_val_0) = XCSPEC_EVALS[opt["DefaultValue"]](xcconfigs, id_configs)
            used_user_content = used_user_content or eval_val_0_used_user_content

    return (used_user_content, (eval_val_0 == "YES"))

def _com_apple_compilers_llvm_clang_1_0__CLANG_MODULES_IGNORE_MACROS__DefaultValue(xcconfigs, id_configs):
    # $(GCC_PREPROCESSOR_DEFINITIONS_NOT_USED_IN_PRECOMPS)

    used_user_content = False

    eval_val_0 = ""
    eval_key_0 = "GCC_PREPROCESSOR_DEFINITIONS_NOT_USED_IN_PRECOMPS"
    if eval_key_0 in xcconfigs:
        eval_val_0 = xcconfigs[eval_key_0]
        used_user_content = True
    elif eval_key_0 in id_configs:
        opt = id_configs[eval_key_0]
        if "DefaultValue" in opt:
            (eval_val_0_used_user_content, eval_val_0) = XCSPEC_EVALS[opt["DefaultValue"]](xcconfigs, id_configs)
            used_user_content = used_user_content or eval_val_0_used_user_content

    return (used_user_content, eval_val_0)

def _com_apple_compilers_llvm_clang_1_0__CLANG_MODULES_VALIDATE_SYSTEM_HEADERS__Condition(xcconfigs, id_configs):
    # $(CLANG_ENABLE_MODULES)

    used_user_content = False

    eval_val_0 = ""
    eval_key_0 = "CLANG_ENABLE_MODULES"
    if eval_key_0 in xcconfigs:
        eval_val_0 = xcconfigs[eval_key_0]
        used_user_content = True
    elif eval_key_0 in id_configs:
        opt = id_configs[eval_key_0]
        if "DefaultValue" in opt:
            (eval_val_0_used_user_content, eval_val_0) = XCSPEC_EVALS[opt["DefaultValue"]](xcconfigs, id_configs)
            used_user_content = used_user_content or eval_val_0_used_user_content

    return (used_user_content, (eval_val_0 == "YES"))

def _com_apple_compilers_llvm_clang_1_0__CLANG_MODULES_VALIDATE_SYSTEM_HEADERS__DefaultValue(xcconfigs, id_configs):
    # NO
    return (False, "NO")

def _com_apple_compilers_llvm_clang_1_0__CLANG_MODULES_BUILD_SESSION_FILE__Condition(xcconfigs, id_configs):
    # $(CLANG_ENABLE_MODULES)

    used_user_content = False

    eval_val_0 = ""
    eval_key_0 = "CLANG_ENABLE_MODULES"
    if eval_key_0 in xcconfigs:
        eval_val_0 = xcconfigs[eval_key_0]
        used_user_content = True
    elif eval_key_0 in id_configs:
        opt = id_configs[eval_key_0]
        if "DefaultValue" in opt:
            (eval_val_0_used_user_content, eval_val_0) = XCSPEC_EVALS[opt["DefaultValue"]](xcconfigs, id_configs)
            used_user_content = used_user_content or eval_val_0_used_user_content

    return (used_user_content, (eval_val_0 == "YES"))

def _com_apple_compilers_llvm_clang_1_0__CLANG_MODULES_BUILD_SESSION_FILE__DefaultValue(xcconfigs, id_configs):
    #
    return (False, "")

def _com_apple_compilers_llvm_clang_1_0__CLANG_ALLOW_NON_MODULAR_INCLUDES_IN_FRAMEWORK_MODULES__Condition(xcconfigs, id_configs):
    # $(CLANG_ENABLE_MODULES)

    used_user_content = False

    eval_val_0 = ""
    eval_key_0 = "CLANG_ENABLE_MODULES"
    if eval_key_0 in xcconfigs:
        eval_val_0 = xcconfigs[eval_key_0]
        used_user_content = True
    elif eval_key_0 in id_configs:
        opt = id_configs[eval_key_0]
        if "DefaultValue" in opt:
            (eval_val_0_used_user_content, eval_val_0) = XCSPEC_EVALS[opt["DefaultValue"]](xcconfigs, id_configs)
            used_user_content = used_user_content or eval_val_0_used_user_content

    return (used_user_content, (eval_val_0 == "YES"))

def _com_apple_compilers_llvm_clang_1_0__CLANG_ALLOW_NON_MODULAR_INCLUDES_IN_FRAMEWORK_MODULES__DefaultValue(xcconfigs, id_configs):
    # NO
    return (False, "NO")

def _com_apple_compilers_llvm_clang_1_0__CLANG_ENABLE_MODULE_IMPLEMENTATION_OF__Condition(xcconfigs, id_configs):
    # $(CLANG_ENABLE_MODULES) && $(DEFINES_MODULE)

    used_user_content = False

    eval_val_0 = ""
    eval_key_0 = "CLANG_ENABLE_MODULES"
    if eval_key_0 in xcconfigs:
        eval_val_0 = xcconfigs[eval_key_0]
        used_user_content = True
    elif eval_key_0 in id_configs:
        opt = id_configs[eval_key_0]
        if "DefaultValue" in opt:
            (eval_val_0_used_user_content, eval_val_0) = XCSPEC_EVALS[opt["DefaultValue"]](xcconfigs, id_configs)
            used_user_content = used_user_content or eval_val_0_used_user_content

    eval_val_1 = ""
    eval_key_1 = "DEFINES_MODULE"
    if eval_key_1 in xcconfigs:
        eval_val_1 = xcconfigs[eval_key_1]
        used_user_content = True
    elif eval_key_1 in id_configs:
        opt = id_configs[eval_key_1]
        if "DefaultValue" in opt:
            (eval_val_1_used_user_content, eval_val_1) = XCSPEC_EVALS[opt["DefaultValue"]](xcconfigs, id_configs)
            used_user_content = used_user_content or eval_val_1_used_user_content

    return (used_user_content, (eval_val_0 == "YES" and eval_val_1 == "YES"))

def _com_apple_compilers_llvm_clang_1_0__CLANG_ENABLE_MODULE_IMPLEMENTATION_OF__DefaultValue(xcconfigs, id_configs):
    # YES
    return (False, "YES")

def _com_apple_compilers_llvm_clang_1_0__CLANG_ENABLE_BOUNDS_ATTRIBUTES__DefaultValue(xcconfigs, id_configs):
    # NO
    return (False, "NO")

def _com_apple_compilers_llvm_clang_1_0__CLANG_ENABLE_BOUNDS_SAFETY__DefaultValue(xcconfigs, id_configs):
    # NO
    return (False, "NO")

def _com_apple_compilers_llvm_clang_1_0__CLANG_ENABLE_APP_EXTENSION__DefaultValue(xcconfigs, id_configs):
    # $(APPLICATION_EXTENSION_API_ONLY)

    used_user_content = False

    eval_val_0 = ""
    eval_key_0 = "APPLICATION_EXTENSION_API_ONLY"
    if eval_key_0 in xcconfigs:
        eval_val_0 = xcconfigs[eval_key_0]
        used_user_content = True
    elif eval_key_0 in id_configs:
        opt = id_configs[eval_key_0]
        if "DefaultValue" in opt:
            (eval_val_0_used_user_content, eval_val_0) = XCSPEC_EVALS[opt["DefaultValue"]](xcconfigs, id_configs)
            used_user_content = used_user_content or eval_val_0_used_user_content

    return (used_user_content, eval_val_0)

def _com_apple_compilers_llvm_clang_1_0__GCC_CHAR_IS_UNSIGNED_CHAR__DefaultValue(xcconfigs, id_configs):
    # NO
    return (False, "NO")

def _com_apple_compilers_llvm_clang_1_0__GCC_ENABLE_ASM_KEYWORD__DefaultValue(xcconfigs, id_configs):
    # YES
    return (False, "YES")

def _com_apple_compilers_llvm_clang_1_0__GCC_ENABLE_BUILTIN_FUNCTIONS__DefaultValue(xcconfigs, id_configs):
    # YES
    return (False, "YES")

def _com_apple_compilers_llvm_clang_1_0__GCC_ENABLE_TRIGRAPHS__DefaultValue(xcconfigs, id_configs):
    # NO
    return (False, "NO")

def _com_apple_compilers_llvm_clang_1_0__GCC_ENABLE_CPP_EXCEPTIONS__DefaultValue(xcconfigs, id_configs):
    # YES
    return (False, "YES")

def _com_apple_compilers_llvm_clang_1_0__GCC_ENABLE_CPP_RTTI__DefaultValue(xcconfigs, id_configs):
    # YES
    return (False, "YES")

def _com_apple_compilers_llvm_clang_1_0__GCC_ENABLE_PASCAL_STRINGS__DefaultValue(xcconfigs, id_configs):
    # YES
    return (False, "YES")

def _com_apple_compilers_llvm_clang_1_0__GCC_SHORT_ENUMS__DefaultValue(xcconfigs, id_configs):
    # NO
    return (False, "NO")

def _com_apple_compilers_llvm_clang_1_0__GCC_LINK_WITH_DYNAMIC_LIBRARIES__DefaultValue(xcconfigs, id_configs):
    # YES
    return (False, "YES")

def _com_apple_compilers_llvm_clang_1_0__GCC_ENABLE_FLOATING_POINT_LIBRARY_CALLS__DefaultValue(xcconfigs, id_configs):
    # NO
    return (False, "NO")

def _com_apple_compilers_llvm_clang_1_0__CLANG_ENABLE_CPP_STATIC_DESTRUCTORS__DefaultValue(xcconfigs, id_configs):
    # YES
    return (False, "YES")

def _com_apple_compilers_llvm_clang_1_0__GCC_PREFIX_HEADER__DefaultValue(xcconfigs, id_configs):
    #
    return (False, "")

def _com_apple_compilers_llvm_clang_1_0__GCC_PRECOMPILE_PREFIX_HEADER__DefaultValue(xcconfigs, id_configs):
    # NO
    return (False, "NO")

def _com_apple_compilers_llvm_clang_1_0__GCC_INCREASE_PRECOMPILED_HEADER_SHARING__DefaultValue(xcconfigs, id_configs):
    # NO
    return (False, "NO")

def _com_apple_compilers_llvm_clang_1_0__GCC_GENERATE_DEBUGGING_SYMBOLS__DefaultValue(xcconfigs, id_configs):
    # YES
    return (False, "YES")

def _com_apple_compilers_llvm_clang_1_0__GCC_OPTIMIZATION_LEVEL__DefaultValue(xcconfigs, id_configs):
    # s
    return (False, "s")

def _com_apple_compilers_llvm_clang_1_0__LLVM_OPTIMIZATION_LEVEL_VAL_0__DefaultValue(xcconfigs, id_configs):
    # NO
    return (False, "NO")

def _com_apple_compilers_llvm_clang_1_0__LLVM_OPTIMIZATION_LEVEL_VAL_1__DefaultValue(xcconfigs, id_configs):
    # NO
    return (False, "NO")

def _com_apple_compilers_llvm_clang_1_0__LLVM_OPTIMIZATION_LEVEL_VAL_2__DefaultValue(xcconfigs, id_configs):
    # NO
    return (False, "NO")

def _com_apple_compilers_llvm_clang_1_0__LLVM_OPTIMIZATION_LEVEL_VAL_3__DefaultValue(xcconfigs, id_configs):
    # NO
    return (False, "NO")

def _com_apple_compilers_llvm_clang_1_0__LLVM_OPTIMIZATION_LEVEL_VAL_s__DefaultValue(xcconfigs, id_configs):
    # NO
    return (False, "NO")

def _com_apple_compilers_llvm_clang_1_0__LLVM_OPTIMIZATION_LEVEL_VAL_fast__DefaultValue(xcconfigs, id_configs):
    # YES
    return (False, "YES")

def _com_apple_compilers_llvm_clang_1_0__LLVM_OPTIMIZATION_LEVEL_VAL_z__DefaultValue(xcconfigs, id_configs):
    # NO
    return (False, "NO")

def _com_apple_compilers_llvm_clang_1_0__LLVM_IMPLICIT_AGGRESSIVE_OPTIMIZATIONS__DefaultValue(xcconfigs, id_configs):
    # $(LLVM_OPTIMIZATION_LEVEL_VAL_$(GCC_OPTIMIZATION_LEVEL))

    used_user_content = False

    eval_val_0 = ""
    eval_key_0 = "GCC_OPTIMIZATION_LEVEL"
    if eval_key_0 in xcconfigs:
        eval_val_0 = xcconfigs[eval_key_0]
        used_user_content = True
    elif eval_key_0 in id_configs:
        opt = id_configs[eval_key_0]
        if "DefaultValue" in opt:
            (eval_val_0_used_user_content, eval_val_0) = XCSPEC_EVALS[opt["DefaultValue"]](xcconfigs, id_configs)
            used_user_content = used_user_content or eval_val_0_used_user_content

    eval_val_1 = ""
    eval_key_1 = "LLVM_OPTIMIZATION_LEVEL_VAL_{eval_val_0}".format(eval_val_0 = eval_val_0)
    if eval_key_1 in xcconfigs:
        eval_val_1 = xcconfigs[eval_key_1]
        used_user_content = True
    elif eval_key_1 in id_configs:
        opt = id_configs[eval_key_1]
        if "DefaultValue" in opt:
            (eval_val_1_used_user_content, eval_val_1) = XCSPEC_EVALS[opt["DefaultValue"]](xcconfigs, id_configs)
            used_user_content = used_user_content or eval_val_1_used_user_content

    return (used_user_content, eval_val_1)

def _com_apple_compilers_llvm_clang_1_0__LLVM_LTO__DefaultValue(xcconfigs, id_configs):
    # NO
    return (False, "NO")

def _com_apple_compilers_llvm_clang_1_0__GCC_NO_COMMON_BLOCKS__DefaultValue(xcconfigs, id_configs):
    # NO
    return (False, "NO")

def _com_apple_compilers_llvm_clang_1_0__GCC_REUSE_STRINGS__DefaultValue(xcconfigs, id_configs):
    # YES
    return (False, "YES")

def _com_apple_compilers_llvm_clang_1_0__GCC_DYNAMIC_NO_PIC__DefaultValue(xcconfigs, id_configs):
    # NO
    return (False, "NO")

def _com_apple_compilers_llvm_clang_1_0__GCC_ENABLE_KERNEL_DEVELOPMENT__DefaultValue(xcconfigs, id_configs):
    # NO
    return (False, "NO")

def _com_apple_compilers_llvm_clang_1_0__GCC_TREAT_WARNINGS_AS_ERRORS__DefaultValue(xcconfigs, id_configs):
    # NO
    return (False, "NO")

def _com_apple_compilers_llvm_clang_1_0__GCC_TREAT_IMPLICIT_FUNCTION_DECLARATIONS_AS_ERRORS__DefaultValue(xcconfigs, id_configs):
    # NO
    return (False, "NO")

def _com_apple_compilers_llvm_clang_1_0__GCC_TREAT_INCOMPATIBLE_POINTER_TYPE_WARNINGS_AS_ERRORS__DefaultValue(xcconfigs, id_configs):
    # NO
    return (False, "NO")

def _com_apple_compilers_llvm_clang_1_0__GCC_WARN_ABOUT_MISSING_FIELD_INITIALIZERS__DefaultValue(xcconfigs, id_configs):
    # NO
    return (False, "NO")

def _com_apple_compilers_llvm_clang_1_0__GCC_WARN_ABOUT_MISSING_PROTOTYPES__DefaultValue(xcconfigs, id_configs):
    # NO
    return (False, "NO")

def _com_apple_compilers_llvm_clang_1_0__GCC_WARN_ABOUT_RETURN_TYPE__DefaultValue(xcconfigs, id_configs):
    # NO
    return (False, "NO")

def _com_apple_compilers_llvm_clang_1_0__CLANG_WARN_DOCUMENTATION_COMMENTS__DefaultValue(xcconfigs, id_configs):
    # NO
    return (False, "NO")

def _com_apple_compilers_llvm_clang_1_0__CLANG_WARN_UNREACHABLE_CODE__DefaultValue(xcconfigs, id_configs):
    # NO
    return (False, "NO")

def _com_apple_compilers_llvm_clang_1_0__CLANG_WARN_QUOTED_INCLUDE_IN_FRAMEWORK_HEADER__DefaultValue(xcconfigs, id_configs):
    # NO
    return (False, "NO")

def _com_apple_compilers_llvm_clang_1_0__CLANG_WARN_FRAMEWORK_INCLUDE_PRIVATE_FROM_PUBLIC__DefaultValue(xcconfigs, id_configs):
    # NO
    return (False, "NO")

def _com_apple_compilers_llvm_clang_1_0__CLANG_WARN_NULLABLE_TO_NONNULL_CONVERSION__DefaultValue(xcconfigs, id_configs):
    # NO
    return (False, "NO")

def _com_apple_compilers_llvm_clang_1_0__CLANG_WARN_OBJC_IMPLICIT_ATOMIC_PROPERTIES__DefaultValue(xcconfigs, id_configs):
    # NO
    return (False, "NO")

def _com_apple_compilers_llvm_clang_1_0__CLANG_WARN_DIRECT_OBJC_ISA_USAGE__DefaultValue(xcconfigs, id_configs):
    # YES
    return (False, "YES")

def _com_apple_compilers_llvm_clang_1_0__CLANG_WARN_OBJC_INTERFACE_IVARS__DefaultValue(xcconfigs, id_configs):
    # NO
    return (False, "NO")

def _com_apple_compilers_llvm_clang_1_0__CLANG_WARN_OBJC_MISSING_PROPERTY_SYNTHESIS__DefaultValue(xcconfigs, id_configs):
    # NO
    return (False, "NO")

def _com_apple_compilers_llvm_clang_1_0__CLANG_WARN_OBJC_ROOT_CLASS__DefaultValue(xcconfigs, id_configs):
    # YES
    return (False, "YES")

def _com_apple_compilers_llvm_clang_1_0__CLANG_WARN_OBJC_REPEATED_USE_OF_WEAK__DefaultValue(xcconfigs, id_configs):
    # NO
    return (False, "NO")

def _com_apple_compilers_llvm_clang_1_0__CLANG_WARN_OBJC_EXPLICIT_OWNERSHIP_TYPE__DefaultValue(xcconfigs, id_configs):
    # NO
    return (False, "NO")

def _com_apple_compilers_llvm_clang_1_0__CLANG_WARN_OBJC_IMPLICIT_RETAIN_SELF__DefaultValue(xcconfigs, id_configs):
    # NO
    return (False, "NO")

def _com_apple_compilers_llvm_clang_1_0__GCC_WARN_NON_VIRTUAL_DESTRUCTOR__DefaultValue(xcconfigs, id_configs):
    # NO
    return (False, "NO")

def _com_apple_compilers_llvm_clang_1_0__GCC_WARN_HIDDEN_VIRTUAL_FUNCTIONS__DefaultValue(xcconfigs, id_configs):
    # NO
    return (False, "NO")

def _com_apple_compilers_llvm_clang_1_0__CLANG_WARN__EXIT_TIME_DESTRUCTORS__DefaultValue(xcconfigs, id_configs):
    # NO
    return (False, "NO")

def _com_apple_compilers_llvm_clang_1_0__CLANG_WARN__ARC_BRIDGE_CAST_NONARC__DefaultValue(xcconfigs, id_configs):
    # YES
    return (False, "YES")

def _com_apple_compilers_llvm_clang_1_0__CLANG_WARN__DUPLICATE_METHOD_MATCH__DefaultValue(xcconfigs, id_configs):
    # NO
    return (False, "NO")

def _com_apple_compilers_llvm_clang_1_0__GCC_WARN_TYPECHECK_CALLS_TO_PRINTF__DefaultValue(xcconfigs, id_configs):
    # YES
    return (False, "YES")

def _com_apple_compilers_llvm_clang_1_0__GCC_WARN_INITIALIZER_NOT_FULLY_BRACKETED__DefaultValue(xcconfigs, id_configs):
    # NO
    return (False, "NO")

def _com_apple_compilers_llvm_clang_1_0__GCC_WARN_MISSING_PARENTHESES__DefaultValue(xcconfigs, id_configs):
    # YES
    return (False, "YES")

def _com_apple_compilers_llvm_clang_1_0__GCC_WARN_CHECK_SWITCH_STATEMENTS__DefaultValue(xcconfigs, id_configs):
    # YES
    return (False, "YES")

def _com_apple_compilers_llvm_clang_1_0__CLANG_WARN_COMPLETION_HANDLER_MISUSE__DefaultValue(xcconfigs, id_configs):
    # NO
    return (False, "NO")

def _com_apple_compilers_llvm_clang_1_0__GCC_WARN_UNUSED_FUNCTION__DefaultValue(xcconfigs, id_configs):
    # NO
    return (False, "NO")

def _com_apple_compilers_llvm_clang_1_0__GCC_WARN_UNUSED_LABEL__DefaultValue(xcconfigs, id_configs):
    # NO
    return (False, "NO")

def _com_apple_compilers_llvm_clang_1_0__CLANG_WARN_EMPTY_BODY__DefaultValue(xcconfigs, id_configs):
    # NO
    return (False, "NO")

def _com_apple_compilers_llvm_clang_1_0__GCC_WARN_UNINITIALIZED_AUTOS__DefaultValue(xcconfigs, id_configs):
    # NO
    return (False, "NO")

def _com_apple_compilers_llvm_clang_1_0__GCC_WARN_UNKNOWN_PRAGMAS__DefaultValue(xcconfigs, id_configs):
    # NO
    return (False, "NO")

def _com_apple_compilers_llvm_clang_1_0__GCC_WARN_INHIBIT_ALL_WARNINGS__DefaultValue(xcconfigs, id_configs):
    # $(SUPPRESS_WARNINGS)

    used_user_content = False

    eval_val_0 = ""
    eval_key_0 = "SUPPRESS_WARNINGS"
    if eval_key_0 in xcconfigs:
        eval_val_0 = xcconfigs[eval_key_0]
        used_user_content = True
    elif eval_key_0 in id_configs:
        opt = id_configs[eval_key_0]
        if "DefaultValue" in opt:
            (eval_val_0_used_user_content, eval_val_0) = XCSPEC_EVALS[opt["DefaultValue"]](xcconfigs, id_configs)
            used_user_content = used_user_content or eval_val_0_used_user_content

    return (used_user_content, eval_val_0)

def _com_apple_compilers_llvm_clang_1_0__GCC_WARN_PEDANTIC__DefaultValue(xcconfigs, id_configs):
    # NO
    return (False, "NO")

def _com_apple_compilers_llvm_clang_1_0__GCC_WARN_SHADOW__DefaultValue(xcconfigs, id_configs):
    # NO
    return (False, "NO")

def _com_apple_compilers_llvm_clang_1_0__GCC_WARN_FOUR_CHARACTER_CONSTANTS__DefaultValue(xcconfigs, id_configs):
    # NO
    return (False, "NO")

def _com_apple_compilers_llvm_clang_1_0__CLANG_WARN_SUSPICIOUS_IMPLICIT_CONVERSION__DefaultValue(xcconfigs, id_configs):
    # NO
    return (False, "NO")

def _com_apple_compilers_llvm_clang_1_0__CLANG_WARN_CONSTANT_CONVERSION__DefaultValue(xcconfigs, id_configs):
    # $(CLANG_WARN_SUSPICIOUS_IMPLICIT_CONVERSION)

    used_user_content = False

    eval_val_0 = ""
    eval_key_0 = "CLANG_WARN_SUSPICIOUS_IMPLICIT_CONVERSION"
    if eval_key_0 in xcconfigs:
        eval_val_0 = xcconfigs[eval_key_0]
        used_user_content = True
    elif eval_key_0 in id_configs:
        opt = id_configs[eval_key_0]
        if "DefaultValue" in opt:
            (eval_val_0_used_user_content, eval_val_0) = XCSPEC_EVALS[opt["DefaultValue"]](xcconfigs, id_configs)
            used_user_content = used_user_content or eval_val_0_used_user_content

    return (used_user_content, eval_val_0)

def _com_apple_compilers_llvm_clang_1_0__CLANG_WARN_INT_CONVERSION__DefaultValue(xcconfigs, id_configs):
    # $(CLANG_WARN_SUSPICIOUS_IMPLICIT_CONVERSION)

    used_user_content = False

    eval_val_0 = ""
    eval_key_0 = "CLANG_WARN_SUSPICIOUS_IMPLICIT_CONVERSION"
    if eval_key_0 in xcconfigs:
        eval_val_0 = xcconfigs[eval_key_0]
        used_user_content = True
    elif eval_key_0 in id_configs:
        opt = id_configs[eval_key_0]
        if "DefaultValue" in opt:
            (eval_val_0_used_user_content, eval_val_0) = XCSPEC_EVALS[opt["DefaultValue"]](xcconfigs, id_configs)
            used_user_content = used_user_content or eval_val_0_used_user_content

    return (used_user_content, eval_val_0)

def _com_apple_compilers_llvm_clang_1_0__CLANG_WARN_BOOL_CONVERSION__DefaultValue(xcconfigs, id_configs):
    # $(CLANG_WARN_SUSPICIOUS_IMPLICIT_CONVERSION)

    used_user_content = False

    eval_val_0 = ""
    eval_key_0 = "CLANG_WARN_SUSPICIOUS_IMPLICIT_CONVERSION"
    if eval_key_0 in xcconfigs:
        eval_val_0 = xcconfigs[eval_key_0]
        used_user_content = True
    elif eval_key_0 in id_configs:
        opt = id_configs[eval_key_0]
        if "DefaultValue" in opt:
            (eval_val_0_used_user_content, eval_val_0) = XCSPEC_EVALS[opt["DefaultValue"]](xcconfigs, id_configs)
            used_user_content = used_user_content or eval_val_0_used_user_content

    return (used_user_content, eval_val_0)

def _com_apple_compilers_llvm_clang_1_0__CLANG_WARN_ENUM_CONVERSION__DefaultValue(xcconfigs, id_configs):
    # $(CLANG_WARN_SUSPICIOUS_IMPLICIT_CONVERSION)

    used_user_content = False

    eval_val_0 = ""
    eval_key_0 = "CLANG_WARN_SUSPICIOUS_IMPLICIT_CONVERSION"
    if eval_key_0 in xcconfigs:
        eval_val_0 = xcconfigs[eval_key_0]
        used_user_content = True
    elif eval_key_0 in id_configs:
        opt = id_configs[eval_key_0]
        if "DefaultValue" in opt:
            (eval_val_0_used_user_content, eval_val_0) = XCSPEC_EVALS[opt["DefaultValue"]](xcconfigs, id_configs)
            used_user_content = used_user_content or eval_val_0_used_user_content

    return (used_user_content, eval_val_0)

def _com_apple_compilers_llvm_clang_1_0__CLANG_WARN_FLOAT_CONVERSION__DefaultValue(xcconfigs, id_configs):
    # $(CLANG_WARN_SUSPICIOUS_IMPLICIT_CONVERSION)

    used_user_content = False

    eval_val_0 = ""
    eval_key_0 = "CLANG_WARN_SUSPICIOUS_IMPLICIT_CONVERSION"
    if eval_key_0 in xcconfigs:
        eval_val_0 = xcconfigs[eval_key_0]
        used_user_content = True
    elif eval_key_0 in id_configs:
        opt = id_configs[eval_key_0]
        if "DefaultValue" in opt:
            (eval_val_0_used_user_content, eval_val_0) = XCSPEC_EVALS[opt["DefaultValue"]](xcconfigs, id_configs)
            used_user_content = used_user_content or eval_val_0_used_user_content

    return (used_user_content, eval_val_0)

def _com_apple_compilers_llvm_clang_1_0__CLANG_WARN_NON_LITERAL_NULL_CONVERSION__DefaultValue(xcconfigs, id_configs):
    # $(CLANG_WARN_SUSPICIOUS_IMPLICIT_CONVERSION)

    used_user_content = False

    eval_val_0 = ""
    eval_key_0 = "CLANG_WARN_SUSPICIOUS_IMPLICIT_CONVERSION"
    if eval_key_0 in xcconfigs:
        eval_val_0 = xcconfigs[eval_key_0]
        used_user_content = True
    elif eval_key_0 in id_configs:
        opt = id_configs[eval_key_0]
        if "DefaultValue" in opt:
            (eval_val_0_used_user_content, eval_val_0) = XCSPEC_EVALS[opt["DefaultValue"]](xcconfigs, id_configs)
            used_user_content = used_user_content or eval_val_0_used_user_content

    return (used_user_content, eval_val_0)

def _com_apple_compilers_llvm_clang_1_0__CLANG_WARN_OBJC_LITERAL_CONVERSION__DefaultValue(xcconfigs, id_configs):
    # $(CLANG_WARN_SUSPICIOUS_IMPLICIT_CONVERSION)

    used_user_content = False

    eval_val_0 = ""
    eval_key_0 = "CLANG_WARN_SUSPICIOUS_IMPLICIT_CONVERSION"
    if eval_key_0 in xcconfigs:
        eval_val_0 = xcconfigs[eval_key_0]
        used_user_content = True
    elif eval_key_0 in id_configs:
        opt = id_configs[eval_key_0]
        if "DefaultValue" in opt:
            (eval_val_0_used_user_content, eval_val_0) = XCSPEC_EVALS[opt["DefaultValue"]](xcconfigs, id_configs)
            used_user_content = used_user_content or eval_val_0_used_user_content

    return (used_user_content, eval_val_0)

def _com_apple_compilers_llvm_clang_1_0__CLANG_WARN_MISSING_NOESCAPE__DefaultValue(xcconfigs, id_configs):
    # YES
    return (False, "YES")

def _com_apple_compilers_llvm_clang_1_0__CLANG_WARN_PRAGMA_PACK__DefaultValue(xcconfigs, id_configs):
    # YES
    return (False, "YES")

def _com_apple_compilers_llvm_clang_1_0__CLANG_WARN_PRIVATE_MODULE__DefaultValue(xcconfigs, id_configs):
    # YES
    return (False, "YES")

def _com_apple_compilers_llvm_clang_1_0__CLANG_WARN_VEXING_PARSE__DefaultValue(xcconfigs, id_configs):
    # YES
    return (False, "YES")

def _com_apple_compilers_llvm_clang_1_0__CLANG_WARN_DELETE_NON_VIRTUAL_DTOR__DefaultValue(xcconfigs, id_configs):
    # YES
    return (False, "YES")

def _com_apple_compilers_llvm_clang_1_0__CLANG_WARN_ASSIGN_ENUM__DefaultValue(xcconfigs, id_configs):
    # NO
    return (False, "NO")

def _com_apple_compilers_llvm_clang_1_0__GCC_WARN_SIGN_COMPARE__DefaultValue(xcconfigs, id_configs):
    # NO
    return (False, "NO")

def _com_apple_compilers_llvm_clang_1_0__GCC_WARN_MULTIPLE_DEFINITION_TYPES_FOR_SELECTOR__DefaultValue(xcconfigs, id_configs):
    # NO
    return (False, "NO")

def _com_apple_compilers_llvm_clang_1_0__GCC_WARN_STRICT_SELECTOR_MATCH__DefaultValue(xcconfigs, id_configs):
    # NO
    return (False, "NO")

def _com_apple_compilers_llvm_clang_1_0__GCC_WARN_UNDECLARED_SELECTOR__DefaultValue(xcconfigs, id_configs):
    # NO
    return (False, "NO")

def _com_apple_compilers_llvm_clang_1_0__CLANG_WARN_DEPRECATED_OBJC_IMPLEMENTATIONS__DefaultValue(xcconfigs, id_configs):
    # NO
    return (False, "NO")

def _com_apple_compilers_llvm_clang_1_0__CLANG_WARN_CXX0X_EXTENSIONS__DefaultValue(xcconfigs, id_configs):
    # NO
    return (False, "NO")

def _com_apple_compilers_llvm_clang_1_0__CLANG_WARN_ATOMIC_IMPLICIT_SEQ_CST__DefaultValue(xcconfigs, id_configs):
    # NO
    return (False, "NO")

def _com_apple_compilers_llvm_clang_1_0__CLANG_WARN_IMPLICIT_FALLTHROUGH__DefaultValue(xcconfigs, id_configs):
    # NO
    return (False, "NO")

def _com_apple_compilers_llvm_clang_1_0__CLANG_TRIVIAL_AUTO_VAR_INIT__DefaultValue(xcconfigs, id_configs):
    # default
    return (False, "default")

def _com_apple_compilers_llvm_clang_1_0__WARNING_CFLAGS__DefaultValue(xcconfigs, id_configs):
    #
    return (False, "")

def _com_apple_compilers_llvm_clang_1_0__GCC_PREPROCESSOR_DEFINITIONS__DefaultValue(xcconfigs, id_configs):
    #
    return (False, "")

def _com_apple_compilers_llvm_clang_1_0__GCC_PRODUCT_TYPE_PREPROCESSOR_DEFINITIONS__DefaultValue(xcconfigs, id_configs):
    #
    return (False, "")

def _com_apple_compilers_llvm_clang_1_0__GCC_PREPROCESSOR_DEFINITIONS_NOT_USED_IN_PRECOMPS__DefaultValue(xcconfigs, id_configs):
    #
    return (False, "")

def _com_apple_compilers_llvm_clang_1_0__ENABLE_NS_ASSERTIONS__DefaultValue(xcconfigs, id_configs):
    # YES
    return (False, "YES")

def _com_apple_compilers_llvm_clang_1_0__ENABLE_STRICT_OBJC_MSGSEND__DefaultValue(xcconfigs, id_configs):
    # NO
    return (False, "NO")

def _com_apple_compilers_llvm_clang_1_0__USE_HEADERMAP__DefaultValue(xcconfigs, id_configs):
    # YES
    return (False, "YES")

def _com_apple_compilers_llvm_clang_1_0__HEADERMAP_FILE_FORMAT__DefaultValue(xcconfigs, id_configs):
    # traditional
    return (False, "traditional")

def _com_apple_compilers_llvm_clang_1_0__CPP_HEADERMAP_FILE__DefaultValue(xcconfigs, id_configs):
    # $(TEMP_DIR)/$(PRODUCT_NAME).hmap

    used_user_content = False

    eval_val_0 = ""
    eval_key_0 = "TEMP_DIR"
    if eval_key_0 in xcconfigs:
        eval_val_0 = xcconfigs[eval_key_0]
        used_user_content = True
    elif eval_key_0 in id_configs:
        opt = id_configs[eval_key_0]
        if "DefaultValue" in opt:
            (eval_val_0_used_user_content, eval_val_0) = XCSPEC_EVALS[opt["DefaultValue"]](xcconfigs, id_configs)
            used_user_content = used_user_content or eval_val_0_used_user_content

    eval_val_1 = ""
    eval_key_1 = "PRODUCT_NAME"
    if eval_key_1 in xcconfigs:
        eval_val_1 = xcconfigs[eval_key_1]
        used_user_content = True
    elif eval_key_1 in id_configs:
        opt = id_configs[eval_key_1]
        if "DefaultValue" in opt:
            (eval_val_1_used_user_content, eval_val_1) = XCSPEC_EVALS[opt["DefaultValue"]](xcconfigs, id_configs)
            used_user_content = used_user_content or eval_val_1_used_user_content

    return (used_user_content, "{eval_val_0}/{eval_val_1}.hmap".format(eval_val_0 = eval_val_0, eval_val_1 = eval_val_1))

def _com_apple_compilers_llvm_clang_1_0__CPP_HEADERMAP_FILE_FOR_GENERATED_FILES__DefaultValue(xcconfigs, id_configs):
    # $(TEMP_DIR)/$(PRODUCT_NAME)-generated-files.hmap

    used_user_content = False

    eval_val_0 = ""
    eval_key_0 = "TEMP_DIR"
    if eval_key_0 in xcconfigs:
        eval_val_0 = xcconfigs[eval_key_0]
        used_user_content = True
    elif eval_key_0 in id_configs:
        opt = id_configs[eval_key_0]
        if "DefaultValue" in opt:
            (eval_val_0_used_user_content, eval_val_0) = XCSPEC_EVALS[opt["DefaultValue"]](xcconfigs, id_configs)
            used_user_content = used_user_content or eval_val_0_used_user_content

    eval_val_1 = ""
    eval_key_1 = "PRODUCT_NAME"
    if eval_key_1 in xcconfigs:
        eval_val_1 = xcconfigs[eval_key_1]
        used_user_content = True
    elif eval_key_1 in id_configs:
        opt = id_configs[eval_key_1]
        if "DefaultValue" in opt:
            (eval_val_1_used_user_content, eval_val_1) = XCSPEC_EVALS[opt["DefaultValue"]](xcconfigs, id_configs)
            used_user_content = used_user_content or eval_val_1_used_user_content

    return (used_user_content, "{eval_val_0}/{eval_val_1}-generated-files.hmap".format(eval_val_0 = eval_val_0, eval_val_1 = eval_val_1))

def _com_apple_compilers_llvm_clang_1_0__CPP_HEADERMAP_FILE_FOR_OWN_TARGET_HEADERS__DefaultValue(xcconfigs, id_configs):
    # $(TEMP_DIR)/$(PRODUCT_NAME)-own-target-headers.hmap

    used_user_content = False

    eval_val_0 = ""
    eval_key_0 = "TEMP_DIR"
    if eval_key_0 in xcconfigs:
        eval_val_0 = xcconfigs[eval_key_0]
        used_user_content = True
    elif eval_key_0 in id_configs:
        opt = id_configs[eval_key_0]
        if "DefaultValue" in opt:
            (eval_val_0_used_user_content, eval_val_0) = XCSPEC_EVALS[opt["DefaultValue"]](xcconfigs, id_configs)
            used_user_content = used_user_content or eval_val_0_used_user_content

    eval_val_1 = ""
    eval_key_1 = "PRODUCT_NAME"
    if eval_key_1 in xcconfigs:
        eval_val_1 = xcconfigs[eval_key_1]
        used_user_content = True
    elif eval_key_1 in id_configs:
        opt = id_configs[eval_key_1]
        if "DefaultValue" in opt:
            (eval_val_1_used_user_content, eval_val_1) = XCSPEC_EVALS[opt["DefaultValue"]](xcconfigs, id_configs)
            used_user_content = used_user_content or eval_val_1_used_user_content

    return (used_user_content, "{eval_val_0}/{eval_val_1}-own-target-headers.hmap".format(eval_val_0 = eval_val_0, eval_val_1 = eval_val_1))

def _com_apple_compilers_llvm_clang_1_0__CPP_HEADERMAP_FILE_FOR_ALL_TARGET_HEADERS__DefaultValue(xcconfigs, id_configs):
    # $(TEMP_DIR)/$(PRODUCT_NAME)-all-target-headers.hmap

    used_user_content = False

    eval_val_0 = ""
    eval_key_0 = "TEMP_DIR"
    if eval_key_0 in xcconfigs:
        eval_val_0 = xcconfigs[eval_key_0]
        used_user_content = True
    elif eval_key_0 in id_configs:
        opt = id_configs[eval_key_0]
        if "DefaultValue" in opt:
            (eval_val_0_used_user_content, eval_val_0) = XCSPEC_EVALS[opt["DefaultValue"]](xcconfigs, id_configs)
            used_user_content = used_user_content or eval_val_0_used_user_content

    eval_val_1 = ""
    eval_key_1 = "PRODUCT_NAME"
    if eval_key_1 in xcconfigs:
        eval_val_1 = xcconfigs[eval_key_1]
        used_user_content = True
    elif eval_key_1 in id_configs:
        opt = id_configs[eval_key_1]
        if "DefaultValue" in opt:
            (eval_val_1_used_user_content, eval_val_1) = XCSPEC_EVALS[opt["DefaultValue"]](xcconfigs, id_configs)
            used_user_content = used_user_content or eval_val_1_used_user_content

    return (used_user_content, "{eval_val_0}/{eval_val_1}-all-target-headers.hmap".format(eval_val_0 = eval_val_0, eval_val_1 = eval_val_1))

def _com_apple_compilers_llvm_clang_1_0__CPP_HEADERMAP_FILE_FOR_ALL_NON_FRAMEWORK_TARGET_HEADERS__DefaultValue(xcconfigs, id_configs):
    # $(TEMP_DIR)/$(PRODUCT_NAME)-all-non-framework-target-headers.hmap

    used_user_content = False

    eval_val_0 = ""
    eval_key_0 = "TEMP_DIR"
    if eval_key_0 in xcconfigs:
        eval_val_0 = xcconfigs[eval_key_0]
        used_user_content = True
    elif eval_key_0 in id_configs:
        opt = id_configs[eval_key_0]
        if "DefaultValue" in opt:
            (eval_val_0_used_user_content, eval_val_0) = XCSPEC_EVALS[opt["DefaultValue"]](xcconfigs, id_configs)
            used_user_content = used_user_content or eval_val_0_used_user_content

    eval_val_1 = ""
    eval_key_1 = "PRODUCT_NAME"
    if eval_key_1 in xcconfigs:
        eval_val_1 = xcconfigs[eval_key_1]
        used_user_content = True
    elif eval_key_1 in id_configs:
        opt = id_configs[eval_key_1]
        if "DefaultValue" in opt:
            (eval_val_1_used_user_content, eval_val_1) = XCSPEC_EVALS[opt["DefaultValue"]](xcconfigs, id_configs)
            used_user_content = used_user_content or eval_val_1_used_user_content

    return (used_user_content, "{eval_val_0}/{eval_val_1}-all-non-framework-target-headers.hmap".format(eval_val_0 = eval_val_0, eval_val_1 = eval_val_1))

def _com_apple_compilers_llvm_clang_1_0__CPP_HEADERMAP_FILE_FOR_PROJECT_FILES__DefaultValue(xcconfigs, id_configs):
    # $(TEMP_DIR)/$(PRODUCT_NAME)-project-headers.hmap

    used_user_content = False

    eval_val_0 = ""
    eval_key_0 = "TEMP_DIR"
    if eval_key_0 in xcconfigs:
        eval_val_0 = xcconfigs[eval_key_0]
        used_user_content = True
    elif eval_key_0 in id_configs:
        opt = id_configs[eval_key_0]
        if "DefaultValue" in opt:
            (eval_val_0_used_user_content, eval_val_0) = XCSPEC_EVALS[opt["DefaultValue"]](xcconfigs, id_configs)
            used_user_content = used_user_content or eval_val_0_used_user_content

    eval_val_1 = ""
    eval_key_1 = "PRODUCT_NAME"
    if eval_key_1 in xcconfigs:
        eval_val_1 = xcconfigs[eval_key_1]
        used_user_content = True
    elif eval_key_1 in id_configs:
        opt = id_configs[eval_key_1]
        if "DefaultValue" in opt:
            (eval_val_1_used_user_content, eval_val_1) = XCSPEC_EVALS[opt["DefaultValue"]](xcconfigs, id_configs)
            used_user_content = used_user_content or eval_val_1_used_user_content

    return (used_user_content, "{eval_val_0}/{eval_val_1}-project-headers.hmap".format(eval_val_0 = eval_val_0, eval_val_1 = eval_val_1))

def _com_apple_compilers_llvm_clang_1_0__CPP_HEADERMAP_PRODUCT_HEADERS_VFS_FILE__DefaultValue(xcconfigs, id_configs):
    # $(PROJECT_TEMP_DIR)/all-product-headers.yaml

    used_user_content = False

    eval_val_0 = ""
    eval_key_0 = "PROJECT_TEMP_DIR"
    if eval_key_0 in xcconfigs:
        eval_val_0 = xcconfigs[eval_key_0]
        used_user_content = True
    elif eval_key_0 in id_configs:
        opt = id_configs[eval_key_0]
        if "DefaultValue" in opt:
            (eval_val_0_used_user_content, eval_val_0) = XCSPEC_EVALS[opt["DefaultValue"]](xcconfigs, id_configs)
            used_user_content = used_user_content or eval_val_0_used_user_content

    return (used_user_content, "{eval_val_0}/all-product-headers.yaml".format(eval_val_0 = eval_val_0))

def _com_apple_compilers_llvm_clang_1_0__USE_HEADER_SYMLINKS__DefaultValue(xcconfigs, id_configs):
    # NO
    return (False, "NO")

def _com_apple_compilers_llvm_clang_1_0__CPP_HEADER_SYMLINKS_DIR__DefaultValue(xcconfigs, id_configs):
    # $(TEMP_DIR)/$(PRODUCT_NAME).hdrs

    used_user_content = False

    eval_val_0 = ""
    eval_key_0 = "TEMP_DIR"
    if eval_key_0 in xcconfigs:
        eval_val_0 = xcconfigs[eval_key_0]
        used_user_content = True
    elif eval_key_0 in id_configs:
        opt = id_configs[eval_key_0]
        if "DefaultValue" in opt:
            (eval_val_0_used_user_content, eval_val_0) = XCSPEC_EVALS[opt["DefaultValue"]](xcconfigs, id_configs)
            used_user_content = used_user_content or eval_val_0_used_user_content

    eval_val_1 = ""
    eval_key_1 = "PRODUCT_NAME"
    if eval_key_1 in xcconfigs:
        eval_val_1 = xcconfigs[eval_key_1]
        used_user_content = True
    elif eval_key_1 in id_configs:
        opt = id_configs[eval_key_1]
        if "DefaultValue" in opt:
            (eval_val_1_used_user_content, eval_val_1) = XCSPEC_EVALS[opt["DefaultValue"]](xcconfigs, id_configs)
            used_user_content = used_user_content or eval_val_1_used_user_content

    return (used_user_content, "{eval_val_0}/{eval_val_1}.hdrs".format(eval_val_0 = eval_val_0, eval_val_1 = eval_val_1))

def _com_apple_compilers_llvm_clang_1_0__GCC_USE_GCC3_PFE_SUPPORT__DefaultValue(xcconfigs, id_configs):
    # YES
    return (False, "YES")

def _com_apple_compilers_llvm_clang_1_0__GCC_PFE_FILE_C_DIALECTS__DefaultValue(xcconfigs, id_configs):
    # c objective-c c++ objective-c++
    return (False, "c objective-c c++ objective-c++")

def _com_apple_compilers_llvm_clang_1_0__ENABLE_APPLE_KEXT_CODE_GENERATION__DefaultValue(xcconfigs, id_configs):
    # NO
    return (False, "NO")

def _com_apple_compilers_llvm_clang_1_0__GCC_WARN_UNUSED_PARAMETER__DefaultValue(xcconfigs, id_configs):
    # NO
    return (False, "NO")

def _com_apple_compilers_llvm_clang_1_0__GCC_WARN_UNUSED_VARIABLE__DefaultValue(xcconfigs, id_configs):
    # NO
    return (False, "NO")

def _com_apple_compilers_llvm_clang_1_0__GCC_WARN_UNUSED_VALUE__DefaultValue(xcconfigs, id_configs):
    # YES
    return (False, "YES")

def _com_apple_compilers_llvm_clang_1_0__CLANG_WARN_XNU_TYPED_ALLOCATORS__DefaultValue(xcconfigs, id_configs):
    # DEFAULT
    return (False, "DEFAULT")

def _com_apple_compilers_llvm_clang_1_0__GCC_ENABLE_EXCEPTIONS__DefaultValue(xcconfigs, id_configs):
    # NO
    return (False, "NO")

def _com_apple_compilers_llvm_clang_1_0__GCC_ENABLE_OBJC_EXCEPTIONS__DefaultValue(xcconfigs, id_configs):
    # YES
    return (False, "YES")

def _com_apple_compilers_llvm_clang_1_0__CLANG_ENABLE_OBJC_ARC_EXCEPTIONS__DefaultValue(xcconfigs, id_configs):
    # NO
    return (False, "NO")

def _com_apple_compilers_llvm_clang_1_0__GCC_CW_ASM_SYNTAX__DefaultValue(xcconfigs, id_configs):
    # YES
    return (False, "YES")

def _com_apple_compilers_llvm_clang_1_0__GCC_UNROLL_LOOPS__DefaultValue(xcconfigs, id_configs):
    # NO
    return (False, "NO")

def _com_apple_compilers_llvm_clang_1_0__GCC_FAST_MATH__Condition(xcconfigs, id_configs):
    # !$(LLVM_IMPLICIT_AGGRESSIVE_OPTIMIZATIONS)

    used_user_content = False

    eval_val_0 = ""
    eval_key_0 = "LLVM_IMPLICIT_AGGRESSIVE_OPTIMIZATIONS"
    if eval_key_0 in xcconfigs:
        eval_val_0 = xcconfigs[eval_key_0]
        used_user_content = True
    elif eval_key_0 in id_configs:
        opt = id_configs[eval_key_0]
        if "DefaultValue" in opt:
            (eval_val_0_used_user_content, eval_val_0) = XCSPEC_EVALS[opt["DefaultValue"]](xcconfigs, id_configs)
            used_user_content = used_user_content or eval_val_0_used_user_content

    return (used_user_content, (not eval_val_0 == "YES"))

def _com_apple_compilers_llvm_clang_1_0__GCC_FAST_MATH__DefaultValue(xcconfigs, id_configs):
    # NO
    return (False, "NO")

def _com_apple_compilers_llvm_clang_1_0__GCC_STRICT_ALIASING__DefaultValue(xcconfigs, id_configs):
    # YES
    return (False, "YES")

def _com_apple_compilers_llvm_clang_1_0__GCC_INSTRUMENT_PROGRAM_FLOW_ARCS__DefaultValue(xcconfigs, id_configs):
    # NO
    return (False, "NO")

def _com_apple_compilers_llvm_clang_1_0__GCC_GENERATE_TEST_COVERAGE_FILES__DefaultValue(xcconfigs, id_configs):
    # NO
    return (False, "NO")

def _com_apple_compilers_llvm_clang_1_0__GCC_WARN_ALLOW_INCOMPLETE_PROTOCOL__DefaultValue(xcconfigs, id_configs):
    # YES
    return (False, "YES")

def _com_apple_compilers_llvm_clang_1_0__GCC_WARN_ABOUT_DEPRECATED_FUNCTIONS__DefaultValue(xcconfigs, id_configs):
    # YES
    return (False, "YES")

def _com_apple_compilers_llvm_clang_1_0__GCC_WARN_ABOUT_INVALID_OFFSETOF_MACRO__DefaultValue(xcconfigs, id_configs):
    # YES
    return (False, "YES")

def _com_apple_compilers_llvm_clang_1_0__GCC_DEBUG_INFORMATION_FORMAT__Condition(xcconfigs, id_configs):
    # $(GCC_GENERATE_DEBUGGING_SYMBOLS)

    used_user_content = False

    eval_val_0 = ""
    eval_key_0 = "GCC_GENERATE_DEBUGGING_SYMBOLS"
    if eval_key_0 in xcconfigs:
        eval_val_0 = xcconfigs[eval_key_0]
        used_user_content = True
    elif eval_key_0 in id_configs:
        opt = id_configs[eval_key_0]
        if "DefaultValue" in opt:
            (eval_val_0_used_user_content, eval_val_0) = XCSPEC_EVALS[opt["DefaultValue"]](xcconfigs, id_configs)
            used_user_content = used_user_content or eval_val_0_used_user_content

    return (used_user_content, (eval_val_0 == "YES"))

def _com_apple_compilers_llvm_clang_1_0__GCC_DEBUG_INFORMATION_FORMAT__DefaultValue(xcconfigs, id_configs):
    # $(DEBUG_INFORMATION_FORMAT)

    used_user_content = False

    eval_val_0 = ""
    eval_key_0 = "DEBUG_INFORMATION_FORMAT"
    if eval_key_0 in xcconfigs:
        eval_val_0 = xcconfigs[eval_key_0]
        used_user_content = True
    elif eval_key_0 in id_configs:
        opt = id_configs[eval_key_0]
        if "DefaultValue" in opt:
            (eval_val_0_used_user_content, eval_val_0) = XCSPEC_EVALS[opt["DefaultValue"]](xcconfigs, id_configs)
            used_user_content = used_user_content or eval_val_0_used_user_content

    return (used_user_content, eval_val_0)

def _com_apple_compilers_llvm_clang_1_0__CLANG_DEBUG_INFORMATION_LEVEL__Condition(xcconfigs, id_configs):
    # $(GCC_GENERATE_DEBUGGING_SYMBOLS)

    used_user_content = False

    eval_val_0 = ""
    eval_key_0 = "GCC_GENERATE_DEBUGGING_SYMBOLS"
    if eval_key_0 in xcconfigs:
        eval_val_0 = xcconfigs[eval_key_0]
        used_user_content = True
    elif eval_key_0 in id_configs:
        opt = id_configs[eval_key_0]
        if "DefaultValue" in opt:
            (eval_val_0_used_user_content, eval_val_0) = XCSPEC_EVALS[opt["DefaultValue"]](xcconfigs, id_configs)
            used_user_content = used_user_content or eval_val_0_used_user_content

    return (used_user_content, (eval_val_0 == "YES"))

def _com_apple_compilers_llvm_clang_1_0__CLANG_DEBUG_INFORMATION_LEVEL__DefaultValue(xcconfigs, id_configs):
    # default
    return (False, "default")

def _com_apple_compilers_llvm_clang_1_0__GCC_ENABLE_SSE3_EXTENSIONS__DefaultValue(xcconfigs, id_configs):
    # NO
    return (False, "NO")

def _com_apple_compilers_llvm_clang_1_0__GCC_ENABLE_SUPPLEMENTAL_SSE3_INSTRUCTIONS__DefaultValue(xcconfigs, id_configs):
    # NO
    return (False, "NO")

def _com_apple_compilers_llvm_clang_1_0__GCC_ENABLE_SSE41_EXTENSIONS__DefaultValue(xcconfigs, id_configs):
    # NO
    return (False, "NO")

def _com_apple_compilers_llvm_clang_1_0__GCC_ENABLE_SSE42_EXTENSIONS__DefaultValue(xcconfigs, id_configs):
    # NO
    return (False, "NO")

def _com_apple_compilers_llvm_clang_1_0__DEFAULT_SSE_LEVEL_3_YES__DefaultValue(xcconfigs, id_configs):
    # sse3
    return (False, "sse3")

def _com_apple_compilers_llvm_clang_1_0__DEFAULT_SSE_LEVEL_3_NO__DefaultValue(xcconfigs, id_configs):
    # default
    return (False, "default")

def _com_apple_compilers_llvm_clang_1_0__DEFAULT_SSE_LEVEL_3_SUPPLEMENTAL_YES__DefaultValue(xcconfigs, id_configs):
    # ssse3
    return (False, "ssse3")

def _com_apple_compilers_llvm_clang_1_0__DEFAULT_SSE_LEVEL_3_SUPPLEMENTAL_NO__DefaultValue(xcconfigs, id_configs):
    # $(DEFAULT_SSE_LEVEL_3_$(GCC_ENABLE_SSE3_EXTENSIONS))

    used_user_content = False

    eval_val_0 = ""
    eval_key_0 = "GCC_ENABLE_SSE3_EXTENSIONS"
    if eval_key_0 in xcconfigs:
        eval_val_0 = xcconfigs[eval_key_0]
        used_user_content = True
    elif eval_key_0 in id_configs:
        opt = id_configs[eval_key_0]
        if "DefaultValue" in opt:
            (eval_val_0_used_user_content, eval_val_0) = XCSPEC_EVALS[opt["DefaultValue"]](xcconfigs, id_configs)
            used_user_content = used_user_content or eval_val_0_used_user_content

    eval_val_1 = ""
    eval_key_1 = "DEFAULT_SSE_LEVEL_3_{eval_val_0}".format(eval_val_0 = eval_val_0)
    if eval_key_1 in xcconfigs:
        eval_val_1 = xcconfigs[eval_key_1]
        used_user_content = True
    elif eval_key_1 in id_configs:
        opt = id_configs[eval_key_1]
        if "DefaultValue" in opt:
            (eval_val_1_used_user_content, eval_val_1) = XCSPEC_EVALS[opt["DefaultValue"]](xcconfigs, id_configs)
            used_user_content = used_user_content or eval_val_1_used_user_content

    return (used_user_content, eval_val_1)

def _com_apple_compilers_llvm_clang_1_0__DEFAULT_SSE_LEVEL_4_1_YES__DefaultValue(xcconfigs, id_configs):
    # sse4.1
    return (False, "sse4.1")

def _com_apple_compilers_llvm_clang_1_0__DEFAULT_SSE_LEVEL_4_1_NO__DefaultValue(xcconfigs, id_configs):
    # $(DEFAULT_SSE_LEVEL_3_SUPPLEMENTAL_$(GCC_ENABLE_SUPPLEMENTAL_SSE3_INSTRUCTIONS))

    used_user_content = False

    eval_val_0 = ""
    eval_key_0 = "GCC_ENABLE_SUPPLEMENTAL_SSE3_INSTRUCTIONS"
    if eval_key_0 in xcconfigs:
        eval_val_0 = xcconfigs[eval_key_0]
        used_user_content = True
    elif eval_key_0 in id_configs:
        opt = id_configs[eval_key_0]
        if "DefaultValue" in opt:
            (eval_val_0_used_user_content, eval_val_0) = XCSPEC_EVALS[opt["DefaultValue"]](xcconfigs, id_configs)
            used_user_content = used_user_content or eval_val_0_used_user_content

    eval_val_1 = ""
    eval_key_1 = "DEFAULT_SSE_LEVEL_3_SUPPLEMENTAL_{eval_val_0}".format(eval_val_0 = eval_val_0)
    if eval_key_1 in xcconfigs:
        eval_val_1 = xcconfigs[eval_key_1]
        used_user_content = True
    elif eval_key_1 in id_configs:
        opt = id_configs[eval_key_1]
        if "DefaultValue" in opt:
            (eval_val_1_used_user_content, eval_val_1) = XCSPEC_EVALS[opt["DefaultValue"]](xcconfigs, id_configs)
            used_user_content = used_user_content or eval_val_1_used_user_content

    return (used_user_content, eval_val_1)

def _com_apple_compilers_llvm_clang_1_0__DEFAULT_SSE_LEVEL_4_2_YES__DefaultValue(xcconfigs, id_configs):
    # sse4.2
    return (False, "sse4.2")

def _com_apple_compilers_llvm_clang_1_0__DEFAULT_SSE_LEVEL_4_2_NO__DefaultValue(xcconfigs, id_configs):
    # $(DEFAULT_SSE_LEVEL_4_1_$(GCC_ENABLE_SSE41_EXTENSIONS))

    used_user_content = False

    eval_val_0 = ""
    eval_key_0 = "GCC_ENABLE_SSE41_EXTENSIONS"
    if eval_key_0 in xcconfigs:
        eval_val_0 = xcconfigs[eval_key_0]
        used_user_content = True
    elif eval_key_0 in id_configs:
        opt = id_configs[eval_key_0]
        if "DefaultValue" in opt:
            (eval_val_0_used_user_content, eval_val_0) = XCSPEC_EVALS[opt["DefaultValue"]](xcconfigs, id_configs)
            used_user_content = used_user_content or eval_val_0_used_user_content

    eval_val_1 = ""
    eval_key_1 = "DEFAULT_SSE_LEVEL_4_1_{eval_val_0}".format(eval_val_0 = eval_val_0)
    if eval_key_1 in xcconfigs:
        eval_val_1 = xcconfigs[eval_key_1]
        used_user_content = True
    elif eval_key_1 in id_configs:
        opt = id_configs[eval_key_1]
        if "DefaultValue" in opt:
            (eval_val_1_used_user_content, eval_val_1) = XCSPEC_EVALS[opt["DefaultValue"]](xcconfigs, id_configs)
            used_user_content = used_user_content or eval_val_1_used_user_content

    return (used_user_content, eval_val_1)

def _com_apple_compilers_llvm_clang_1_0__CLANG_X86_VECTOR_INSTRUCTIONS__DefaultValue(xcconfigs, id_configs):
    # $(DEFAULT_SSE_LEVEL_4_2_$(GCC_ENABLE_SSE42_EXTENSIONS))

    used_user_content = False

    eval_val_0 = ""
    eval_key_0 = "GCC_ENABLE_SSE42_EXTENSIONS"
    if eval_key_0 in xcconfigs:
        eval_val_0 = xcconfigs[eval_key_0]
        used_user_content = True
    elif eval_key_0 in id_configs:
        opt = id_configs[eval_key_0]
        if "DefaultValue" in opt:
            (eval_val_0_used_user_content, eval_val_0) = XCSPEC_EVALS[opt["DefaultValue"]](xcconfigs, id_configs)
            used_user_content = used_user_content or eval_val_0_used_user_content

    eval_val_1 = ""
    eval_key_1 = "DEFAULT_SSE_LEVEL_4_2_{eval_val_0}".format(eval_val_0 = eval_val_0)
    if eval_key_1 in xcconfigs:
        eval_val_1 = xcconfigs[eval_key_1]
        used_user_content = True
    elif eval_key_1 in id_configs:
        opt = id_configs[eval_key_1]
        if "DefaultValue" in opt:
            (eval_val_1_used_user_content, eval_val_1) = XCSPEC_EVALS[opt["DefaultValue"]](xcconfigs, id_configs)
            used_user_content = used_user_content or eval_val_1_used_user_content

    return (used_user_content, eval_val_1)

def _com_apple_compilers_llvm_clang_1_0__GCC_SYMBOLS_PRIVATE_EXTERN__DefaultValue(xcconfigs, id_configs):
    # NO
    return (False, "NO")

def _com_apple_compilers_llvm_clang_1_0__GCC_INLINES_ARE_PRIVATE_EXTERN__DefaultValue(xcconfigs, id_configs):
    # NO
    return (False, "NO")

def _com_apple_compilers_llvm_clang_1_0__GCC_THREADSAFE_STATICS__DefaultValue(xcconfigs, id_configs):
    # YES
    return (False, "YES")

def _com_apple_compilers_llvm_clang_1_0__GCC_WARN_ABOUT_POINTER_SIGNEDNESS__DefaultValue(xcconfigs, id_configs):
    # YES
    return (False, "YES")

def _com_apple_compilers_llvm_clang_1_0__GCC_WARN_ABOUT_MISSING_NEWLINE__DefaultValue(xcconfigs, id_configs):
    # NO
    return (False, "NO")

def _com_apple_compilers_llvm_clang_1_0__CLANG_WARN_IMPLICIT_SIGN_CONVERSION__DefaultValue(xcconfigs, id_configs):
    # NO
    return (False, "NO")

def _com_apple_compilers_llvm_clang_1_0__GCC_WARN_64_TO_32_BIT_CONVERSION__DefaultValue(xcconfigs, id_configs):
    # NO
    return (False, "NO")

def _com_apple_compilers_llvm_clang_1_0__CLANG_WARN_INFINITE_RECURSION__DefaultValue(xcconfigs, id_configs):
    # NO
    return (False, "NO")

def _com_apple_compilers_llvm_clang_1_0__CLANG_WARN_SUSPICIOUS_MOVE__DefaultValue(xcconfigs, id_configs):
    # NO
    return (False, "NO")

def _com_apple_compilers_llvm_clang_1_0__CLANG_WARN_COMMA__DefaultValue(xcconfigs, id_configs):
    # NO
    return (False, "NO")

def _com_apple_compilers_llvm_clang_1_0__CLANG_WARN_BLOCK_CAPTURE_AUTORELEASING__DefaultValue(xcconfigs, id_configs):
    # NO
    return (False, "NO")

def _com_apple_compilers_llvm_clang_1_0__CLANG_WARN_STRICT_PROTOTYPES__DefaultValue(xcconfigs, id_configs):
    # NO
    return (False, "NO")

def _com_apple_compilers_llvm_clang_1_0__CLANG_WARN_RANGE_LOOP_ANALYSIS__DefaultValue(xcconfigs, id_configs):
    # NO
    return (False, "NO")

def _com_apple_compilers_llvm_clang_1_0__CLANG_WARN_SEMICOLON_BEFORE_METHOD_BODY__DefaultValue(xcconfigs, id_configs):
    # NO
    return (False, "NO")

def _com_apple_compilers_llvm_clang_1_0__CLANG_WARN_UNGUARDED_AVAILABILITY__DefaultValue(xcconfigs, id_configs):
    # YES
    return (False, "YES")

def _com_apple_compilers_llvm_clang_1_0__GCC_OBJC_ABI_VERSION__DefaultValue(xcconfigs, id_configs):
    # $(OBJC_ABI_VERSION)

    used_user_content = False

    eval_val_0 = ""
    eval_key_0 = "OBJC_ABI_VERSION"
    if eval_key_0 in xcconfigs:
        eval_val_0 = xcconfigs[eval_key_0]
        used_user_content = True
    elif eval_key_0 in id_configs:
        opt = id_configs[eval_key_0]
        if "DefaultValue" in opt:
            (eval_val_0_used_user_content, eval_val_0) = XCSPEC_EVALS[opt["DefaultValue"]](xcconfigs, id_configs)
            used_user_content = used_user_content or eval_val_0_used_user_content

    return (used_user_content, eval_val_0)

def _com_apple_compilers_llvm_clang_1_0__GCC_OBJC_LEGACY_DISPATCH__DefaultValue(xcconfigs, id_configs):
    # NO
    return (False, "NO")

def _com_apple_compilers_llvm_clang_1_0__CLANG_INSTRUMENT_FOR_OPTIMIZATION_PROFILING__DefaultValue(xcconfigs, id_configs):
    # NO
    return (False, "NO")

def _com_apple_compilers_llvm_clang_1_0__CLANG_OPTIMIZATION_PROFILE_FILE__DefaultValue(xcconfigs, id_configs):
    # $(SRCROOT)/OptimizationProfiles/$(PROJECT_NAME).profdata

    used_user_content = False

    eval_val_0 = ""
    eval_key_0 = "SRCROOT"
    if eval_key_0 in xcconfigs:
        eval_val_0 = xcconfigs[eval_key_0]
        used_user_content = True
    elif eval_key_0 in id_configs:
        opt = id_configs[eval_key_0]
        if "DefaultValue" in opt:
            (eval_val_0_used_user_content, eval_val_0) = XCSPEC_EVALS[opt["DefaultValue"]](xcconfigs, id_configs)
            used_user_content = used_user_content or eval_val_0_used_user_content

    eval_val_1 = ""
    eval_key_1 = "PROJECT_NAME"
    if eval_key_1 in xcconfigs:
        eval_val_1 = xcconfigs[eval_key_1]
        used_user_content = True
    elif eval_key_1 in id_configs:
        opt = id_configs[eval_key_1]
        if "DefaultValue" in opt:
            (eval_val_1_used_user_content, eval_val_1) = XCSPEC_EVALS[opt["DefaultValue"]](xcconfigs, id_configs)
            used_user_content = used_user_content or eval_val_1_used_user_content

    return (used_user_content, "{eval_val_0}/OptimizationProfiles/{eval_val_1}.profdata".format(eval_val_0 = eval_val_0, eval_val_1 = eval_val_1))

def _com_apple_compilers_llvm_clang_1_0__CLANG_USE_OPTIMIZATION_PROFILE__Condition(xcconfigs, id_configs):
    # ! $(CLANG_INSTRUMENT_FOR_OPTIMIZATION_PROFILING) && ! $(CLANG_COVERAGE_MAPPING)

    used_user_content = False

    eval_val_0 = ""
    eval_key_0 = "CLANG_INSTRUMENT_FOR_OPTIMIZATION_PROFILING"
    if eval_key_0 in xcconfigs:
        eval_val_0 = xcconfigs[eval_key_0]
        used_user_content = True
    elif eval_key_0 in id_configs:
        opt = id_configs[eval_key_0]
        if "DefaultValue" in opt:
            (eval_val_0_used_user_content, eval_val_0) = XCSPEC_EVALS[opt["DefaultValue"]](xcconfigs, id_configs)
            used_user_content = used_user_content or eval_val_0_used_user_content

    eval_val_1 = ""
    eval_key_1 = "CLANG_COVERAGE_MAPPING"
    if eval_key_1 in xcconfigs:
        eval_val_1 = xcconfigs[eval_key_1]
        used_user_content = True
    elif eval_key_1 in id_configs:
        opt = id_configs[eval_key_1]
        if "DefaultValue" in opt:
            (eval_val_1_used_user_content, eval_val_1) = XCSPEC_EVALS[opt["DefaultValue"]](xcconfigs, id_configs)
            used_user_content = used_user_content or eval_val_1_used_user_content

    return (used_user_content, (not eval_val_0 == "YES" and not eval_val_1 == "YES"))

def _com_apple_compilers_llvm_clang_1_0__CLANG_USE_OPTIMIZATION_PROFILE__DefaultValue(xcconfigs, id_configs):
    # NO
    return (False, "NO")

def _com_apple_compilers_llvm_clang_1_0__CLANG_ENABLE_CODE_COVERAGE__DefaultValue(xcconfigs, id_configs):
    # $(ENABLE_CODE_COVERAGE)

    used_user_content = False

    eval_val_0 = ""
    eval_key_0 = "ENABLE_CODE_COVERAGE"
    if eval_key_0 in xcconfigs:
        eval_val_0 = xcconfigs[eval_key_0]
        used_user_content = True
    elif eval_key_0 in id_configs:
        opt = id_configs[eval_key_0]
        if "DefaultValue" in opt:
            (eval_val_0_used_user_content, eval_val_0) = XCSPEC_EVALS[opt["DefaultValue"]](xcconfigs, id_configs)
            used_user_content = used_user_content or eval_val_0_used_user_content

    return (used_user_content, eval_val_0)

def _com_apple_compilers_llvm_clang_1_0__CLANG_COVERAGE_MAPPING__Condition(xcconfigs, id_configs):
    # $(CLANG_ENABLE_CODE_COVERAGE)

    used_user_content = False

    eval_val_0 = ""
    eval_key_0 = "CLANG_ENABLE_CODE_COVERAGE"
    if eval_key_0 in xcconfigs:
        eval_val_0 = xcconfigs[eval_key_0]
        used_user_content = True
    elif eval_key_0 in id_configs:
        opt = id_configs[eval_key_0]
        if "DefaultValue" in opt:
            (eval_val_0_used_user_content, eval_val_0) = XCSPEC_EVALS[opt["DefaultValue"]](xcconfigs, id_configs)
            used_user_content = used_user_content or eval_val_0_used_user_content

    return (used_user_content, (eval_val_0 == "YES"))

def _com_apple_compilers_llvm_clang_1_0__CLANG_COVERAGE_MAPPING__DefaultValue(xcconfigs, id_configs):
    # NO
    return (False, "NO")

def _com_apple_compilers_llvm_clang_1_0__CLANG_COVERAGE_MAPPING_LINKER_ARGS__DefaultValue(xcconfigs, id_configs):
    # $(CLANG_COVERAGE_MAPPING)

    used_user_content = False

    eval_val_0 = ""
    eval_key_0 = "CLANG_COVERAGE_MAPPING"
    if eval_key_0 in xcconfigs:
        eval_val_0 = xcconfigs[eval_key_0]
        used_user_content = True
    elif eval_key_0 in id_configs:
        opt = id_configs[eval_key_0]
        if "DefaultValue" in opt:
            (eval_val_0_used_user_content, eval_val_0) = XCSPEC_EVALS[opt["DefaultValue"]](xcconfigs, id_configs)
            used_user_content = used_user_content or eval_val_0_used_user_content

    return (used_user_content, eval_val_0)

def _com_apple_compilers_llvm_clang_1_0__CLANG_BITCODE_GENERATION_MODE__Condition(xcconfigs, id_configs):
    # $(ENABLE_BITCODE)

    used_user_content = False

    eval_val_0 = ""
    eval_key_0 = "ENABLE_BITCODE"
    if eval_key_0 in xcconfigs:
        eval_val_0 = xcconfigs[eval_key_0]
        used_user_content = True
    elif eval_key_0 in id_configs:
        opt = id_configs[eval_key_0]
        if "DefaultValue" in opt:
            (eval_val_0_used_user_content, eval_val_0) = XCSPEC_EVALS[opt["DefaultValue"]](xcconfigs, id_configs)
            used_user_content = used_user_content or eval_val_0_used_user_content

    return (used_user_content, (eval_val_0 == "YES"))

def _com_apple_compilers_llvm_clang_1_0__CLANG_BITCODE_GENERATION_MODE__DefaultValue(xcconfigs, id_configs):
    # $(BITCODE_GENERATION_MODE)

    used_user_content = False

    eval_val_0 = ""
    eval_key_0 = "BITCODE_GENERATION_MODE"
    if eval_key_0 in xcconfigs:
        eval_val_0 = xcconfigs[eval_key_0]
        used_user_content = True
    elif eval_key_0 in id_configs:
        opt = id_configs[eval_key_0]
        if "DefaultValue" in opt:
            (eval_val_0_used_user_content, eval_val_0) = XCSPEC_EVALS[opt["DefaultValue"]](xcconfigs, id_configs)
            used_user_content = used_user_content or eval_val_0_used_user_content

    return (used_user_content, eval_val_0)

def _com_apple_compilers_llvm_clang_1_0__CLANG_ADDRESS_SANITIZER__DefaultValue(xcconfigs, id_configs):
    # $(ENABLE_ADDRESS_SANITIZER)

    used_user_content = False

    eval_val_0 = ""
    eval_key_0 = "ENABLE_ADDRESS_SANITIZER"
    if eval_key_0 in xcconfigs:
        eval_val_0 = xcconfigs[eval_key_0]
        used_user_content = True
    elif eval_key_0 in id_configs:
        opt = id_configs[eval_key_0]
        if "DefaultValue" in opt:
            (eval_val_0_used_user_content, eval_val_0) = XCSPEC_EVALS[opt["DefaultValue"]](xcconfigs, id_configs)
            used_user_content = used_user_content or eval_val_0_used_user_content

    return (used_user_content, eval_val_0)

def _com_apple_compilers_llvm_clang_1_0__CLANG_ADDRESS_SANITIZER_CONTAINER_OVERFLOW__Condition(xcconfigs, id_configs):
    # $(CLANG_ADDRESS_SANITIZER)

    used_user_content = False

    eval_val_0 = ""
    eval_key_0 = "CLANG_ADDRESS_SANITIZER"
    if eval_key_0 in xcconfigs:
        eval_val_0 = xcconfigs[eval_key_0]
        used_user_content = True
    elif eval_key_0 in id_configs:
        opt = id_configs[eval_key_0]
        if "DefaultValue" in opt:
            (eval_val_0_used_user_content, eval_val_0) = XCSPEC_EVALS[opt["DefaultValue"]](xcconfigs, id_configs)
            used_user_content = used_user_content or eval_val_0_used_user_content

    return (used_user_content, (eval_val_0 == "YES"))

def _com_apple_compilers_llvm_clang_1_0__CLANG_ADDRESS_SANITIZER_CONTAINER_OVERFLOW__DefaultValue(xcconfigs, id_configs):
    # NO
    return (False, "NO")

def _com_apple_compilers_llvm_clang_1_0__CLANG_ADDRESS_SANITIZER_USE_AFTER_SCOPE__Condition(xcconfigs, id_configs):
    # $(CLANG_ADDRESS_SANITIZER)

    used_user_content = False

    eval_val_0 = ""
    eval_key_0 = "CLANG_ADDRESS_SANITIZER"
    if eval_key_0 in xcconfigs:
        eval_val_0 = xcconfigs[eval_key_0]
        used_user_content = True
    elif eval_key_0 in id_configs:
        opt = id_configs[eval_key_0]
        if "DefaultValue" in opt:
            (eval_val_0_used_user_content, eval_val_0) = XCSPEC_EVALS[opt["DefaultValue"]](xcconfigs, id_configs)
            used_user_content = used_user_content or eval_val_0_used_user_content

    return (used_user_content, (eval_val_0 == "YES"))

def _com_apple_compilers_llvm_clang_1_0__CLANG_ADDRESS_SANITIZER_USE_AFTER_SCOPE__DefaultValue(xcconfigs, id_configs):
    # NO
    return (False, "NO")

def _com_apple_compilers_llvm_clang_1_0__CLANG_ADDRESS_SANITIZER_ALLOW_ERROR_RECOVERY__Condition(xcconfigs, id_configs):
    # $(CLANG_ADDRESS_SANITIZER)

    used_user_content = False

    eval_val_0 = ""
    eval_key_0 = "CLANG_ADDRESS_SANITIZER"
    if eval_key_0 in xcconfigs:
        eval_val_0 = xcconfigs[eval_key_0]
        used_user_content = True
    elif eval_key_0 in id_configs:
        opt = id_configs[eval_key_0]
        if "DefaultValue" in opt:
            (eval_val_0_used_user_content, eval_val_0) = XCSPEC_EVALS[opt["DefaultValue"]](xcconfigs, id_configs)
            used_user_content = used_user_content or eval_val_0_used_user_content

    return (used_user_content, (eval_val_0 == "YES"))

def _com_apple_compilers_llvm_clang_1_0__CLANG_ADDRESS_SANITIZER_ALLOW_ERROR_RECOVERY__DefaultValue(xcconfigs, id_configs):
    # $(ENABLE_ADDRESS_SANITIZER_ALLOW_ERROR_RECOVERY)

    used_user_content = False

    eval_val_0 = ""
    eval_key_0 = "ENABLE_ADDRESS_SANITIZER_ALLOW_ERROR_RECOVERY"
    if eval_key_0 in xcconfigs:
        eval_val_0 = xcconfigs[eval_key_0]
        used_user_content = True
    elif eval_key_0 in id_configs:
        opt = id_configs[eval_key_0]
        if "DefaultValue" in opt:
            (eval_val_0_used_user_content, eval_val_0) = XCSPEC_EVALS[opt["DefaultValue"]](xcconfigs, id_configs)
            used_user_content = used_user_content or eval_val_0_used_user_content

    return (used_user_content, eval_val_0)

def _com_apple_compilers_llvm_clang_1_0__CLANG_LIBFUZZER__DefaultValue(xcconfigs, id_configs):
    # $(ENABLE_LIBFUZZER)

    used_user_content = False

    eval_val_0 = ""
    eval_key_0 = "ENABLE_LIBFUZZER"
    if eval_key_0 in xcconfigs:
        eval_val_0 = xcconfigs[eval_key_0]
        used_user_content = True
    elif eval_key_0 in id_configs:
        opt = id_configs[eval_key_0]
        if "DefaultValue" in opt:
            (eval_val_0_used_user_content, eval_val_0) = XCSPEC_EVALS[opt["DefaultValue"]](xcconfigs, id_configs)
            used_user_content = used_user_content or eval_val_0_used_user_content

    return (used_user_content, eval_val_0)

def _com_apple_compilers_llvm_clang_1_0__CLANG_SANITIZER_COVERAGE__Condition(xcconfigs, id_configs):
    # !$(CLANG_LIBFUZZER)

    used_user_content = False

    eval_val_0 = ""
    eval_key_0 = "CLANG_LIBFUZZER"
    if eval_key_0 in xcconfigs:
        eval_val_0 = xcconfigs[eval_key_0]
        used_user_content = True
    elif eval_key_0 in id_configs:
        opt = id_configs[eval_key_0]
        if "DefaultValue" in opt:
            (eval_val_0_used_user_content, eval_val_0) = XCSPEC_EVALS[opt["DefaultValue"]](xcconfigs, id_configs)
            used_user_content = used_user_content or eval_val_0_used_user_content

    return (used_user_content, (not eval_val_0 == "YES"))

def _com_apple_compilers_llvm_clang_1_0__CLANG_SANITIZER_COVERAGE__DefaultValue(xcconfigs, id_configs):
    # $(ENABLE_SANITIZER_COVERAGE)

    used_user_content = False

    eval_val_0 = ""
    eval_key_0 = "ENABLE_SANITIZER_COVERAGE"
    if eval_key_0 in xcconfigs:
        eval_val_0 = xcconfigs[eval_key_0]
        used_user_content = True
    elif eval_key_0 in id_configs:
        opt = id_configs[eval_key_0]
        if "DefaultValue" in opt:
            (eval_val_0_used_user_content, eval_val_0) = XCSPEC_EVALS[opt["DefaultValue"]](xcconfigs, id_configs)
            used_user_content = used_user_content or eval_val_0_used_user_content

    return (used_user_content, eval_val_0)

def _com_apple_compilers_llvm_clang_1_0__CLANG_UNDEFINED_BEHAVIOR_SANITIZER__DefaultValue(xcconfigs, id_configs):
    # $(ENABLE_UNDEFINED_BEHAVIOR_SANITIZER)

    used_user_content = False

    eval_val_0 = ""
    eval_key_0 = "ENABLE_UNDEFINED_BEHAVIOR_SANITIZER"
    if eval_key_0 in xcconfigs:
        eval_val_0 = xcconfigs[eval_key_0]
        used_user_content = True
    elif eval_key_0 in id_configs:
        opt = id_configs[eval_key_0]
        if "DefaultValue" in opt:
            (eval_val_0_used_user_content, eval_val_0) = XCSPEC_EVALS[opt["DefaultValue"]](xcconfigs, id_configs)
            used_user_content = used_user_content or eval_val_0_used_user_content

    return (used_user_content, eval_val_0)

def _com_apple_compilers_llvm_clang_1_0__CLANG_UNDEFINED_BEHAVIOR_SANITIZER_INTEGER__Condition(xcconfigs, id_configs):
    # $(CLANG_UNDEFINED_BEHAVIOR_SANITIZER)

    used_user_content = False

    eval_val_0 = ""
    eval_key_0 = "CLANG_UNDEFINED_BEHAVIOR_SANITIZER"
    if eval_key_0 in xcconfigs:
        eval_val_0 = xcconfigs[eval_key_0]
        used_user_content = True
    elif eval_key_0 in id_configs:
        opt = id_configs[eval_key_0]
        if "DefaultValue" in opt:
            (eval_val_0_used_user_content, eval_val_0) = XCSPEC_EVALS[opt["DefaultValue"]](xcconfigs, id_configs)
            used_user_content = used_user_content or eval_val_0_used_user_content

    return (used_user_content, (eval_val_0 == "YES"))

def _com_apple_compilers_llvm_clang_1_0__CLANG_UNDEFINED_BEHAVIOR_SANITIZER_INTEGER__DefaultValue(xcconfigs, id_configs):
    # NO
    return (False, "NO")

def _com_apple_compilers_llvm_clang_1_0__CLANG_UNDEFINED_BEHAVIOR_SANITIZER_NULLABILITY__Condition(xcconfigs, id_configs):
    # $(CLANG_UNDEFINED_BEHAVIOR_SANITIZER)

    used_user_content = False

    eval_val_0 = ""
    eval_key_0 = "CLANG_UNDEFINED_BEHAVIOR_SANITIZER"
    if eval_key_0 in xcconfigs:
        eval_val_0 = xcconfigs[eval_key_0]
        used_user_content = True
    elif eval_key_0 in id_configs:
        opt = id_configs[eval_key_0]
        if "DefaultValue" in opt:
            (eval_val_0_used_user_content, eval_val_0) = XCSPEC_EVALS[opt["DefaultValue"]](xcconfigs, id_configs)
            used_user_content = used_user_content or eval_val_0_used_user_content

    return (used_user_content, (eval_val_0 == "YES"))

def _com_apple_compilers_llvm_clang_1_0__CLANG_UNDEFINED_BEHAVIOR_SANITIZER_NULLABILITY__DefaultValue(xcconfigs, id_configs):
    # NO
    return (False, "NO")

def _com_apple_compilers_llvm_clang_1_0__CLANG_UNDEFINED_BEHAVIOR_SANITIZER_TRAP_ON_SECURITY_ISSUES__DefaultValue(xcconfigs, id_configs):
    # NO
    return (False, "NO")

def _com_apple_compilers_llvm_clang_1_0__CLANG_UNDEFINED_BEHAVIOR_SANITIZER_TRAP_ON_SECURITY_ISSUES_OPT__Condition(xcconfigs, id_configs):
    # $(CLANG_UNDEFINED_BEHAVIOR_SANITIZER_TRAP_ON_SECURITY_ISSUES) && $(GCC_OPTIMIZATION_LEVEL) != 0

    used_user_content = False

    eval_val_0 = ""
    eval_key_0 = "CLANG_UNDEFINED_BEHAVIOR_SANITIZER_TRAP_ON_SECURITY_ISSUES"
    if eval_key_0 in xcconfigs:
        eval_val_0 = xcconfigs[eval_key_0]
        used_user_content = True
    elif eval_key_0 in id_configs:
        opt = id_configs[eval_key_0]
        if "DefaultValue" in opt:
            (eval_val_0_used_user_content, eval_val_0) = XCSPEC_EVALS[opt["DefaultValue"]](xcconfigs, id_configs)
            used_user_content = used_user_content or eval_val_0_used_user_content

    eval_val_1 = ""
    eval_key_1 = "GCC_OPTIMIZATION_LEVEL"
    if eval_key_1 in xcconfigs:
        eval_val_1 = xcconfigs[eval_key_1]
        used_user_content = True
    elif eval_key_1 in id_configs:
        opt = id_configs[eval_key_1]
        if "DefaultValue" in opt:
            (eval_val_1_used_user_content, eval_val_1) = XCSPEC_EVALS[opt["DefaultValue"]](xcconfigs, id_configs)
            used_user_content = used_user_content or eval_val_1_used_user_content

    return (used_user_content, (eval_val_0 == "YES" and eval_val_1 != "0"))

def _com_apple_compilers_llvm_clang_1_0__CLANG_UNDEFINED_BEHAVIOR_SANITIZER_TRAP_ON_SECURITY_ISSUES_OPT__DefaultValue(xcconfigs, id_configs):
    # YES
    return (False, "YES")

def _com_apple_compilers_llvm_clang_1_0__CLANG_INDEX_STORE_PATH__DefaultValue(xcconfigs, id_configs):
    # $(INDEX_DATA_STORE_DIR)

    used_user_content = False

    eval_val_0 = ""
    eval_key_0 = "INDEX_DATA_STORE_DIR"
    if eval_key_0 in xcconfigs:
        eval_val_0 = xcconfigs[eval_key_0]
        used_user_content = True
    elif eval_key_0 in id_configs:
        opt = id_configs[eval_key_0]
        if "DefaultValue" in opt:
            (eval_val_0_used_user_content, eval_val_0) = XCSPEC_EVALS[opt["DefaultValue"]](xcconfigs, id_configs)
            used_user_content = used_user_content or eval_val_0_used_user_content

    return (used_user_content, eval_val_0)

def _com_apple_compilers_llvm_clang_1_0__CLANG_INDEX_STORE_ENABLE__Condition(xcconfigs, id_configs):
    # $(COMPILER_INDEX_STORE_ENABLE)  ||  ( $(COMPILER_INDEX_STORE_ENABLE) == Default  &&  $(GCC_OPTIMIZATION_LEVEL) == 0 )

    used_user_content = False

    eval_val_0 = ""
    eval_key_0 = "COMPILER_INDEX_STORE_ENABLE"
    if eval_key_0 in xcconfigs:
        eval_val_0 = xcconfigs[eval_key_0]
        used_user_content = True
    elif eval_key_0 in id_configs:
        opt = id_configs[eval_key_0]
        if "DefaultValue" in opt:
            (eval_val_0_used_user_content, eval_val_0) = XCSPEC_EVALS[opt["DefaultValue"]](xcconfigs, id_configs)
            used_user_content = used_user_content or eval_val_0_used_user_content

    eval_val_1 = ""
    eval_key_1 = "GCC_OPTIMIZATION_LEVEL"
    if eval_key_1 in xcconfigs:
        eval_val_1 = xcconfigs[eval_key_1]
        used_user_content = True
    elif eval_key_1 in id_configs:
        opt = id_configs[eval_key_1]
        if "DefaultValue" in opt:
            (eval_val_1_used_user_content, eval_val_1) = XCSPEC_EVALS[opt["DefaultValue"]](xcconfigs, id_configs)
            used_user_content = used_user_content or eval_val_1_used_user_content

    return (used_user_content, (eval_val_0 == "YES" or (eval_val_0 == "Default" and eval_val_1 == "0")))

def _com_apple_compilers_llvm_clang_1_0__CLANG_INDEX_STORE_ENABLE__DefaultValue(xcconfigs, id_configs):
    # $(INDEX_ENABLE_DATA_STORE)

    used_user_content = False

    eval_val_0 = ""
    eval_key_0 = "INDEX_ENABLE_DATA_STORE"
    if eval_key_0 in xcconfigs:
        eval_val_0 = xcconfigs[eval_key_0]
        used_user_content = True
    elif eval_key_0 in id_configs:
        opt = id_configs[eval_key_0]
        if "DefaultValue" in opt:
            (eval_val_0_used_user_content, eval_val_0) = XCSPEC_EVALS[opt["DefaultValue"]](xcconfigs, id_configs)
            used_user_content = used_user_content or eval_val_0_used_user_content

    return (used_user_content, eval_val_0)

def _com_apple_compilers_llvm_clang_1_0__CLANG_THREAD_SANITIZER__DefaultValue(xcconfigs, id_configs):
    # $(ENABLE_THREAD_SANITIZER)

    used_user_content = False

    eval_val_0 = ""
    eval_key_0 = "ENABLE_THREAD_SANITIZER"
    if eval_key_0 in xcconfigs:
        eval_val_0 = xcconfigs[eval_key_0]
        used_user_content = True
    elif eval_key_0 in id_configs:
        opt = id_configs[eval_key_0]
        if "DefaultValue" in opt:
            (eval_val_0_used_user_content, eval_val_0) = XCSPEC_EVALS[opt["DefaultValue"]](xcconfigs, id_configs)
            used_user_content = used_user_content or eval_val_0_used_user_content

    return (used_user_content, eval_val_0)

def _com_apple_compilers_llvm_clang_1_0__CLANG_ARC_MIGRATE_PRECHECK__DefaultValue(xcconfigs, id_configs):
    # donothing
    return (False, "donothing")

def _com_apple_compilers_llvm_clang_1_0__CLANG_ARC_MIGRATE_EMIT_ERROR__DefaultValue(xcconfigs, id_configs):
    # NO
    return (False, "NO")

def _com_apple_compilers_llvm_clang_1_0__CLANG_ENABLE_PREFIX_MAPPING__Condition(xcconfigs, id_configs):
    # $(CLANG_ENABLE_COMPILE_CACHE)

    used_user_content = False

    eval_val_0 = ""
    eval_key_0 = "CLANG_ENABLE_COMPILE_CACHE"
    if eval_key_0 in xcconfigs:
        eval_val_0 = xcconfigs[eval_key_0]
        used_user_content = True
    elif eval_key_0 in id_configs:
        opt = id_configs[eval_key_0]
        if "DefaultValue" in opt:
            (eval_val_0_used_user_content, eval_val_0) = XCSPEC_EVALS[opt["DefaultValue"]](xcconfigs, id_configs)
            used_user_content = used_user_content or eval_val_0_used_user_content

    return (used_user_content, (eval_val_0 == "YES"))

def _com_apple_compilers_llvm_clang_1_0__CLANG_OTHER_PREFIX_MAPPINGS__Condition(xcconfigs, id_configs):
    # $(CLANG_ENABLE_COMPILE_CACHE) && $(CLANG_ENABLE_PREFIX_MAPPING)

    used_user_content = False

    eval_val_0 = ""
    eval_key_0 = "CLANG_ENABLE_COMPILE_CACHE"
    if eval_key_0 in xcconfigs:
        eval_val_0 = xcconfigs[eval_key_0]
        used_user_content = True
    elif eval_key_0 in id_configs:
        opt = id_configs[eval_key_0]
        if "DefaultValue" in opt:
            (eval_val_0_used_user_content, eval_val_0) = XCSPEC_EVALS[opt["DefaultValue"]](xcconfigs, id_configs)
            used_user_content = used_user_content or eval_val_0_used_user_content

    eval_val_1 = ""
    eval_key_1 = "CLANG_ENABLE_PREFIX_MAPPING"
    if eval_key_1 in xcconfigs:
        eval_val_1 = xcconfigs[eval_key_1]
        used_user_content = True
    elif eval_key_1 in id_configs:
        opt = id_configs[eval_key_1]
        if "DefaultValue" in opt:
            (eval_val_1_used_user_content, eval_val_1) = XCSPEC_EVALS[opt["DefaultValue"]](xcconfigs, id_configs)
            used_user_content = used_user_content or eval_val_1_used_user_content

    return (used_user_content, (eval_val_0 == "YES" and eval_val_1 == "YES"))

def _com_apple_compilers_llvm_clang_1_0__CLANG_OTHER_PREFIX_MAPPINGS__DefaultValue(xcconfigs, id_configs):
    #
    return (False, "")

def _com_apple_compilers_model_coredata__MOMC_OUTPUT_SUFFIX__DefaultValue(xcconfigs, id_configs):
    # $(MOMC_OUTPUT_SUFFIX_$(InputFileSuffix:identifier))

    used_user_content = False

    eval_val_0 = ""
    eval_key_0 = "InputFileSuffix:identifier"
    if eval_key_0 in xcconfigs:
        eval_val_0 = xcconfigs[eval_key_0]
        used_user_content = True
    elif eval_key_0 in id_configs:
        opt = id_configs[eval_key_0]
        if "DefaultValue" in opt:
            (eval_val_0_used_user_content, eval_val_0) = XCSPEC_EVALS[opt["DefaultValue"]](xcconfigs, id_configs)
            used_user_content = used_user_content or eval_val_0_used_user_content

    eval_val_1 = ""
    eval_key_1 = "MOMC_OUTPUT_SUFFIX_{eval_val_0}".format(eval_val_0 = eval_val_0)
    if eval_key_1 in xcconfigs:
        eval_val_1 = xcconfigs[eval_key_1]
        used_user_content = True
    elif eval_key_1 in id_configs:
        opt = id_configs[eval_key_1]
        if "DefaultValue" in opt:
            (eval_val_1_used_user_content, eval_val_1) = XCSPEC_EVALS[opt["DefaultValue"]](xcconfigs, id_configs)
            used_user_content = used_user_content or eval_val_1_used_user_content

    return (used_user_content, eval_val_1)

def _com_apple_compilers_model_coredata__MOMC_OUTPUT_SUFFIX__xcdatamodeld__DefaultValue(xcconfigs, id_configs):
    # .momd
    return (False, ".momd")

def _com_apple_compilers_model_coredata__MOMC_OUTPUT_SUFFIX__xcdatamodel__DefaultValue(xcconfigs, id_configs):
    # .mom
    return (False, ".mom")

def _com_apple_compilers_model_coredata__DEPLOYMENT_TARGET__DefaultValue(xcconfigs, id_configs):
    # $($(DEPLOYMENT_TARGET_SETTING_NAME))

    used_user_content = False

    eval_val_0 = ""
    eval_key_0 = "DEPLOYMENT_TARGET_SETTING_NAME"
    if eval_key_0 in xcconfigs:
        eval_val_0 = xcconfigs[eval_key_0]
        used_user_content = True
    elif eval_key_0 in id_configs:
        opt = id_configs[eval_key_0]
        if "DefaultValue" in opt:
            (eval_val_0_used_user_content, eval_val_0) = XCSPEC_EVALS[opt["DefaultValue"]](xcconfigs, id_configs)
            used_user_content = used_user_content or eval_val_0_used_user_content

    eval_val_1 = ""
    eval_key_1 = eval_val_0
    if eval_key_1 in xcconfigs:
        eval_val_1 = xcconfigs[eval_key_1]
        used_user_content = True
    elif eval_key_1 in id_configs:
        opt = id_configs[eval_key_1]
        if "DefaultValue" in opt:
            (eval_val_1_used_user_content, eval_val_1) = XCSPEC_EVALS[opt["DefaultValue"]](xcconfigs, id_configs)
            used_user_content = used_user_content or eval_val_1_used_user_content

    return (used_user_content, eval_val_1)

def _com_apple_compilers_model_coredata__MOMC_NO_WARNINGS__DefaultValue(xcconfigs, id_configs):
    # NO
    return (False, "NO")

def _com_apple_compilers_model_coredata__MOMC_NO_INVERSE_RELATIONSHIP_WARNINGS__DefaultValue(xcconfigs, id_configs):
    # NO
    return (False, "NO")

def _com_apple_compilers_model_coredata__MOMC_NO_MAX_PROPERTY_COUNT_WARNINGS__DefaultValue(xcconfigs, id_configs):
    # NO
    return (False, "NO")

def _com_apple_compilers_model_coredata__MOMC_NO_DELETE_RULE_WARNINGS__DefaultValue(xcconfigs, id_configs):
    # NO
    return (False, "NO")

def _com_apple_compilers_model_coredata__MOMC_SUPPRESS_INVERSE_TRANSIENT_ERROR__DefaultValue(xcconfigs, id_configs):
    # NO
    return (False, "NO")

def _com_apple_compilers_model_coredata__MOMC_MODULE__DefaultValue(xcconfigs, id_configs):
    # $(PRODUCT_MODULE_NAME)

    used_user_content = False

    eval_val_0 = ""
    eval_key_0 = "PRODUCT_MODULE_NAME"
    if eval_key_0 in xcconfigs:
        eval_val_0 = xcconfigs[eval_key_0]
        used_user_content = True
    elif eval_key_0 in id_configs:
        opt = id_configs[eval_key_0]
        if "DefaultValue" in opt:
            (eval_val_0_used_user_content, eval_val_0) = XCSPEC_EVALS[opt["DefaultValue"]](xcconfigs, id_configs)
            used_user_content = used_user_content or eval_val_0_used_user_content

    return (used_user_content, eval_val_0)

def _com_apple_compilers_model_coredata__build_file_compiler_flags__DefaultValue(xcconfigs, id_configs):
    #
    return (False, "")

def _com_apple_compilers_model_coredatamapping__MAPC_NO_WARNINGS__DefaultValue(xcconfigs, id_configs):
    # NO
    return (False, "NO")

def _com_apple_compilers_model_coredatamapping__DEPLOYMENT_TARGET__DefaultValue(xcconfigs, id_configs):
    # $($(DEPLOYMENT_TARGET_SETTING_NAME))

    used_user_content = False

    eval_val_0 = ""
    eval_key_0 = "DEPLOYMENT_TARGET_SETTING_NAME"
    if eval_key_0 in xcconfigs:
        eval_val_0 = xcconfigs[eval_key_0]
        used_user_content = True
    elif eval_key_0 in id_configs:
        opt = id_configs[eval_key_0]
        if "DefaultValue" in opt:
            (eval_val_0_used_user_content, eval_val_0) = XCSPEC_EVALS[opt["DefaultValue"]](xcconfigs, id_configs)
            used_user_content = used_user_content or eval_val_0_used_user_content

    eval_val_1 = ""
    eval_key_1 = eval_val_0
    if eval_key_1 in xcconfigs:
        eval_val_1 = xcconfigs[eval_key_1]
        used_user_content = True
    elif eval_key_1 in id_configs:
        opt = id_configs[eval_key_1]
        if "DefaultValue" in opt:
            (eval_val_1_used_user_content, eval_val_1) = XCSPEC_EVALS[opt["DefaultValue"]](xcconfigs, id_configs)
            used_user_content = used_user_content or eval_val_1_used_user_content

    return (used_user_content, eval_val_1)

def _com_apple_compilers_model_coredatamapping__build_file_compiler_flags__DefaultValue(xcconfigs, id_configs):
    #
    return (False, "")

def _com_apple_compilers_model_coredatamapping__MAPC_MODULE__DefaultValue(xcconfigs, id_configs):
    # $(PRODUCT_MODULE_NAME)

    used_user_content = False

    eval_val_0 = ""
    eval_key_0 = "PRODUCT_MODULE_NAME"
    if eval_key_0 in xcconfigs:
        eval_val_0 = xcconfigs[eval_key_0]
        used_user_content = True
    elif eval_key_0 in id_configs:
        opt = id_configs[eval_key_0]
        if "DefaultValue" in opt:
            (eval_val_0_used_user_content, eval_val_0) = XCSPEC_EVALS[opt["DefaultValue"]](xcconfigs, id_configs)
            used_user_content = used_user_content or eval_val_0_used_user_content

    return (used_user_content, eval_val_0)

def _com_apple_pbx_linkers_ld__LD_DETERMINISTIC_MODE__DefaultValue(xcconfigs, id_configs):
    # YES
    return (False, "YES")

def _com_apple_pbx_linkers_ld__LD_TARGET_TRIPLE_ARCHS__DefaultValue(xcconfigs, id_configs):
    # $(CURRENT_ARCH)

    used_user_content = False

    eval_val_0 = ""
    eval_key_0 = "CURRENT_ARCH"
    if eval_key_0 in xcconfigs:
        eval_val_0 = xcconfigs[eval_key_0]
        used_user_content = True
    elif eval_key_0 in id_configs:
        opt = id_configs[eval_key_0]
        if "DefaultValue" in opt:
            (eval_val_0_used_user_content, eval_val_0) = XCSPEC_EVALS[opt["DefaultValue"]](xcconfigs, id_configs)
            used_user_content = used_user_content or eval_val_0_used_user_content

    return (used_user_content, eval_val_0)

def _com_apple_pbx_linkers_ld__LD_OPTIMIZATION_LEVEL__DefaultValue(xcconfigs, id_configs):
    # $(GCC_OPTIMIZATION_LEVEL)

    used_user_content = False

    eval_val_0 = ""
    eval_key_0 = "GCC_OPTIMIZATION_LEVEL"
    if eval_key_0 in xcconfigs:
        eval_val_0 = xcconfigs[eval_key_0]
        used_user_content = True
    elif eval_key_0 in id_configs:
        opt = id_configs[eval_key_0]
        if "DefaultValue" in opt:
            (eval_val_0_used_user_content, eval_val_0) = XCSPEC_EVALS[opt["DefaultValue"]](xcconfigs, id_configs)
            used_user_content = used_user_content or eval_val_0_used_user_content

    return (used_user_content, eval_val_0)

def _com_apple_pbx_linkers_ld__LD_SUPPRESS_WARNINGS__DefaultValue(xcconfigs, id_configs):
    # $(SUPPRESS_WARNINGS)

    used_user_content = False

    eval_val_0 = ""
    eval_key_0 = "SUPPRESS_WARNINGS"
    if eval_key_0 in xcconfigs:
        eval_val_0 = xcconfigs[eval_key_0]
        used_user_content = True
    elif eval_key_0 in id_configs:
        opt = id_configs[eval_key_0]
        if "DefaultValue" in opt:
            (eval_val_0_used_user_content, eval_val_0) = XCSPEC_EVALS[opt["DefaultValue"]](xcconfigs, id_configs)
            used_user_content = used_user_content or eval_val_0_used_user_content

    return (used_user_content, eval_val_0)

def _com_apple_pbx_linkers_ld____INPUT_FILE_LIST_PATH____DefaultValue(xcconfigs, id_configs):
    # $(LINK_FILE_LIST_$(variant)_$(arch))

    used_user_content = False

    eval_val_0 = ""
    eval_key_0 = "variant"
    if eval_key_0 in xcconfigs:
        eval_val_0 = xcconfigs[eval_key_0]
        used_user_content = True
    elif eval_key_0 in id_configs:
        opt = id_configs[eval_key_0]
        if "DefaultValue" in opt:
            (eval_val_0_used_user_content, eval_val_0) = XCSPEC_EVALS[opt["DefaultValue"]](xcconfigs, id_configs)
            used_user_content = used_user_content or eval_val_0_used_user_content

    eval_val_1 = ""
    eval_key_1 = "arch"
    if eval_key_1 in xcconfigs:
        eval_val_1 = xcconfigs[eval_key_1]
        used_user_content = True
    elif eval_key_1 in id_configs:
        opt = id_configs[eval_key_1]
        if "DefaultValue" in opt:
            (eval_val_1_used_user_content, eval_val_1) = XCSPEC_EVALS[opt["DefaultValue"]](xcconfigs, id_configs)
            used_user_content = used_user_content or eval_val_1_used_user_content

    eval_val_2 = ""
    eval_key_2 = "LINK_FILE_LIST_{eval_val_0}_{eval_val_1}".format(eval_val_0 = eval_val_0, eval_val_1 = eval_val_1)
    if eval_key_2 in xcconfigs:
        eval_val_2 = xcconfigs[eval_key_2]
        used_user_content = True
    elif eval_key_2 in id_configs:
        opt = id_configs[eval_key_2]
        if "DefaultValue" in opt:
            (eval_val_2_used_user_content, eval_val_2) = XCSPEC_EVALS[opt["DefaultValue"]](xcconfigs, id_configs)
            used_user_content = used_user_content or eval_val_2_used_user_content

    return (used_user_content, eval_val_2)

def _com_apple_pbx_linkers_ld__LINKER_DISPLAYS_MANGLED_NAMES__DefaultValue(xcconfigs, id_configs):
    # NO
    return (False, "NO")

def _com_apple_pbx_linkers_ld__LD_EXPORT_SYMBOLS__DefaultValue(xcconfigs, id_configs):
    # YES
    return (False, "YES")

def _com_apple_pbx_linkers_ld__EXPORTED_SYMBOLS_FILE__Condition(xcconfigs, id_configs):
    # !$(SEPARATE_SYMBOL_EDIT)

    used_user_content = False

    eval_val_0 = ""
    eval_key_0 = "SEPARATE_SYMBOL_EDIT"
    if eval_key_0 in xcconfigs:
        eval_val_0 = xcconfigs[eval_key_0]
        used_user_content = True
    elif eval_key_0 in id_configs:
        opt = id_configs[eval_key_0]
        if "DefaultValue" in opt:
            (eval_val_0_used_user_content, eval_val_0) = XCSPEC_EVALS[opt["DefaultValue"]](xcconfigs, id_configs)
            used_user_content = used_user_content or eval_val_0_used_user_content

    return (used_user_content, (not eval_val_0 == "YES"))

def _com_apple_pbx_linkers_ld__UNEXPORTED_SYMBOLS_FILE__Condition(xcconfigs, id_configs):
    # !$(SEPARATE_SYMBOL_EDIT)

    used_user_content = False

    eval_val_0 = ""
    eval_key_0 = "SEPARATE_SYMBOL_EDIT"
    if eval_key_0 in xcconfigs:
        eval_val_0 = xcconfigs[eval_key_0]
        used_user_content = True
    elif eval_key_0 in id_configs:
        opt = id_configs[eval_key_0]
        if "DefaultValue" in opt:
            (eval_val_0_used_user_content, eval_val_0) = XCSPEC_EVALS[opt["DefaultValue"]](xcconfigs, id_configs)
            used_user_content = used_user_content or eval_val_0_used_user_content

    return (used_user_content, (not eval_val_0 == "YES"))

def _com_apple_pbx_linkers_ld__GENERATE_PROFILING_CODE__Condition(xcconfigs, id_configs):
    # $(variant) == profile

    used_user_content = False

    eval_val_0 = ""
    eval_key_0 = "variant"
    if eval_key_0 in xcconfigs:
        eval_val_0 = xcconfigs[eval_key_0]
        used_user_content = True
    elif eval_key_0 in id_configs:
        opt = id_configs[eval_key_0]
        if "DefaultValue" in opt:
            (eval_val_0_used_user_content, eval_val_0) = XCSPEC_EVALS[opt["DefaultValue"]](xcconfigs, id_configs)
            used_user_content = used_user_content or eval_val_0_used_user_content

    return (used_user_content, (eval_val_0 == "profile"))

def _com_apple_pbx_linkers_ld__LD_NO_PIE__DefaultValue(xcconfigs, id_configs):
    # NO
    return (False, "NO")

def _com_apple_pbx_linkers_ld__LD_DYLIB_INSTALL_NAME__Condition(xcconfigs, id_configs):
    # $(MACH_O_TYPE) == mh_dylib

    used_user_content = False

    eval_val_0 = ""
    eval_key_0 = "MACH_O_TYPE"
    if eval_key_0 in xcconfigs:
        eval_val_0 = xcconfigs[eval_key_0]
        used_user_content = True
    elif eval_key_0 in id_configs:
        opt = id_configs[eval_key_0]
        if "DefaultValue" in opt:
            (eval_val_0_used_user_content, eval_val_0) = XCSPEC_EVALS[opt["DefaultValue"]](xcconfigs, id_configs)
            used_user_content = used_user_content or eval_val_0_used_user_content

    return (used_user_content, (eval_val_0 == "mh_dylib"))

def _com_apple_pbx_linkers_ld__LD_DYLIB_INSTALL_NAME__DefaultValue(xcconfigs, id_configs):
    #
    return (False, "")

def _com_apple_pbx_linkers_ld__LD_RUNPATH_SEARCH_PATHS__DefaultValue(xcconfigs, id_configs):
    #
    return (False, "")

def _com_apple_pbx_linkers_ld__LD_GENERATE_MAP_FILE__DefaultValue(xcconfigs, id_configs):
    # NO
    return (False, "NO")

def _com_apple_pbx_linkers_ld__LD_MAP_FILE_PATH__DefaultValue(xcconfigs, id_configs):
    # $(TARGET_TEMP_DIR)/$(PRODUCT_NAME)-LinkMap-$(CURRENT_VARIANT)-$(CURRENT_ARCH).txt

    used_user_content = False

    eval_val_0 = ""
    eval_key_0 = "TARGET_TEMP_DIR"
    if eval_key_0 in xcconfigs:
        eval_val_0 = xcconfigs[eval_key_0]
        used_user_content = True
    elif eval_key_0 in id_configs:
        opt = id_configs[eval_key_0]
        if "DefaultValue" in opt:
            (eval_val_0_used_user_content, eval_val_0) = XCSPEC_EVALS[opt["DefaultValue"]](xcconfigs, id_configs)
            used_user_content = used_user_content or eval_val_0_used_user_content

    eval_val_1 = ""
    eval_key_1 = "PRODUCT_NAME"
    if eval_key_1 in xcconfigs:
        eval_val_1 = xcconfigs[eval_key_1]
        used_user_content = True
    elif eval_key_1 in id_configs:
        opt = id_configs[eval_key_1]
        if "DefaultValue" in opt:
            (eval_val_1_used_user_content, eval_val_1) = XCSPEC_EVALS[opt["DefaultValue"]](xcconfigs, id_configs)
            used_user_content = used_user_content or eval_val_1_used_user_content

    eval_val_2 = ""
    eval_key_2 = "CURRENT_VARIANT"
    if eval_key_2 in xcconfigs:
        eval_val_2 = xcconfigs[eval_key_2]
        used_user_content = True
    elif eval_key_2 in id_configs:
        opt = id_configs[eval_key_2]
        if "DefaultValue" in opt:
            (eval_val_2_used_user_content, eval_val_2) = XCSPEC_EVALS[opt["DefaultValue"]](xcconfigs, id_configs)
            used_user_content = used_user_content or eval_val_2_used_user_content

    eval_val_3 = ""
    eval_key_3 = "CURRENT_ARCH"
    if eval_key_3 in xcconfigs:
        eval_val_3 = xcconfigs[eval_key_3]
        used_user_content = True
    elif eval_key_3 in id_configs:
        opt = id_configs[eval_key_3]
        if "DefaultValue" in opt:
            (eval_val_3_used_user_content, eval_val_3) = XCSPEC_EVALS[opt["DefaultValue"]](xcconfigs, id_configs)
            used_user_content = used_user_content or eval_val_3_used_user_content

    return (used_user_content, "{eval_val_0}/{eval_val_1}-LinkMap-{eval_val_2}-{eval_val_3}.txt".format(eval_val_0 = eval_val_0, eval_val_1 = eval_val_1, eval_val_2 = eval_val_2, eval_val_3 = eval_val_3))

def _com_apple_pbx_linkers_ld__LINK_WITH_STANDARD_LIBRARIES__DefaultValue(xcconfigs, id_configs):
    # YES
    return (False, "YES")

def _com_apple_pbx_linkers_ld__KEEP_PRIVATE_EXTERNS__DefaultValue(xcconfigs, id_configs):
    # NO
    return (False, "NO")

def _com_apple_pbx_linkers_ld__DEAD_CODE_STRIPPING__Condition(xcconfigs, id_configs):
    # $(MACH_O_TYPE) != mh_object

    used_user_content = False

    eval_val_0 = ""
    eval_key_0 = "MACH_O_TYPE"
    if eval_key_0 in xcconfigs:
        eval_val_0 = xcconfigs[eval_key_0]
        used_user_content = True
    elif eval_key_0 in id_configs:
        opt = id_configs[eval_key_0]
        if "DefaultValue" in opt:
            (eval_val_0_used_user_content, eval_val_0) = XCSPEC_EVALS[opt["DefaultValue"]](xcconfigs, id_configs)
            used_user_content = used_user_content or eval_val_0_used_user_content

    return (used_user_content, (eval_val_0 != "mh_object"))

def _com_apple_pbx_linkers_ld__DEAD_CODE_STRIPPING__DefaultValue(xcconfigs, id_configs):
    # NO
    return (False, "NO")

def _com_apple_pbx_linkers_ld__PRESERVE_DEAD_CODE_INITS_AND_TERMS__DefaultValue(xcconfigs, id_configs):
    # NO
    return (False, "NO")

def _com_apple_pbx_linkers_ld__BUNDLE_LOADER__DefaultValue(xcconfigs, id_configs):
    #
    return (False, "")

def _com_apple_pbx_linkers_ld__ORDER_FILE__DefaultValue(xcconfigs, id_configs):
    #
    return (False, "")

def _com_apple_pbx_linkers_ld__LD_LTO_OBJECT_FILE__Condition(xcconfigs, id_configs):
    # $(GCC_GENERATE_DEBUGGING_SYMBOLS)

    used_user_content = False

    eval_val_0 = ""
    eval_key_0 = "GCC_GENERATE_DEBUGGING_SYMBOLS"
    if eval_key_0 in xcconfigs:
        eval_val_0 = xcconfigs[eval_key_0]
        used_user_content = True
    elif eval_key_0 in id_configs:
        opt = id_configs[eval_key_0]
        if "DefaultValue" in opt:
            (eval_val_0_used_user_content, eval_val_0) = XCSPEC_EVALS[opt["DefaultValue"]](xcconfigs, id_configs)
            used_user_content = used_user_content or eval_val_0_used_user_content

    return (used_user_content, (eval_val_0 == "YES"))

def _com_apple_pbx_linkers_ld__LD_LTO_OBJECT_FILE__DefaultValue(xcconfigs, id_configs):
    # $(OBJECT_FILE_DIR_$(CURRENT_VARIANT))/$(CURRENT_ARCH)/$(PRODUCT_NAME)_lto.o

    used_user_content = False

    eval_val_0 = ""
    eval_key_0 = "CURRENT_VARIANT"
    if eval_key_0 in xcconfigs:
        eval_val_0 = xcconfigs[eval_key_0]
        used_user_content = True
    elif eval_key_0 in id_configs:
        opt = id_configs[eval_key_0]
        if "DefaultValue" in opt:
            (eval_val_0_used_user_content, eval_val_0) = XCSPEC_EVALS[opt["DefaultValue"]](xcconfigs, id_configs)
            used_user_content = used_user_content or eval_val_0_used_user_content

    eval_val_1 = ""
    eval_key_1 = "CURRENT_ARCH"
    if eval_key_1 in xcconfigs:
        eval_val_1 = xcconfigs[eval_key_1]
        used_user_content = True
    elif eval_key_1 in id_configs:
        opt = id_configs[eval_key_1]
        if "DefaultValue" in opt:
            (eval_val_1_used_user_content, eval_val_1) = XCSPEC_EVALS[opt["DefaultValue"]](xcconfigs, id_configs)
            used_user_content = used_user_content or eval_val_1_used_user_content

    eval_val_2 = ""
    eval_key_2 = "PRODUCT_NAME"
    if eval_key_2 in xcconfigs:
        eval_val_2 = xcconfigs[eval_key_2]
        used_user_content = True
    elif eval_key_2 in id_configs:
        opt = id_configs[eval_key_2]
        if "DefaultValue" in opt:
            (eval_val_2_used_user_content, eval_val_2) = XCSPEC_EVALS[opt["DefaultValue"]](xcconfigs, id_configs)
            used_user_content = used_user_content or eval_val_2_used_user_content

    eval_val_3 = ""
    eval_key_3 = "OBJECT_FILE_DIR_{eval_val_0}".format(eval_val_0 = eval_val_0)
    if eval_key_3 in xcconfigs:
        eval_val_3 = xcconfigs[eval_key_3]
        used_user_content = True
    elif eval_key_3 in id_configs:
        opt = id_configs[eval_key_3]
        if "DefaultValue" in opt:
            (eval_val_3_used_user_content, eval_val_3) = XCSPEC_EVALS[opt["DefaultValue"]](xcconfigs, id_configs)
            used_user_content = used_user_content or eval_val_3_used_user_content

    return (used_user_content, "{eval_val_3}/{eval_val_1}/{eval_val_2}_lto.o".format(eval_val_3 = eval_val_3, eval_val_1 = eval_val_1, eval_val_2 = eval_val_2))

def _com_apple_pbx_linkers_ld__LD_EXPORT_GLOBAL_SYMBOLS__DefaultValue(xcconfigs, id_configs):
    # NO
    return (False, "NO")

def _com_apple_pbx_linkers_ld__LD_DONT_RUN_DEDUPLICATION__Condition(xcconfigs, id_configs):
    # $(GCC_OPTIMIZATION_LEVEL) == '0'

    used_user_content = False

    eval_val_0 = ""
    eval_key_0 = "GCC_OPTIMIZATION_LEVEL"
    if eval_key_0 in xcconfigs:
        eval_val_0 = xcconfigs[eval_key_0]
        used_user_content = True
    elif eval_key_0 in id_configs:
        opt = id_configs[eval_key_0]
        if "DefaultValue" in opt:
            (eval_val_0_used_user_content, eval_val_0) = XCSPEC_EVALS[opt["DefaultValue"]](xcconfigs, id_configs)
            used_user_content = used_user_content or eval_val_0_used_user_content

    return (used_user_content, (eval_val_0 == "0"))

def _com_apple_pbx_linkers_ld__LD_DONT_RUN_DEDUPLICATION__DefaultValue(xcconfigs, id_configs):
    # YES
    return (False, "YES")

def _com_apple_pbx_linkers_ld__LD_OBJC_ABI_VERSION__DefaultValue(xcconfigs, id_configs):
    # $(OBJC_ABI_VERSION)

    used_user_content = False

    eval_val_0 = ""
    eval_key_0 = "OBJC_ABI_VERSION"
    if eval_key_0 in xcconfigs:
        eval_val_0 = xcconfigs[eval_key_0]
        used_user_content = True
    elif eval_key_0 in id_configs:
        opt = id_configs[eval_key_0]
        if "DefaultValue" in opt:
            (eval_val_0_used_user_content, eval_val_0) = XCSPEC_EVALS[opt["DefaultValue"]](xcconfigs, id_configs)
            used_user_content = used_user_content or eval_val_0_used_user_content

    return (used_user_content, eval_val_0)

def _com_apple_pbx_linkers_ld__LD_QUOTE_LINKER_ARGUMENTS_FOR_COMPILER_DRIVER__DefaultValue(xcconfigs, id_configs):
    # YES
    return (False, "YES")

def _com_apple_pbx_linkers_ld__LD_BITCODE_GENERATION_MODE__Condition(xcconfigs, id_configs):
    # $(ENABLE_BITCODE)

    used_user_content = False

    eval_val_0 = ""
    eval_key_0 = "ENABLE_BITCODE"
    if eval_key_0 in xcconfigs:
        eval_val_0 = xcconfigs[eval_key_0]
        used_user_content = True
    elif eval_key_0 in id_configs:
        opt = id_configs[eval_key_0]
        if "DefaultValue" in opt:
            (eval_val_0_used_user_content, eval_val_0) = XCSPEC_EVALS[opt["DefaultValue"]](xcconfigs, id_configs)
            used_user_content = used_user_content or eval_val_0_used_user_content

    return (used_user_content, (eval_val_0 == "YES"))

def _com_apple_pbx_linkers_ld__LD_BITCODE_GENERATION_MODE__DefaultValue(xcconfigs, id_configs):
    # $(BITCODE_GENERATION_MODE)

    used_user_content = False

    eval_val_0 = ""
    eval_key_0 = "BITCODE_GENERATION_MODE"
    if eval_key_0 in xcconfigs:
        eval_val_0 = xcconfigs[eval_key_0]
        used_user_content = True
    elif eval_key_0 in id_configs:
        opt = id_configs[eval_key_0]
        if "DefaultValue" in opt:
            (eval_val_0_used_user_content, eval_val_0) = XCSPEC_EVALS[opt["DefaultValue"]](xcconfigs, id_configs)
            used_user_content = used_user_content or eval_val_0_used_user_content

    return (used_user_content, eval_val_0)

def _com_apple_pbx_linkers_ld__LD_VERIFY_BITCODE__Condition(xcconfigs, id_configs):
    # $(ENABLE_BITCODE)  &&  $(BITCODE_GENERATION_MODE) == bitcode

    used_user_content = False

    eval_val_0 = ""
    eval_key_0 = "ENABLE_BITCODE"
    if eval_key_0 in xcconfigs:
        eval_val_0 = xcconfigs[eval_key_0]
        used_user_content = True
    elif eval_key_0 in id_configs:
        opt = id_configs[eval_key_0]
        if "DefaultValue" in opt:
            (eval_val_0_used_user_content, eval_val_0) = XCSPEC_EVALS[opt["DefaultValue"]](xcconfigs, id_configs)
            used_user_content = used_user_content or eval_val_0_used_user_content

    eval_val_1 = ""
    eval_key_1 = "BITCODE_GENERATION_MODE"
    if eval_key_1 in xcconfigs:
        eval_val_1 = xcconfigs[eval_key_1]
        used_user_content = True
    elif eval_key_1 in id_configs:
        opt = id_configs[eval_key_1]
        if "DefaultValue" in opt:
            (eval_val_1_used_user_content, eval_val_1) = XCSPEC_EVALS[opt["DefaultValue"]](xcconfigs, id_configs)
            used_user_content = used_user_content or eval_val_1_used_user_content

    return (used_user_content, (eval_val_0 == "YES" and eval_val_1 == "bitcode"))

def _com_apple_pbx_linkers_ld__LD_VERIFY_BITCODE__DefaultValue(xcconfigs, id_configs):
    # YES
    return (False, "YES")

def _com_apple_pbx_linkers_ld__LD_HIDE_BITCODE_SYMBOLS__Condition(xcconfigs, id_configs):
    # $(ENABLE_BITCODE)  &&  $(BITCODE_GENERATION_MODE) == bitcode  &&  $(MACH_O_TYPE) != mh_object

    used_user_content = False

    eval_val_0 = ""
    eval_key_0 = "ENABLE_BITCODE"
    if eval_key_0 in xcconfigs:
        eval_val_0 = xcconfigs[eval_key_0]
        used_user_content = True
    elif eval_key_0 in id_configs:
        opt = id_configs[eval_key_0]
        if "DefaultValue" in opt:
            (eval_val_0_used_user_content, eval_val_0) = XCSPEC_EVALS[opt["DefaultValue"]](xcconfigs, id_configs)
            used_user_content = used_user_content or eval_val_0_used_user_content

    eval_val_1 = ""
    eval_key_1 = "BITCODE_GENERATION_MODE"
    if eval_key_1 in xcconfigs:
        eval_val_1 = xcconfigs[eval_key_1]
        used_user_content = True
    elif eval_key_1 in id_configs:
        opt = id_configs[eval_key_1]
        if "DefaultValue" in opt:
            (eval_val_1_used_user_content, eval_val_1) = XCSPEC_EVALS[opt["DefaultValue"]](xcconfigs, id_configs)
            used_user_content = used_user_content or eval_val_1_used_user_content

    eval_val_2 = ""
    eval_key_2 = "MACH_O_TYPE"
    if eval_key_2 in xcconfigs:
        eval_val_2 = xcconfigs[eval_key_2]
        used_user_content = True
    elif eval_key_2 in id_configs:
        opt = id_configs[eval_key_2]
        if "DefaultValue" in opt:
            (eval_val_2_used_user_content, eval_val_2) = XCSPEC_EVALS[opt["DefaultValue"]](xcconfigs, id_configs)
            used_user_content = used_user_content or eval_val_2_used_user_content

    return (used_user_content, (eval_val_0 == "YES" and eval_val_1 == "bitcode" and eval_val_2 != "mh_object"))

def _com_apple_pbx_linkers_ld__LD_HIDE_BITCODE_SYMBOLS__DefaultValue(xcconfigs, id_configs):
    # $(HIDE_BITCODE_SYMBOLS)

    used_user_content = False

    eval_val_0 = ""
    eval_key_0 = "HIDE_BITCODE_SYMBOLS"
    if eval_key_0 in xcconfigs:
        eval_val_0 = xcconfigs[eval_key_0]
        used_user_content = True
    elif eval_key_0 in id_configs:
        opt = id_configs[eval_key_0]
        if "DefaultValue" in opt:
            (eval_val_0_used_user_content, eval_val_0) = XCSPEC_EVALS[opt["DefaultValue"]](xcconfigs, id_configs)
            used_user_content = used_user_content or eval_val_0_used_user_content

    return (used_user_content, eval_val_0)

def _com_apple_pbx_linkers_ld__LD_GENERATE_BITCODE_SYMBOL_MAP__Condition(xcconfigs, id_configs):
    # $(ENABLE_BITCODE)  &&  $(BITCODE_GENERATION_MODE) == bitcode  &&  $(MACH_O_TYPE) != mh_object

    used_user_content = False

    eval_val_0 = ""
    eval_key_0 = "ENABLE_BITCODE"
    if eval_key_0 in xcconfigs:
        eval_val_0 = xcconfigs[eval_key_0]
        used_user_content = True
    elif eval_key_0 in id_configs:
        opt = id_configs[eval_key_0]
        if "DefaultValue" in opt:
            (eval_val_0_used_user_content, eval_val_0) = XCSPEC_EVALS[opt["DefaultValue"]](xcconfigs, id_configs)
            used_user_content = used_user_content or eval_val_0_used_user_content

    eval_val_1 = ""
    eval_key_1 = "BITCODE_GENERATION_MODE"
    if eval_key_1 in xcconfigs:
        eval_val_1 = xcconfigs[eval_key_1]
        used_user_content = True
    elif eval_key_1 in id_configs:
        opt = id_configs[eval_key_1]
        if "DefaultValue" in opt:
            (eval_val_1_used_user_content, eval_val_1) = XCSPEC_EVALS[opt["DefaultValue"]](xcconfigs, id_configs)
            used_user_content = used_user_content or eval_val_1_used_user_content

    eval_val_2 = ""
    eval_key_2 = "MACH_O_TYPE"
    if eval_key_2 in xcconfigs:
        eval_val_2 = xcconfigs[eval_key_2]
        used_user_content = True
    elif eval_key_2 in id_configs:
        opt = id_configs[eval_key_2]
        if "DefaultValue" in opt:
            (eval_val_2_used_user_content, eval_val_2) = XCSPEC_EVALS[opt["DefaultValue"]](xcconfigs, id_configs)
            used_user_content = used_user_content or eval_val_2_used_user_content

    return (used_user_content, (eval_val_0 == "YES" and eval_val_1 == "bitcode" and eval_val_2 != "mh_object"))

def _com_apple_pbx_linkers_ld__LD_GENERATE_BITCODE_SYMBOL_MAP__DefaultValue(xcconfigs, id_configs):
    # $(HIDE_BITCODE_SYMBOLS)

    used_user_content = False

    eval_val_0 = ""
    eval_key_0 = "HIDE_BITCODE_SYMBOLS"
    if eval_key_0 in xcconfigs:
        eval_val_0 = xcconfigs[eval_key_0]
        used_user_content = True
    elif eval_key_0 in id_configs:
        opt = id_configs[eval_key_0]
        if "DefaultValue" in opt:
            (eval_val_0_used_user_content, eval_val_0) = XCSPEC_EVALS[opt["DefaultValue"]](xcconfigs, id_configs)
            used_user_content = used_user_content or eval_val_0_used_user_content

    return (used_user_content, eval_val_0)

def _com_apple_pbx_linkers_ld__LD_THREAD_SANITIZER__DefaultValue(xcconfigs, id_configs):
    # $(ENABLE_THREAD_SANITIZER)

    used_user_content = False

    eval_val_0 = ""
    eval_key_0 = "ENABLE_THREAD_SANITIZER"
    if eval_key_0 in xcconfigs:
        eval_val_0 = xcconfigs[eval_key_0]
        used_user_content = True
    elif eval_key_0 in id_configs:
        opt = id_configs[eval_key_0]
        if "DefaultValue" in opt:
            (eval_val_0_used_user_content, eval_val_0) = XCSPEC_EVALS[opt["DefaultValue"]](xcconfigs, id_configs)
            used_user_content = used_user_content or eval_val_0_used_user_content

    return (used_user_content, eval_val_0)

def _com_apple_pbx_linkers_ld__LD_DEBUG_VARIANT__Condition(xcconfigs, id_configs):
    # $(ENABLE_ADDRESS_SANITIZER) || $(ENABLE_THREAD_SANITIZER) || $(ENABLE_SANITIZER_COVERAGE) || $(ENABLE_UNDEFINED_BEHAVIOR_SANITIZER) || $(CLANG_COVERAGE_MAPPING)

    used_user_content = False

    eval_val_0 = ""
    eval_key_0 = "ENABLE_ADDRESS_SANITIZER"
    if eval_key_0 in xcconfigs:
        eval_val_0 = xcconfigs[eval_key_0]
        used_user_content = True
    elif eval_key_0 in id_configs:
        opt = id_configs[eval_key_0]
        if "DefaultValue" in opt:
            (eval_val_0_used_user_content, eval_val_0) = XCSPEC_EVALS[opt["DefaultValue"]](xcconfigs, id_configs)
            used_user_content = used_user_content or eval_val_0_used_user_content

    eval_val_1 = ""
    eval_key_1 = "ENABLE_THREAD_SANITIZER"
    if eval_key_1 in xcconfigs:
        eval_val_1 = xcconfigs[eval_key_1]
        used_user_content = True
    elif eval_key_1 in id_configs:
        opt = id_configs[eval_key_1]
        if "DefaultValue" in opt:
            (eval_val_1_used_user_content, eval_val_1) = XCSPEC_EVALS[opt["DefaultValue"]](xcconfigs, id_configs)
            used_user_content = used_user_content or eval_val_1_used_user_content

    eval_val_2 = ""
    eval_key_2 = "ENABLE_SANITIZER_COVERAGE"
    if eval_key_2 in xcconfigs:
        eval_val_2 = xcconfigs[eval_key_2]
        used_user_content = True
    elif eval_key_2 in id_configs:
        opt = id_configs[eval_key_2]
        if "DefaultValue" in opt:
            (eval_val_2_used_user_content, eval_val_2) = XCSPEC_EVALS[opt["DefaultValue"]](xcconfigs, id_configs)
            used_user_content = used_user_content or eval_val_2_used_user_content

    eval_val_3 = ""
    eval_key_3 = "ENABLE_UNDEFINED_BEHAVIOR_SANITIZER"
    if eval_key_3 in xcconfigs:
        eval_val_3 = xcconfigs[eval_key_3]
        used_user_content = True
    elif eval_key_3 in id_configs:
        opt = id_configs[eval_key_3]
        if "DefaultValue" in opt:
            (eval_val_3_used_user_content, eval_val_3) = XCSPEC_EVALS[opt["DefaultValue"]](xcconfigs, id_configs)
            used_user_content = used_user_content or eval_val_3_used_user_content

    eval_val_4 = ""
    eval_key_4 = "CLANG_COVERAGE_MAPPING"
    if eval_key_4 in xcconfigs:
        eval_val_4 = xcconfigs[eval_key_4]
        used_user_content = True
    elif eval_key_4 in id_configs:
        opt = id_configs[eval_key_4]
        if "DefaultValue" in opt:
            (eval_val_4_used_user_content, eval_val_4) = XCSPEC_EVALS[opt["DefaultValue"]](xcconfigs, id_configs)
            used_user_content = used_user_content or eval_val_4_used_user_content

    return (used_user_content, (eval_val_0 == "YES" or eval_val_1 == "YES" or eval_val_2 == "YES" or eval_val_3 == "YES" or eval_val_4 == "YES"))

def _com_apple_pbx_linkers_ld__LD_DEBUG_VARIANT__DefaultValue(xcconfigs, id_configs):
    # YES
    return (False, "YES")

def _com_apple_pbx_linkers_ld__LD_FINAL_OUTPUT_FILE__Condition(xcconfigs, id_configs):
    # $(DEPLOYMENT_POSTPROCESSING)  &&  !$(SKIP_INSTALL)  &&  $(INSTALL_PATH) != ""

    used_user_content = False

    eval_val_0 = ""
    eval_key_0 = "DEPLOYMENT_POSTPROCESSING"
    if eval_key_0 in xcconfigs:
        eval_val_0 = xcconfigs[eval_key_0]
        used_user_content = True
    elif eval_key_0 in id_configs:
        opt = id_configs[eval_key_0]
        if "DefaultValue" in opt:
            (eval_val_0_used_user_content, eval_val_0) = XCSPEC_EVALS[opt["DefaultValue"]](xcconfigs, id_configs)
            used_user_content = used_user_content or eval_val_0_used_user_content

    eval_val_1 = ""
    eval_key_1 = "SKIP_INSTALL"
    if eval_key_1 in xcconfigs:
        eval_val_1 = xcconfigs[eval_key_1]
        used_user_content = True
    elif eval_key_1 in id_configs:
        opt = id_configs[eval_key_1]
        if "DefaultValue" in opt:
            (eval_val_1_used_user_content, eval_val_1) = XCSPEC_EVALS[opt["DefaultValue"]](xcconfigs, id_configs)
            used_user_content = used_user_content or eval_val_1_used_user_content

    eval_val_2 = ""
    eval_key_2 = "INSTALL_PATH"
    if eval_key_2 in xcconfigs:
        eval_val_2 = xcconfigs[eval_key_2]
        used_user_content = True
    elif eval_key_2 in id_configs:
        opt = id_configs[eval_key_2]
        if "DefaultValue" in opt:
            (eval_val_2_used_user_content, eval_val_2) = XCSPEC_EVALS[opt["DefaultValue"]](xcconfigs, id_configs)
            used_user_content = used_user_content or eval_val_2_used_user_content

    return (used_user_content, (eval_val_0 == "YES" and not eval_val_1 == "YES" and eval_val_2 != ""))

def _com_apple_pbx_linkers_ld__LD_FINAL_OUTPUT_FILE__DefaultValue(xcconfigs, id_configs):
    # $(INSTALL_PATH)/$(EXECUTABLE_PATH)

    used_user_content = False

    eval_val_0 = ""
    eval_key_0 = "INSTALL_PATH"
    if eval_key_0 in xcconfigs:
        eval_val_0 = xcconfigs[eval_key_0]
        used_user_content = True
    elif eval_key_0 in id_configs:
        opt = id_configs[eval_key_0]
        if "DefaultValue" in opt:
            (eval_val_0_used_user_content, eval_val_0) = XCSPEC_EVALS[opt["DefaultValue"]](xcconfigs, id_configs)
            used_user_content = used_user_content or eval_val_0_used_user_content

    eval_val_1 = ""
    eval_key_1 = "EXECUTABLE_PATH"
    if eval_key_1 in xcconfigs:
        eval_val_1 = xcconfigs[eval_key_1]
        used_user_content = True
    elif eval_key_1 in id_configs:
        opt = id_configs[eval_key_1]
        if "DefaultValue" in opt:
            (eval_val_1_used_user_content, eval_val_1) = XCSPEC_EVALS[opt["DefaultValue"]](xcconfigs, id_configs)
            used_user_content = used_user_content or eval_val_1_used_user_content

    return (used_user_content, "{eval_val_0}/{eval_val_1}".format(eval_val_0 = eval_val_0, eval_val_1 = eval_val_1))

def _com_apple_pbx_linkers_ld__LD_DEPENDENCY_INFO_FILE__DefaultValue(xcconfigs, id_configs):
    # $(OBJECT_FILE_DIR_$(CURRENT_VARIANT))/$(CURRENT_ARCH)/$(PRODUCT_NAME)_dependency_info.dat

    used_user_content = False

    eval_val_0 = ""
    eval_key_0 = "CURRENT_VARIANT"
    if eval_key_0 in xcconfigs:
        eval_val_0 = xcconfigs[eval_key_0]
        used_user_content = True
    elif eval_key_0 in id_configs:
        opt = id_configs[eval_key_0]
        if "DefaultValue" in opt:
            (eval_val_0_used_user_content, eval_val_0) = XCSPEC_EVALS[opt["DefaultValue"]](xcconfigs, id_configs)
            used_user_content = used_user_content or eval_val_0_used_user_content

    eval_val_1 = ""
    eval_key_1 = "CURRENT_ARCH"
    if eval_key_1 in xcconfigs:
        eval_val_1 = xcconfigs[eval_key_1]
        used_user_content = True
    elif eval_key_1 in id_configs:
        opt = id_configs[eval_key_1]
        if "DefaultValue" in opt:
            (eval_val_1_used_user_content, eval_val_1) = XCSPEC_EVALS[opt["DefaultValue"]](xcconfigs, id_configs)
            used_user_content = used_user_content or eval_val_1_used_user_content

    eval_val_2 = ""
    eval_key_2 = "PRODUCT_NAME"
    if eval_key_2 in xcconfigs:
        eval_val_2 = xcconfigs[eval_key_2]
        used_user_content = True
    elif eval_key_2 in id_configs:
        opt = id_configs[eval_key_2]
        if "DefaultValue" in opt:
            (eval_val_2_used_user_content, eval_val_2) = XCSPEC_EVALS[opt["DefaultValue"]](xcconfigs, id_configs)
            used_user_content = used_user_content or eval_val_2_used_user_content

    eval_val_3 = ""
    eval_key_3 = "OBJECT_FILE_DIR_{eval_val_0}".format(eval_val_0 = eval_val_0)
    if eval_key_3 in xcconfigs:
        eval_val_3 = xcconfigs[eval_key_3]
        used_user_content = True
    elif eval_key_3 in id_configs:
        opt = id_configs[eval_key_3]
        if "DefaultValue" in opt:
            (eval_val_3_used_user_content, eval_val_3) = XCSPEC_EVALS[opt["DefaultValue"]](xcconfigs, id_configs)
            used_user_content = used_user_content or eval_val_3_used_user_content

    return (used_user_content, "{eval_val_3}/{eval_val_1}/{eval_val_2}_dependency_info.dat".format(eval_val_3 = eval_val_3, eval_val_1 = eval_val_1, eval_val_2 = eval_val_2))

def _com_apple_pbx_linkers_ld__CLANG_ARC_MIGRATE_PRECHECK__DefaultValue(xcconfigs, id_configs):
    # donothing
    return (False, "donothing")

def _com_apple_pbx_linkers_ld__LD_DYLIB_ALLOWABLE_CLIENTS__DefaultValue(xcconfigs, id_configs):
    #
    return (False, "")

def _com_apple_pbx_linkers_ld__LD_MAKE_MERGEABLE__DefaultValue(xcconfigs, id_configs):
    # $(MAKE_MERGEABLE)

    used_user_content = False

    eval_val_0 = ""
    eval_key_0 = "MAKE_MERGEABLE"
    if eval_key_0 in xcconfigs:
        eval_val_0 = xcconfigs[eval_key_0]
        used_user_content = True
    elif eval_key_0 in id_configs:
        opt = id_configs[eval_key_0]
        if "DefaultValue" in opt:
            (eval_val_0_used_user_content, eval_val_0) = XCSPEC_EVALS[opt["DefaultValue"]](xcconfigs, id_configs)
            used_user_content = used_user_content or eval_val_0_used_user_content

    return (used_user_content, eval_val_0)

def _com_apple_pbx_linkers_ld__LD_ENTRY_POINT__Condition(xcconfigs, id_configs):
    # $(MACH_O_TYPE) == mh_execute

    used_user_content = False

    eval_val_0 = ""
    eval_key_0 = "MACH_O_TYPE"
    if eval_key_0 in xcconfigs:
        eval_val_0 = xcconfigs[eval_key_0]
        used_user_content = True
    elif eval_key_0 in id_configs:
        opt = id_configs[eval_key_0]
        if "DefaultValue" in opt:
            (eval_val_0_used_user_content, eval_val_0) = XCSPEC_EVALS[opt["DefaultValue"]](xcconfigs, id_configs)
            used_user_content = used_user_content or eval_val_0_used_user_content

    return (used_user_content, (eval_val_0 == "mh_execute"))

def _com_apple_pbx_linkers_ld__ALL_OTHER_LDFLAGS__Condition(xcconfigs, id_configs):
    # $(MACH_O_TYPE) != mh_object

    used_user_content = False

    eval_val_0 = ""
    eval_key_0 = "MACH_O_TYPE"
    if eval_key_0 in xcconfigs:
        eval_val_0 = xcconfigs[eval_key_0]
        used_user_content = True
    elif eval_key_0 in id_configs:
        opt = id_configs[eval_key_0]
        if "DefaultValue" in opt:
            (eval_val_0_used_user_content, eval_val_0) = XCSPEC_EVALS[opt["DefaultValue"]](xcconfigs, id_configs)
            used_user_content = used_user_content or eval_val_0_used_user_content

    return (used_user_content, (eval_val_0 != "mh_object"))

def _com_apple_pbx_linkers_ld__ALL_OTHER_LDFLAGS__DefaultValue(xcconfigs, id_configs):
    # $(LD_FLAGS) $(SECTORDER_FLAGS) $(OTHER_LDFLAGS) $(OTHER_LDFLAGS_$(variant)) $(OTHER_LDFLAGS_$(arch)) $(OTHER_LDFLAGS_$(variant)_$(arch)) $(PRODUCT_SPECIFIC_LDFLAGS)

    used_user_content = False

    eval_val_0 = ""
    eval_key_0 = "LD_FLAGS"
    if eval_key_0 in xcconfigs:
        eval_val_0 = xcconfigs[eval_key_0]
        used_user_content = True
    elif eval_key_0 in id_configs:
        opt = id_configs[eval_key_0]
        if "DefaultValue" in opt:
            (eval_val_0_used_user_content, eval_val_0) = XCSPEC_EVALS[opt["DefaultValue"]](xcconfigs, id_configs)
            used_user_content = used_user_content or eval_val_0_used_user_content

    eval_val_1 = ""
    eval_key_1 = "SECTORDER_FLAGS"
    if eval_key_1 in xcconfigs:
        eval_val_1 = xcconfigs[eval_key_1]
        used_user_content = True
    elif eval_key_1 in id_configs:
        opt = id_configs[eval_key_1]
        if "DefaultValue" in opt:
            (eval_val_1_used_user_content, eval_val_1) = XCSPEC_EVALS[opt["DefaultValue"]](xcconfigs, id_configs)
            used_user_content = used_user_content or eval_val_1_used_user_content

    eval_val_2 = ""
    eval_key_2 = "OTHER_LDFLAGS"
    if eval_key_2 in xcconfigs:
        eval_val_2 = xcconfigs[eval_key_2]
        used_user_content = True
    elif eval_key_2 in id_configs:
        opt = id_configs[eval_key_2]
        if "DefaultValue" in opt:
            (eval_val_2_used_user_content, eval_val_2) = XCSPEC_EVALS[opt["DefaultValue"]](xcconfigs, id_configs)
            used_user_content = used_user_content or eval_val_2_used_user_content

    eval_val_3 = ""
    eval_key_3 = "variant"
    if eval_key_3 in xcconfigs:
        eval_val_3 = xcconfigs[eval_key_3]
        used_user_content = True
    elif eval_key_3 in id_configs:
        opt = id_configs[eval_key_3]
        if "DefaultValue" in opt:
            (eval_val_3_used_user_content, eval_val_3) = XCSPEC_EVALS[opt["DefaultValue"]](xcconfigs, id_configs)
            used_user_content = used_user_content or eval_val_3_used_user_content

    eval_val_4 = ""
    eval_key_4 = "arch"
    if eval_key_4 in xcconfigs:
        eval_val_4 = xcconfigs[eval_key_4]
        used_user_content = True
    elif eval_key_4 in id_configs:
        opt = id_configs[eval_key_4]
        if "DefaultValue" in opt:
            (eval_val_4_used_user_content, eval_val_4) = XCSPEC_EVALS[opt["DefaultValue"]](xcconfigs, id_configs)
            used_user_content = used_user_content or eval_val_4_used_user_content

    eval_val_5 = ""
    eval_key_5 = "PRODUCT_SPECIFIC_LDFLAGS"
    if eval_key_5 in xcconfigs:
        eval_val_5 = xcconfigs[eval_key_5]
        used_user_content = True
    elif eval_key_5 in id_configs:
        opt = id_configs[eval_key_5]
        if "DefaultValue" in opt:
            (eval_val_5_used_user_content, eval_val_5) = XCSPEC_EVALS[opt["DefaultValue"]](xcconfigs, id_configs)
            used_user_content = used_user_content or eval_val_5_used_user_content

    eval_val_6 = ""
    eval_key_6 = "OTHER_LDFLAGS_{eval_val_3}".format(eval_val_3 = eval_val_3)
    if eval_key_6 in xcconfigs:
        eval_val_6 = xcconfigs[eval_key_6]
        used_user_content = True
    elif eval_key_6 in id_configs:
        opt = id_configs[eval_key_6]
        if "DefaultValue" in opt:
            (eval_val_6_used_user_content, eval_val_6) = XCSPEC_EVALS[opt["DefaultValue"]](xcconfigs, id_configs)
            used_user_content = used_user_content or eval_val_6_used_user_content

    eval_val_7 = ""
    eval_key_7 = "OTHER_LDFLAGS_{eval_val_4}".format(eval_val_4 = eval_val_4)
    if eval_key_7 in xcconfigs:
        eval_val_7 = xcconfigs[eval_key_7]
        used_user_content = True
    elif eval_key_7 in id_configs:
        opt = id_configs[eval_key_7]
        if "DefaultValue" in opt:
            (eval_val_7_used_user_content, eval_val_7) = XCSPEC_EVALS[opt["DefaultValue"]](xcconfigs, id_configs)
            used_user_content = used_user_content or eval_val_7_used_user_content

    eval_val_8 = ""
    eval_key_8 = "OTHER_LDFLAGS_{eval_val_3}_{eval_val_4}".format(eval_val_3 = eval_val_3, eval_val_4 = eval_val_4)
    if eval_key_8 in xcconfigs:
        eval_val_8 = xcconfigs[eval_key_8]
        used_user_content = True
    elif eval_key_8 in id_configs:
        opt = id_configs[eval_key_8]
        if "DefaultValue" in opt:
            (eval_val_8_used_user_content, eval_val_8) = XCSPEC_EVALS[opt["DefaultValue"]](xcconfigs, id_configs)
            used_user_content = used_user_content or eval_val_8_used_user_content

    return (used_user_content, "{eval_val_0} {eval_val_1} {eval_val_2} {eval_val_6} {eval_val_7} {eval_val_8} {eval_val_5}".format(eval_val_0 = eval_val_0, eval_val_1 = eval_val_1, eval_val_2 = eval_val_2, eval_val_6 = eval_val_6, eval_val_7 = eval_val_7, eval_val_8 = eval_val_8, eval_val_5 = eval_val_5))

def _com_apple_pbx_linkers_ld__OTHER_LDRFLAGS__Condition(xcconfigs, id_configs):
    # $(MACH_O_TYPE) == mh_object

    used_user_content = False

    eval_val_0 = ""
    eval_key_0 = "MACH_O_TYPE"
    if eval_key_0 in xcconfigs:
        eval_val_0 = xcconfigs[eval_key_0]
        used_user_content = True
    elif eval_key_0 in id_configs:
        opt = id_configs[eval_key_0]
        if "DefaultValue" in opt:
            (eval_val_0_used_user_content, eval_val_0) = XCSPEC_EVALS[opt["DefaultValue"]](xcconfigs, id_configs)
            used_user_content = used_user_content or eval_val_0_used_user_content

    return (used_user_content, (eval_val_0 == "mh_object"))

def _com_apple_pbx_linkers_ld__OTHER_LDRFLAGS__DefaultValue(xcconfigs, id_configs):
    # $(OTHER_LDFLAGS)

    used_user_content = False

    eval_val_0 = ""
    eval_key_0 = "OTHER_LDFLAGS"
    if eval_key_0 in xcconfigs:
        eval_val_0 = xcconfigs[eval_key_0]
        used_user_content = True
    elif eval_key_0 in id_configs:
        opt = id_configs[eval_key_0]
        if "DefaultValue" in opt:
            (eval_val_0_used_user_content, eval_val_0) = XCSPEC_EVALS[opt["DefaultValue"]](xcconfigs, id_configs)
            used_user_content = used_user_content or eval_val_0_used_user_content

    return (used_user_content, eval_val_0)

def _com_apple_xcode_tools_ibtool_compiler__IBC_EXEC__DefaultValue(xcconfigs, id_configs):
    # ibtool
    return (False, "ibtool")

def _com_apple_xcode_tools_ibtool_compiler__IBC_FLATTEN_NIBS__DefaultValue(xcconfigs, id_configs):
    # YES
    return (False, "YES")

def _com_apple_xcode_tools_ibtool_compiler__IBC_ERRORS__DefaultValue(xcconfigs, id_configs):
    # YES
    return (False, "YES")

def _com_apple_xcode_tools_ibtool_compiler__IBC_WARNINGS__DefaultValue(xcconfigs, id_configs):
    # YES
    return (False, "YES")

def _com_apple_xcode_tools_ibtool_compiler__IBC_NOTICES__DefaultValue(xcconfigs, id_configs):
    # YES
    return (False, "YES")

def _com_apple_xcode_tools_ibtool_compiler__IBC_OTHER_FLAGS__DefaultValue(xcconfigs, id_configs):
    #
    return (False, "")

def _com_apple_xcode_tools_ibtool_compiler__IBC_PLUGINS__DefaultValue(xcconfigs, id_configs):
    #
    return (False, "")

def _com_apple_xcode_tools_ibtool_compiler__IBC_REGIONS_AND_STRINGS_FILES__DefaultValue(xcconfigs, id_configs):
    #
    return (False, "")

def _com_apple_xcode_tools_ibtool_compiler__IBC_PLUGIN_SEARCH_PATHS__DefaultValue(xcconfigs, id_configs):
    #
    return (False, "")

def _com_apple_xcode_tools_ibtool_compiler__IBC_MODULE__DefaultValue(xcconfigs, id_configs):
    # $(PRODUCT_MODULE_NAME)

    used_user_content = False

    eval_val_0 = ""
    eval_key_0 = "PRODUCT_MODULE_NAME"
    if eval_key_0 in xcconfigs:
        eval_val_0 = xcconfigs[eval_key_0]
        used_user_content = True
    elif eval_key_0 in id_configs:
        opt = id_configs[eval_key_0]
        if "DefaultValue" in opt:
            (eval_val_0_used_user_content, eval_val_0) = XCSPEC_EVALS[opt["DefaultValue"]](xcconfigs, id_configs)
            used_user_content = used_user_content or eval_val_0_used_user_content

    return (used_user_content, eval_val_0)

def _com_apple_xcode_tools_ibtool_compiler__build_file_compiler_flags__DefaultValue(xcconfigs, id_configs):
    #
    return (False, "")

def _com_apple_xcode_tools_ibtool_compiler__XIB_COMPILER_INFOPLIST_CONTENT_FILE__DefaultValue(xcconfigs, id_configs):
    # $(TARGET_TEMP_DIR)/$(InputFileRegionPathComponent)$(InputFileBase)-PartialInfo.plist

    used_user_content = False

    eval_val_0 = ""
    eval_key_0 = "TARGET_TEMP_DIR"
    if eval_key_0 in xcconfigs:
        eval_val_0 = xcconfigs[eval_key_0]
        used_user_content = True
    elif eval_key_0 in id_configs:
        opt = id_configs[eval_key_0]
        if "DefaultValue" in opt:
            (eval_val_0_used_user_content, eval_val_0) = XCSPEC_EVALS[opt["DefaultValue"]](xcconfigs, id_configs)
            used_user_content = used_user_content or eval_val_0_used_user_content

    eval_val_1 = ""
    eval_key_1 = "InputFileRegionPathComponent"
    if eval_key_1 in xcconfigs:
        eval_val_1 = xcconfigs[eval_key_1]
        used_user_content = True
    elif eval_key_1 in id_configs:
        opt = id_configs[eval_key_1]
        if "DefaultValue" in opt:
            (eval_val_1_used_user_content, eval_val_1) = XCSPEC_EVALS[opt["DefaultValue"]](xcconfigs, id_configs)
            used_user_content = used_user_content or eval_val_1_used_user_content

    eval_val_2 = ""
    eval_key_2 = "InputFileBase"
    if eval_key_2 in xcconfigs:
        eval_val_2 = xcconfigs[eval_key_2]
        used_user_content = True
    elif eval_key_2 in id_configs:
        opt = id_configs[eval_key_2]
        if "DefaultValue" in opt:
            (eval_val_2_used_user_content, eval_val_2) = XCSPEC_EVALS[opt["DefaultValue"]](xcconfigs, id_configs)
            used_user_content = used_user_content or eval_val_2_used_user_content

    return (used_user_content, "{eval_val_0}/{eval_val_1}{eval_val_2}-PartialInfo.plist".format(eval_val_0 = eval_val_0, eval_val_1 = eval_val_1, eval_val_2 = eval_val_2))

def _com_apple_xcode_tools_ibtool_compiler__IBC_COMPILER_AUTO_ACTIVATE_CUSTOM_FONTS__DefaultValue(xcconfigs, id_configs):
    # YES
    return (False, "YES")

def _com_apple_xcode_tools_ibtool_compiler__IBC_COMPILER_USE_NIBKEYEDARCHIVER_FOR_MACOS__DefaultValue(xcconfigs, id_configs):
    # NO
    return (False, "NO")

def _com_apple_xcode_tools_swift_compiler__SWIFT_EXEC__DefaultValue(xcconfigs, id_configs):
    # swiftc
    return (False, "swiftc")

def _com_apple_xcode_tools_swift_compiler__SWIFT_LIBRARIES_ONLY__DefaultValue(xcconfigs, id_configs):
    # NO
    return (False, "NO")

def _com_apple_xcode_tools_swift_compiler__SWIFT_ENABLE_INCREMENTAL_COMPILATION__DefaultValue(xcconfigs, id_configs):
    # YES
    return (False, "YES")

def _com_apple_xcode_tools_swift_compiler__SWIFT_CROSS_MODULE_OPTIMIZATION__DefaultValue(xcconfigs, id_configs):
    # NO
    return (False, "NO")

def _com_apple_xcode_tools_swift_compiler__SWIFT_PRECOMPILE_BRIDGING_HEADER__DefaultValue(xcconfigs, id_configs):
    # YES
    return (False, "YES")

def _com_apple_xcode_tools_swift_compiler__SWIFT_USE_PARALLEL_WHOLE_MODULE_OPTIMIZATION__DefaultValue(xcconfigs, id_configs):
    # YES
    return (False, "YES")

def _com_apple_xcode_tools_swift_compiler__SWIFT_USE_PARALLEL_WMO_TARGETS__DefaultValue(xcconfigs, id_configs):
    # YES
    return (False, "YES")

def _com_apple_xcode_tools_swift_compiler__SWIFT_WHOLE_MODULE_OPTIMIZATION__DefaultValue(xcconfigs, id_configs):
    # NO
    return (False, "NO")

def _com_apple_xcode_tools_swift_compiler__SWIFT_LIBRARY_PATH__DefaultValue(xcconfigs, id_configs):
    #
    return (False, "")

def _com_apple_xcode_tools_swift_compiler__SWIFT_MODULE_NAME__DefaultValue(xcconfigs, id_configs):
    # $(PRODUCT_MODULE_NAME)

    used_user_content = False

    eval_val_0 = ""
    eval_key_0 = "PRODUCT_MODULE_NAME"
    if eval_key_0 in xcconfigs:
        eval_val_0 = xcconfigs[eval_key_0]
        used_user_content = True
    elif eval_key_0 in id_configs:
        opt = id_configs[eval_key_0]
        if "DefaultValue" in opt:
            (eval_val_0_used_user_content, eval_val_0) = XCSPEC_EVALS[opt["DefaultValue"]](xcconfigs, id_configs)
            used_user_content = used_user_content or eval_val_0_used_user_content

    return (used_user_content, eval_val_0)

def _com_apple_xcode_tools_swift_compiler__SWIFT_MODULE_ALIASES__DefaultValue(xcconfigs, id_configs):
    #
    return (False, "")

def _com_apple_xcode_tools_swift_compiler__SWIFT_OBJC_BRIDGING_HEADER__DefaultValue(xcconfigs, id_configs):
    #
    return (False, "")

def _com_apple_xcode_tools_swift_compiler__SWIFT_OBJC_INTERFACE_HEADER_NAME__DefaultValue(xcconfigs, id_configs):
    # $(SWIFT_MODULE_NAME)-Swift.h

    used_user_content = False

    eval_val_0 = ""
    eval_key_0 = "SWIFT_MODULE_NAME"
    if eval_key_0 in xcconfigs:
        eval_val_0 = xcconfigs[eval_key_0]
        used_user_content = True
    elif eval_key_0 in id_configs:
        opt = id_configs[eval_key_0]
        if "DefaultValue" in opt:
            (eval_val_0_used_user_content, eval_val_0) = XCSPEC_EVALS[opt["DefaultValue"]](xcconfigs, id_configs)
            used_user_content = used_user_content or eval_val_0_used_user_content

    return (used_user_content, "{eval_val_0}-Swift.h".format(eval_val_0 = eval_val_0))

def _com_apple_xcode_tools_swift_compiler__SWIFT_INSTALL_OBJC_HEADER__DefaultValue(xcconfigs, id_configs):
    # YES
    return (False, "YES")

def _com_apple_xcode_tools_swift_compiler__SWIFT_INSTALL_MODULE__DefaultValue(xcconfigs, id_configs):
    # YES
    return (False, "YES")

def _com_apple_xcode_tools_swift_compiler__SWIFT_OPTIMIZATION_LEVEL__DefaultValue(xcconfigs, id_configs):
    # -O
    return (False, "-O")

def _com_apple_xcode_tools_swift_compiler__SWIFT_COMPILATION_MODE__Condition(xcconfigs, id_configs):
    # !$(SWIFT_WHOLE_MODULE_OPTIMIZATION) && $(SWIFT_OPTIMIZATION_LEVEL) != '-Owholemodule'

    used_user_content = False

    eval_val_0 = ""
    eval_key_0 = "SWIFT_WHOLE_MODULE_OPTIMIZATION"
    if eval_key_0 in xcconfigs:
        eval_val_0 = xcconfigs[eval_key_0]
        used_user_content = True
    elif eval_key_0 in id_configs:
        opt = id_configs[eval_key_0]
        if "DefaultValue" in opt:
            (eval_val_0_used_user_content, eval_val_0) = XCSPEC_EVALS[opt["DefaultValue"]](xcconfigs, id_configs)
            used_user_content = used_user_content or eval_val_0_used_user_content

    eval_val_1 = ""
    eval_key_1 = "SWIFT_OPTIMIZATION_LEVEL"
    if eval_key_1 in xcconfigs:
        eval_val_1 = xcconfigs[eval_key_1]
        used_user_content = True
    elif eval_key_1 in id_configs:
        opt = id_configs[eval_key_1]
        if "DefaultValue" in opt:
            (eval_val_1_used_user_content, eval_val_1) = XCSPEC_EVALS[opt["DefaultValue"]](xcconfigs, id_configs)
            used_user_content = used_user_content or eval_val_1_used_user_content

    return (used_user_content, (not eval_val_0 == "YES" and eval_val_1 != "-Owholemodule"))

def _com_apple_xcode_tools_swift_compiler__SWIFT_COMPILATION_MODE__DefaultValue(xcconfigs, id_configs):
    # singlefile
    return (False, "singlefile")

def _com_apple_xcode_tools_swift_compiler__SWIFT_ENABLE_BATCH_MODE__DefaultValue(xcconfigs, id_configs):
    # YES
    return (False, "YES")

def _com_apple_xcode_tools_swift_compiler__SWIFT_DISABLE_SAFETY_CHECKS__DefaultValue(xcconfigs, id_configs):
    # NO
    return (False, "NO")

def _com_apple_xcode_tools_swift_compiler__SWIFT_ENFORCE_EXCLUSIVE_ACCESS__DefaultValue(xcconfigs, id_configs):
    # on
    return (False, "on")

def _com_apple_xcode_tools_swift_compiler____SWIFT_ENFORCE_EXCLUSIVE_ACCESS_DEBUG_ENFORCEMENT_RELEASE__Condition(xcconfigs, id_configs):
    # $(SWIFT_OPTIMIZATION_LEVEL) != '-Onone' && ($(SWIFT_ENFORCE_EXCLUSIVE_ACCESS) == 'full' || $(SWIFT_ENFORCE_EXCLUSIVE_ACCESS) == 'debug-only')

    used_user_content = False

    eval_val_0 = ""
    eval_key_0 = "SWIFT_OPTIMIZATION_LEVEL"
    if eval_key_0 in xcconfigs:
        eval_val_0 = xcconfigs[eval_key_0]
        used_user_content = True
    elif eval_key_0 in id_configs:
        opt = id_configs[eval_key_0]
        if "DefaultValue" in opt:
            (eval_val_0_used_user_content, eval_val_0) = XCSPEC_EVALS[opt["DefaultValue"]](xcconfigs, id_configs)
            used_user_content = used_user_content or eval_val_0_used_user_content

    eval_val_1 = ""
    eval_key_1 = "SWIFT_ENFORCE_EXCLUSIVE_ACCESS"
    if eval_key_1 in xcconfigs:
        eval_val_1 = xcconfigs[eval_key_1]
        used_user_content = True
    elif eval_key_1 in id_configs:
        opt = id_configs[eval_key_1]
        if "DefaultValue" in opt:
            (eval_val_1_used_user_content, eval_val_1) = XCSPEC_EVALS[opt["DefaultValue"]](xcconfigs, id_configs)
            used_user_content = used_user_content or eval_val_1_used_user_content

    return (used_user_content, (eval_val_0 != "-Onone" and (eval_val_1 == "full" or eval_val_1 == "debug-only")))

def _com_apple_xcode_tools_swift_compiler____SWIFT_ENFORCE_EXCLUSIVE_ACCESS_DEBUG_ENFORCEMENT_RELEASE__DefaultValue(xcconfigs, id_configs):
    # YES
    return (False, "YES")

def _com_apple_xcode_tools_swift_compiler____SWIFT_ENFORCE_EXCLUSIVE_ACCESS_DEBUG_ENFORCEMENT_DEBUG__Condition(xcconfigs, id_configs):
    # $(SWIFT_OPTIMIZATION_LEVEL) == '-Onone' && ($(SWIFT_ENFORCE_EXCLUSIVE_ACCESS) == 'full' || $(SWIFT_ENFORCE_EXCLUSIVE_ACCESS) == 'debug-only')

    used_user_content = False

    eval_val_0 = ""
    eval_key_0 = "SWIFT_OPTIMIZATION_LEVEL"
    if eval_key_0 in xcconfigs:
        eval_val_0 = xcconfigs[eval_key_0]
        used_user_content = True
    elif eval_key_0 in id_configs:
        opt = id_configs[eval_key_0]
        if "DefaultValue" in opt:
            (eval_val_0_used_user_content, eval_val_0) = XCSPEC_EVALS[opt["DefaultValue"]](xcconfigs, id_configs)
            used_user_content = used_user_content or eval_val_0_used_user_content

    eval_val_1 = ""
    eval_key_1 = "SWIFT_ENFORCE_EXCLUSIVE_ACCESS"
    if eval_key_1 in xcconfigs:
        eval_val_1 = xcconfigs[eval_key_1]
        used_user_content = True
    elif eval_key_1 in id_configs:
        opt = id_configs[eval_key_1]
        if "DefaultValue" in opt:
            (eval_val_1_used_user_content, eval_val_1) = XCSPEC_EVALS[opt["DefaultValue"]](xcconfigs, id_configs)
            used_user_content = used_user_content or eval_val_1_used_user_content

    return (used_user_content, (eval_val_0 == "-Onone" and (eval_val_1 == "full" or eval_val_1 == "debug-only")))

def _com_apple_xcode_tools_swift_compiler____SWIFT_ENFORCE_EXCLUSIVE_ACCESS_DEBUG_ENFORCEMENT_DEBUG__DefaultValue(xcconfigs, id_configs):
    # YES
    return (False, "YES")

def _com_apple_xcode_tools_swift_compiler__SWIFT_STDLIB__DefaultValue(xcconfigs, id_configs):
    # swiftCore
    return (False, "swiftCore")

def _com_apple_xcode_tools_swift_compiler__SWIFT_PACKAGE_NAME__Condition(xcconfigs, id_configs):
    # $(SWIFT_PACKAGE_NAME) != ""

    used_user_content = False

    eval_val_0 = ""
    eval_key_0 = "SWIFT_PACKAGE_NAME"
    if eval_key_0 in xcconfigs:
        eval_val_0 = xcconfigs[eval_key_0]
        used_user_content = True
    elif eval_key_0 in id_configs:
        opt = id_configs[eval_key_0]
        if "DefaultValue" in opt:
            (eval_val_0_used_user_content, eval_val_0) = XCSPEC_EVALS[opt["DefaultValue"]](xcconfigs, id_configs)
            used_user_content = used_user_content or eval_val_0_used_user_content

    return (used_user_content, (eval_val_0 != ""))

def _com_apple_xcode_tools_swift_compiler__SWIFT_RESPONSE_FILE_PATH__DefaultValue(xcconfigs, id_configs):
    # $(SWIFT_RESPONSE_FILE_PATH_$(variant)_$(arch))

    used_user_content = False

    eval_val_0 = ""
    eval_key_0 = "variant"
    if eval_key_0 in xcconfigs:
        eval_val_0 = xcconfigs[eval_key_0]
        used_user_content = True
    elif eval_key_0 in id_configs:
        opt = id_configs[eval_key_0]
        if "DefaultValue" in opt:
            (eval_val_0_used_user_content, eval_val_0) = XCSPEC_EVALS[opt["DefaultValue"]](xcconfigs, id_configs)
            used_user_content = used_user_content or eval_val_0_used_user_content

    eval_val_1 = ""
    eval_key_1 = "arch"
    if eval_key_1 in xcconfigs:
        eval_val_1 = xcconfigs[eval_key_1]
        used_user_content = True
    elif eval_key_1 in id_configs:
        opt = id_configs[eval_key_1]
        if "DefaultValue" in opt:
            (eval_val_1_used_user_content, eval_val_1) = XCSPEC_EVALS[opt["DefaultValue"]](xcconfigs, id_configs)
            used_user_content = used_user_content or eval_val_1_used_user_content

    eval_val_2 = ""
    eval_key_2 = "SWIFT_RESPONSE_FILE_PATH_{eval_val_0}_{eval_val_1}".format(eval_val_0 = eval_val_0, eval_val_1 = eval_val_1)
    if eval_key_2 in xcconfigs:
        eval_val_2 = xcconfigs[eval_key_2]
        used_user_content = True
    elif eval_key_2 in id_configs:
        opt = id_configs[eval_key_2]
        if "DefaultValue" in opt:
            (eval_val_2_used_user_content, eval_val_2) = XCSPEC_EVALS[opt["DefaultValue"]](xcconfigs, id_configs)
            used_user_content = used_user_content or eval_val_2_used_user_content

    return (used_user_content, eval_val_2)

def _com_apple_xcode_tools_swift_compiler__SWIFT_ACTIVE_COMPILATION_CONDITIONS__DefaultValue(xcconfigs, id_configs):
    #
    return (False, "")

def _com_apple_xcode_tools_swift_compiler__SWIFT_DEPLOYMENT_TARGET__DefaultValue(xcconfigs, id_configs):
    # $($(DEPLOYMENT_TARGET_SETTING_NAME))

    used_user_content = False

    eval_val_0 = ""
    eval_key_0 = "DEPLOYMENT_TARGET_SETTING_NAME"
    if eval_key_0 in xcconfigs:
        eval_val_0 = xcconfigs[eval_key_0]
        used_user_content = True
    elif eval_key_0 in id_configs:
        opt = id_configs[eval_key_0]
        if "DefaultValue" in opt:
            (eval_val_0_used_user_content, eval_val_0) = XCSPEC_EVALS[opt["DefaultValue"]](xcconfigs, id_configs)
            used_user_content = used_user_content or eval_val_0_used_user_content

    eval_val_1 = ""
    eval_key_1 = eval_val_0
    if eval_key_1 in xcconfigs:
        eval_val_1 = xcconfigs[eval_key_1]
        used_user_content = True
    elif eval_key_1 in id_configs:
        opt = id_configs[eval_key_1]
        if "DefaultValue" in opt:
            (eval_val_1_used_user_content, eval_val_1) = XCSPEC_EVALS[opt["DefaultValue"]](xcconfigs, id_configs)
            used_user_content = used_user_content or eval_val_1_used_user_content

    return (used_user_content, eval_val_1)

def _com_apple_xcode_tools_swift_compiler__SWIFT_TARGET_TRIPLE__DefaultValue(xcconfigs, id_configs):
    # $(CURRENT_ARCH)-apple-$(SWIFT_PLATFORM_TARGET_PREFIX)$(SWIFT_DEPLOYMENT_TARGET)$(LLVM_TARGET_TRIPLE_SUFFIX)

    used_user_content = False

    eval_val_0 = ""
    eval_key_0 = "CURRENT_ARCH"
    if eval_key_0 in xcconfigs:
        eval_val_0 = xcconfigs[eval_key_0]
        used_user_content = True
    elif eval_key_0 in id_configs:
        opt = id_configs[eval_key_0]
        if "DefaultValue" in opt:
            (eval_val_0_used_user_content, eval_val_0) = XCSPEC_EVALS[opt["DefaultValue"]](xcconfigs, id_configs)
            used_user_content = used_user_content or eval_val_0_used_user_content

    eval_val_1 = ""
    eval_key_1 = "SWIFT_PLATFORM_TARGET_PREFIX"
    if eval_key_1 in xcconfigs:
        eval_val_1 = xcconfigs[eval_key_1]
        used_user_content = True
    elif eval_key_1 in id_configs:
        opt = id_configs[eval_key_1]
        if "DefaultValue" in opt:
            (eval_val_1_used_user_content, eval_val_1) = XCSPEC_EVALS[opt["DefaultValue"]](xcconfigs, id_configs)
            used_user_content = used_user_content or eval_val_1_used_user_content

    eval_val_2 = ""
    eval_key_2 = "SWIFT_DEPLOYMENT_TARGET"
    if eval_key_2 in xcconfigs:
        eval_val_2 = xcconfigs[eval_key_2]
        used_user_content = True
    elif eval_key_2 in id_configs:
        opt = id_configs[eval_key_2]
        if "DefaultValue" in opt:
            (eval_val_2_used_user_content, eval_val_2) = XCSPEC_EVALS[opt["DefaultValue"]](xcconfigs, id_configs)
            used_user_content = used_user_content or eval_val_2_used_user_content

    eval_val_3 = ""
    eval_key_3 = "LLVM_TARGET_TRIPLE_SUFFIX"
    if eval_key_3 in xcconfigs:
        eval_val_3 = xcconfigs[eval_key_3]
        used_user_content = True
    elif eval_key_3 in id_configs:
        opt = id_configs[eval_key_3]
        if "DefaultValue" in opt:
            (eval_val_3_used_user_content, eval_val_3) = XCSPEC_EVALS[opt["DefaultValue"]](xcconfigs, id_configs)
            used_user_content = used_user_content or eval_val_3_used_user_content

    return (used_user_content, "{eval_val_0}-apple-{eval_val_1}{eval_val_2}{eval_val_3}".format(eval_val_0 = eval_val_0, eval_val_1 = eval_val_1, eval_val_2 = eval_val_2, eval_val_3 = eval_val_3))

def _com_apple_xcode_tools_swift_compiler__SWIFT_VERSION__DefaultValue(xcconfigs, id_configs):
    #
    return (False, "")

def _com_apple_xcode_tools_swift_compiler__SWIFT_ENABLE_BARE_SLASH_REGEX__DefaultValue(xcconfigs, id_configs):
    # YES
    return (False, "YES")

def _com_apple_xcode_tools_swift_compiler__SWIFT_ENABLE_EMIT_CONST_VALUES__DefaultValue(xcconfigs, id_configs):
    # YES
    return (False, "YES")

def _com_apple_xcode_tools_swift_compiler__SWIFT_EMIT_CONST_VALUE_PROTOCOLS__DefaultValue(xcconfigs, id_configs):
    # AppIntent EntityQuery AppEntity TransientEntity AppEnum AppShortcutProviding AppShortcutsProvider AnyResolverProviding AppIntentsPackage DynamicOptionsProvider
    return (False, "AppIntent EntityQuery AppEntity TransientEntity AppEnum AppShortcutProviding AppShortcutsProvider AnyResolverProviding AppIntentsPackage DynamicOptionsProvider")

def _com_apple_xcode_tools_swift_compiler__SWIFT_STRICT_CONCURRENCY__DefaultValue(xcconfigs, id_configs):
    # minimal
    return (False, "minimal")

def _com_apple_xcode_tools_swift_compiler__SWIFT_OBJC_INTEROP_MODE__DefaultValue(xcconfigs, id_configs):
    # objc
    return (False, "objc")

def _com_apple_xcode_tools_swift_compiler__SWIFT_VALIDATE_CLANG_MODULES_ONCE_PER_BUILD_SESSION__DefaultValue(xcconfigs, id_configs):
    # YES
    return (False, "YES")

def _com_apple_xcode_tools_swift_compiler__SWIFT_SERIALIZE_DEBUGGING_OPTIONS__DefaultValue(xcconfigs, id_configs):
    # YES
    return (False, "YES")

def _com_apple_xcode_tools_swift_compiler__SWIFT_ENABLE_APP_EXTENSION__DefaultValue(xcconfigs, id_configs):
    # $(APPLICATION_EXTENSION_API_ONLY)

    used_user_content = False

    eval_val_0 = ""
    eval_key_0 = "APPLICATION_EXTENSION_API_ONLY"
    if eval_key_0 in xcconfigs:
        eval_val_0 = xcconfigs[eval_key_0]
        used_user_content = True
    elif eval_key_0 in id_configs:
        opt = id_configs[eval_key_0]
        if "DefaultValue" in opt:
            (eval_val_0_used_user_content, eval_val_0) = XCSPEC_EVALS[opt["DefaultValue"]](xcconfigs, id_configs)
            used_user_content = used_user_content or eval_val_0_used_user_content

    return (used_user_content, eval_val_0)

def _com_apple_xcode_tools_swift_compiler__SWIFT_LINK_OBJC_RUNTIME__DefaultValue(xcconfigs, id_configs):
    # $(LINK_OBJC_RUNTIME)

    used_user_content = False

    eval_val_0 = ""
    eval_key_0 = "LINK_OBJC_RUNTIME"
    if eval_key_0 in xcconfigs:
        eval_val_0 = xcconfigs[eval_key_0]
        used_user_content = True
    elif eval_key_0 in id_configs:
        opt = id_configs[eval_key_0]
        if "DefaultValue" in opt:
            (eval_val_0_used_user_content, eval_val_0) = XCSPEC_EVALS[opt["DefaultValue"]](xcconfigs, id_configs)
            used_user_content = used_user_content or eval_val_0_used_user_content

    return (used_user_content, eval_val_0)

def _com_apple_xcode_tools_swift_compiler__CLANG_COVERAGE_MAPPING__Condition(xcconfigs, id_configs):
    # $(ENABLE_CODE_COVERAGE)

    used_user_content = False

    eval_val_0 = ""
    eval_key_0 = "ENABLE_CODE_COVERAGE"
    if eval_key_0 in xcconfigs:
        eval_val_0 = xcconfigs[eval_key_0]
        used_user_content = True
    elif eval_key_0 in id_configs:
        opt = id_configs[eval_key_0]
        if "DefaultValue" in opt:
            (eval_val_0_used_user_content, eval_val_0) = XCSPEC_EVALS[opt["DefaultValue"]](xcconfigs, id_configs)
            used_user_content = used_user_content or eval_val_0_used_user_content

    return (used_user_content, (eval_val_0 == "YES"))

def _com_apple_xcode_tools_swift_compiler__CLANG_COVERAGE_MAPPING__DefaultValue(xcconfigs, id_configs):
    # NO
    return (False, "NO")

def _com_apple_xcode_tools_swift_compiler__CLANG_COVERAGE_MAPPING_LINKER_ARGS__DefaultValue(xcconfigs, id_configs):
    # $(CLANG_COVERAGE_MAPPING)

    used_user_content = False

    eval_val_0 = ""
    eval_key_0 = "CLANG_COVERAGE_MAPPING"
    if eval_key_0 in xcconfigs:
        eval_val_0 = xcconfigs[eval_key_0]
        used_user_content = True
    elif eval_key_0 in id_configs:
        opt = id_configs[eval_key_0]
        if "DefaultValue" in opt:
            (eval_val_0_used_user_content, eval_val_0) = XCSPEC_EVALS[opt["DefaultValue"]](xcconfigs, id_configs)
            used_user_content = used_user_content or eval_val_0_used_user_content

    return (used_user_content, eval_val_0)

def _com_apple_xcode_tools_swift_compiler__SWIFT_REFLECTION_METADATA_LEVEL__DefaultValue(xcconfigs, id_configs):
    # all
    return (False, "all")

def _com_apple_xcode_tools_swift_compiler__SWIFT_BITCODE_GENERATION_MODE__Condition(xcconfigs, id_configs):
    # $(ENABLE_BITCODE)

    used_user_content = False

    eval_val_0 = ""
    eval_key_0 = "ENABLE_BITCODE"
    if eval_key_0 in xcconfigs:
        eval_val_0 = xcconfigs[eval_key_0]
        used_user_content = True
    elif eval_key_0 in id_configs:
        opt = id_configs[eval_key_0]
        if "DefaultValue" in opt:
            (eval_val_0_used_user_content, eval_val_0) = XCSPEC_EVALS[opt["DefaultValue"]](xcconfigs, id_configs)
            used_user_content = used_user_content or eval_val_0_used_user_content

    return (used_user_content, (eval_val_0 == "YES"))

def _com_apple_xcode_tools_swift_compiler__SWIFT_BITCODE_GENERATION_MODE__DefaultValue(xcconfigs, id_configs):
    # $(BITCODE_GENERATION_MODE)

    used_user_content = False

    eval_val_0 = ""
    eval_key_0 = "BITCODE_GENERATION_MODE"
    if eval_key_0 in xcconfigs:
        eval_val_0 = xcconfigs[eval_key_0]
        used_user_content = True
    elif eval_key_0 in id_configs:
        opt = id_configs[eval_key_0]
        if "DefaultValue" in opt:
            (eval_val_0_used_user_content, eval_val_0) = XCSPEC_EVALS[opt["DefaultValue"]](xcconfigs, id_configs)
            used_user_content = used_user_content or eval_val_0_used_user_content

    return (used_user_content, eval_val_0)

def _com_apple_xcode_tools_swift_compiler__SWIFT_ADDRESS_SANITIZER__DefaultValue(xcconfigs, id_configs):
    # $(ENABLE_ADDRESS_SANITIZER)

    used_user_content = False

    eval_val_0 = ""
    eval_key_0 = "ENABLE_ADDRESS_SANITIZER"
    if eval_key_0 in xcconfigs:
        eval_val_0 = xcconfigs[eval_key_0]
        used_user_content = True
    elif eval_key_0 in id_configs:
        opt = id_configs[eval_key_0]
        if "DefaultValue" in opt:
            (eval_val_0_used_user_content, eval_val_0) = XCSPEC_EVALS[opt["DefaultValue"]](xcconfigs, id_configs)
            used_user_content = used_user_content or eval_val_0_used_user_content

    return (used_user_content, eval_val_0)

def _com_apple_xcode_tools_swift_compiler__SWIFT_ADDRESS_SANITIZER_ALLOW_ERROR_RECOVERY__Condition(xcconfigs, id_configs):
    # $(SWIFT_ADDRESS_SANITIZER)

    used_user_content = False

    eval_val_0 = ""
    eval_key_0 = "SWIFT_ADDRESS_SANITIZER"
    if eval_key_0 in xcconfigs:
        eval_val_0 = xcconfigs[eval_key_0]
        used_user_content = True
    elif eval_key_0 in id_configs:
        opt = id_configs[eval_key_0]
        if "DefaultValue" in opt:
            (eval_val_0_used_user_content, eval_val_0) = XCSPEC_EVALS[opt["DefaultValue"]](xcconfigs, id_configs)
            used_user_content = used_user_content or eval_val_0_used_user_content

    return (used_user_content, (eval_val_0 == "YES"))

def _com_apple_xcode_tools_swift_compiler__SWIFT_ADDRESS_SANITIZER_ALLOW_ERROR_RECOVERY__DefaultValue(xcconfigs, id_configs):
    # $(ENABLE_ADDRESS_SANITIZER_ALLOW_ERROR_RECOVERY)

    used_user_content = False

    eval_val_0 = ""
    eval_key_0 = "ENABLE_ADDRESS_SANITIZER_ALLOW_ERROR_RECOVERY"
    if eval_key_0 in xcconfigs:
        eval_val_0 = xcconfigs[eval_key_0]
        used_user_content = True
    elif eval_key_0 in id_configs:
        opt = id_configs[eval_key_0]
        if "DefaultValue" in opt:
            (eval_val_0_used_user_content, eval_val_0) = XCSPEC_EVALS[opt["DefaultValue"]](xcconfigs, id_configs)
            used_user_content = used_user_content or eval_val_0_used_user_content

    return (used_user_content, eval_val_0)

def _com_apple_xcode_tools_swift_compiler__SWIFT_THREAD_SANITIZER__DefaultValue(xcconfigs, id_configs):
    # $(ENABLE_THREAD_SANITIZER)

    used_user_content = False

    eval_val_0 = ""
    eval_key_0 = "ENABLE_THREAD_SANITIZER"
    if eval_key_0 in xcconfigs:
        eval_val_0 = xcconfigs[eval_key_0]
        used_user_content = True
    elif eval_key_0 in id_configs:
        opt = id_configs[eval_key_0]
        if "DefaultValue" in opt:
            (eval_val_0_used_user_content, eval_val_0) = XCSPEC_EVALS[opt["DefaultValue"]](xcconfigs, id_configs)
            used_user_content = used_user_content or eval_val_0_used_user_content

    return (used_user_content, eval_val_0)

def _com_apple_xcode_tools_swift_compiler__SWIFT_ENABLE_TESTABILITY__DefaultValue(xcconfigs, id_configs):
    # NO
    return (False, "NO")

def _com_apple_xcode_tools_swift_compiler__SWIFT_SUPPRESS_WARNINGS__DefaultValue(xcconfigs, id_configs):
    # $(SUPPRESS_WARNINGS)

    used_user_content = False

    eval_val_0 = ""
    eval_key_0 = "SUPPRESS_WARNINGS"
    if eval_key_0 in xcconfigs:
        eval_val_0 = xcconfigs[eval_key_0]
        used_user_content = True
    elif eval_key_0 in id_configs:
        opt = id_configs[eval_key_0]
        if "DefaultValue" in opt:
            (eval_val_0_used_user_content, eval_val_0) = XCSPEC_EVALS[opt["DefaultValue"]](xcconfigs, id_configs)
            used_user_content = used_user_content or eval_val_0_used_user_content

    return (used_user_content, eval_val_0)

def _com_apple_xcode_tools_swift_compiler__SWIFT_TREAT_WARNINGS_AS_ERRORS__DefaultValue(xcconfigs, id_configs):
    # NO
    return (False, "NO")

def _com_apple_xcode_tools_swift_compiler__SWIFT_INDEX_STORE_PATH__DefaultValue(xcconfigs, id_configs):
    # $(INDEX_DATA_STORE_DIR)

    used_user_content = False

    eval_val_0 = ""
    eval_key_0 = "INDEX_DATA_STORE_DIR"
    if eval_key_0 in xcconfigs:
        eval_val_0 = xcconfigs[eval_key_0]
        used_user_content = True
    elif eval_key_0 in id_configs:
        opt = id_configs[eval_key_0]
        if "DefaultValue" in opt:
            (eval_val_0_used_user_content, eval_val_0) = XCSPEC_EVALS[opt["DefaultValue"]](xcconfigs, id_configs)
            used_user_content = used_user_content or eval_val_0_used_user_content

    return (used_user_content, eval_val_0)

def _com_apple_xcode_tools_swift_compiler__SWIFT_INDEX_STORE_ENABLE__Condition(xcconfigs, id_configs):
    # $(COMPILER_INDEX_STORE_ENABLE)  ||  ( $(COMPILER_INDEX_STORE_ENABLE) == Default  &&  $(SWIFT_OPTIMIZATION_LEVEL) == '-Onone' )

    used_user_content = False

    eval_val_0 = ""
    eval_key_0 = "COMPILER_INDEX_STORE_ENABLE"
    if eval_key_0 in xcconfigs:
        eval_val_0 = xcconfigs[eval_key_0]
        used_user_content = True
    elif eval_key_0 in id_configs:
        opt = id_configs[eval_key_0]
        if "DefaultValue" in opt:
            (eval_val_0_used_user_content, eval_val_0) = XCSPEC_EVALS[opt["DefaultValue"]](xcconfigs, id_configs)
            used_user_content = used_user_content or eval_val_0_used_user_content

    eval_val_1 = ""
    eval_key_1 = "SWIFT_OPTIMIZATION_LEVEL"
    if eval_key_1 in xcconfigs:
        eval_val_1 = xcconfigs[eval_key_1]
        used_user_content = True
    elif eval_key_1 in id_configs:
        opt = id_configs[eval_key_1]
        if "DefaultValue" in opt:
            (eval_val_1_used_user_content, eval_val_1) = XCSPEC_EVALS[opt["DefaultValue"]](xcconfigs, id_configs)
            used_user_content = used_user_content or eval_val_1_used_user_content

    return (used_user_content, (eval_val_0 == "YES" or (eval_val_0 == "Default" and eval_val_1 == "-Onone")))

def _com_apple_xcode_tools_swift_compiler__SWIFT_INDEX_STORE_ENABLE__DefaultValue(xcconfigs, id_configs):
    # $(INDEX_ENABLE_DATA_STORE)

    used_user_content = False

    eval_val_0 = ""
    eval_key_0 = "INDEX_ENABLE_DATA_STORE"
    if eval_key_0 in xcconfigs:
        eval_val_0 = xcconfigs[eval_key_0]
        used_user_content = True
    elif eval_key_0 in id_configs:
        opt = id_configs[eval_key_0]
        if "DefaultValue" in opt:
            (eval_val_0_used_user_content, eval_val_0) = XCSPEC_EVALS[opt["DefaultValue"]](xcconfigs, id_configs)
            used_user_content = used_user_content or eval_val_0_used_user_content

    return (used_user_content, eval_val_0)

def _com_apple_xcode_tools_swift_compiler__SWIFT_EMIT_MODULE_INTERFACE__DefaultValue(xcconfigs, id_configs):
    # $(BUILD_LIBRARY_FOR_DISTRIBUTION)

    used_user_content = False

    eval_val_0 = ""
    eval_key_0 = "BUILD_LIBRARY_FOR_DISTRIBUTION"
    if eval_key_0 in xcconfigs:
        eval_val_0 = xcconfigs[eval_key_0]
        used_user_content = True
    elif eval_key_0 in id_configs:
        opt = id_configs[eval_key_0]
        if "DefaultValue" in opt:
            (eval_val_0_used_user_content, eval_val_0) = XCSPEC_EVALS[opt["DefaultValue"]](xcconfigs, id_configs)
            used_user_content = used_user_content or eval_val_0_used_user_content

    return (used_user_content, eval_val_0)

def _com_apple_xcode_tools_swift_compiler__SWIFT_ENABLE_LIBRARY_EVOLUTION__DefaultValue(xcconfigs, id_configs):
    # $(BUILD_LIBRARY_FOR_DISTRIBUTION)

    used_user_content = False

    eval_val_0 = ""
    eval_key_0 = "BUILD_LIBRARY_FOR_DISTRIBUTION"
    if eval_key_0 in xcconfigs:
        eval_val_0 = xcconfigs[eval_key_0]
        used_user_content = True
    elif eval_key_0 in id_configs:
        opt = id_configs[eval_key_0]
        if "DefaultValue" in opt:
            (eval_val_0_used_user_content, eval_val_0) = XCSPEC_EVALS[opt["DefaultValue"]](xcconfigs, id_configs)
            used_user_content = used_user_content or eval_val_0_used_user_content

    return (used_user_content, eval_val_0)

def _com_apple_xcode_tools_swift_compiler__SWIFT_ENABLE_OPAQUE_TYPE_ERASURE__Condition(xcconfigs, id_configs):
    # $(ENABLE_XOJIT_PREVIEWS) && $(SWIFT_OPTIMIZATION_LEVEL) == '-Onone'

    used_user_content = False

    eval_val_0 = ""
    eval_key_0 = "ENABLE_XOJIT_PREVIEWS"
    if eval_key_0 in xcconfigs:
        eval_val_0 = xcconfigs[eval_key_0]
        used_user_content = True
    elif eval_key_0 in id_configs:
        opt = id_configs[eval_key_0]
        if "DefaultValue" in opt:
            (eval_val_0_used_user_content, eval_val_0) = XCSPEC_EVALS[opt["DefaultValue"]](xcconfigs, id_configs)
            used_user_content = used_user_content or eval_val_0_used_user_content

    eval_val_1 = ""
    eval_key_1 = "SWIFT_OPTIMIZATION_LEVEL"
    if eval_key_1 in xcconfigs:
        eval_val_1 = xcconfigs[eval_key_1]
        used_user_content = True
    elif eval_key_1 in id_configs:
        opt = id_configs[eval_key_1]
        if "DefaultValue" in opt:
            (eval_val_1_used_user_content, eval_val_1) = XCSPEC_EVALS[opt["DefaultValue"]](xcconfigs, id_configs)
            used_user_content = used_user_content or eval_val_1_used_user_content

    return (used_user_content, (eval_val_0 == "YES" and eval_val_1 == "-Onone"))

def _com_apple_xcode_tools_swift_compiler__SWIFT_ENABLE_OPAQUE_TYPE_ERASURE__DefaultValue(xcconfigs, id_configs):
    # YES
    return (False, "YES")

def _com_apple_xcode_tools_swift_compiler__SWIFT_CLANG_CXX_LANGUAGE_STANDARD__DefaultValue(xcconfigs, id_configs):
    # $(SWIFT_OBJC_INTEROP_MODE)-$(CLANG_CXX_LANGUAGE_STANDARD)

    used_user_content = False

    eval_val_0 = ""
    eval_key_0 = "SWIFT_OBJC_INTEROP_MODE"
    if eval_key_0 in xcconfigs:
        eval_val_0 = xcconfigs[eval_key_0]
        used_user_content = True
    elif eval_key_0 in id_configs:
        opt = id_configs[eval_key_0]
        if "DefaultValue" in opt:
            (eval_val_0_used_user_content, eval_val_0) = XCSPEC_EVALS[opt["DefaultValue"]](xcconfigs, id_configs)
            used_user_content = used_user_content or eval_val_0_used_user_content

    eval_val_1 = ""
    eval_key_1 = "CLANG_CXX_LANGUAGE_STANDARD"
    if eval_key_1 in xcconfigs:
        eval_val_1 = xcconfigs[eval_key_1]
        used_user_content = True
    elif eval_key_1 in id_configs:
        opt = id_configs[eval_key_1]
        if "DefaultValue" in opt:
            (eval_val_1_used_user_content, eval_val_1) = XCSPEC_EVALS[opt["DefaultValue"]](xcconfigs, id_configs)
            used_user_content = used_user_content or eval_val_1_used_user_content

    return (used_user_content, "{eval_val_0}-{eval_val_1}".format(eval_val_0 = eval_val_0, eval_val_1 = eval_val_1))

XCSPEC_EVALS = {
    "com_apple_compilers_llvm_clang_1_0__CLANG_ADDRESS_SANITIZER_ALLOW_ERROR_RECOVERY__Condition": _com_apple_compilers_llvm_clang_1_0__CLANG_ADDRESS_SANITIZER_ALLOW_ERROR_RECOVERY__Condition,
    "com_apple_compilers_llvm_clang_1_0__CLANG_ADDRESS_SANITIZER_ALLOW_ERROR_RECOVERY__DefaultValue": _com_apple_compilers_llvm_clang_1_0__CLANG_ADDRESS_SANITIZER_ALLOW_ERROR_RECOVERY__DefaultValue,
    "com_apple_compilers_llvm_clang_1_0__CLANG_ADDRESS_SANITIZER_CONTAINER_OVERFLOW__Condition": _com_apple_compilers_llvm_clang_1_0__CLANG_ADDRESS_SANITIZER_CONTAINER_OVERFLOW__Condition,
    "com_apple_compilers_llvm_clang_1_0__CLANG_ADDRESS_SANITIZER_CONTAINER_OVERFLOW__DefaultValue": _com_apple_compilers_llvm_clang_1_0__CLANG_ADDRESS_SANITIZER_CONTAINER_OVERFLOW__DefaultValue,
    "com_apple_compilers_llvm_clang_1_0__CLANG_ADDRESS_SANITIZER_USE_AFTER_SCOPE__Condition": _com_apple_compilers_llvm_clang_1_0__CLANG_ADDRESS_SANITIZER_USE_AFTER_SCOPE__Condition,
    "com_apple_compilers_llvm_clang_1_0__CLANG_ADDRESS_SANITIZER_USE_AFTER_SCOPE__DefaultValue": _com_apple_compilers_llvm_clang_1_0__CLANG_ADDRESS_SANITIZER_USE_AFTER_SCOPE__DefaultValue,
    "com_apple_compilers_llvm_clang_1_0__CLANG_ADDRESS_SANITIZER__DefaultValue": _com_apple_compilers_llvm_clang_1_0__CLANG_ADDRESS_SANITIZER__DefaultValue,
    "com_apple_compilers_llvm_clang_1_0__CLANG_ALLOW_NON_MODULAR_INCLUDES_IN_FRAMEWORK_MODULES__Condition": _com_apple_compilers_llvm_clang_1_0__CLANG_ALLOW_NON_MODULAR_INCLUDES_IN_FRAMEWORK_MODULES__Condition,
    "com_apple_compilers_llvm_clang_1_0__CLANG_ALLOW_NON_MODULAR_INCLUDES_IN_FRAMEWORK_MODULES__DefaultValue": _com_apple_compilers_llvm_clang_1_0__CLANG_ALLOW_NON_MODULAR_INCLUDES_IN_FRAMEWORK_MODULES__DefaultValue,
    "com_apple_compilers_llvm_clang_1_0__CLANG_ARC_MIGRATE_EMIT_ERROR__DefaultValue": _com_apple_compilers_llvm_clang_1_0__CLANG_ARC_MIGRATE_EMIT_ERROR__DefaultValue,
    "com_apple_compilers_llvm_clang_1_0__CLANG_ARC_MIGRATE_PRECHECK__DefaultValue": _com_apple_compilers_llvm_clang_1_0__CLANG_ARC_MIGRATE_PRECHECK__DefaultValue,
    "com_apple_compilers_llvm_clang_1_0__CLANG_BITCODE_GENERATION_MODE__Condition": _com_apple_compilers_llvm_clang_1_0__CLANG_BITCODE_GENERATION_MODE__Condition,
    "com_apple_compilers_llvm_clang_1_0__CLANG_BITCODE_GENERATION_MODE__DefaultValue": _com_apple_compilers_llvm_clang_1_0__CLANG_BITCODE_GENERATION_MODE__DefaultValue,
    "com_apple_compilers_llvm_clang_1_0__CLANG_COLOR_DIAGNOSTICS__DefaultValue": _com_apple_compilers_llvm_clang_1_0__CLANG_COLOR_DIAGNOSTICS__DefaultValue,
    "com_apple_compilers_llvm_clang_1_0__CLANG_COVERAGE_MAPPING_LINKER_ARGS__DefaultValue": _com_apple_compilers_llvm_clang_1_0__CLANG_COVERAGE_MAPPING_LINKER_ARGS__DefaultValue,
    "com_apple_compilers_llvm_clang_1_0__CLANG_COVERAGE_MAPPING__Condition": _com_apple_compilers_llvm_clang_1_0__CLANG_COVERAGE_MAPPING__Condition,
    "com_apple_compilers_llvm_clang_1_0__CLANG_COVERAGE_MAPPING__DefaultValue": _com_apple_compilers_llvm_clang_1_0__CLANG_COVERAGE_MAPPING__DefaultValue,
    "com_apple_compilers_llvm_clang_1_0__CLANG_CXX_LANGUAGE_STANDARD__DefaultValue": _com_apple_compilers_llvm_clang_1_0__CLANG_CXX_LANGUAGE_STANDARD__DefaultValue,
    "com_apple_compilers_llvm_clang_1_0__CLANG_CXX_LIBRARY__DefaultValue": _com_apple_compilers_llvm_clang_1_0__CLANG_CXX_LIBRARY__DefaultValue,
    "com_apple_compilers_llvm_clang_1_0__CLANG_DEBUG_INFORMATION_LEVEL__Condition": _com_apple_compilers_llvm_clang_1_0__CLANG_DEBUG_INFORMATION_LEVEL__Condition,
    "com_apple_compilers_llvm_clang_1_0__CLANG_DEBUG_INFORMATION_LEVEL__DefaultValue": _com_apple_compilers_llvm_clang_1_0__CLANG_DEBUG_INFORMATION_LEVEL__DefaultValue,
    "com_apple_compilers_llvm_clang_1_0__CLANG_DEBUG_MODULES__Condition": _com_apple_compilers_llvm_clang_1_0__CLANG_DEBUG_MODULES__Condition,
    "com_apple_compilers_llvm_clang_1_0__CLANG_DEBUG_MODULES__DefaultValue": _com_apple_compilers_llvm_clang_1_0__CLANG_DEBUG_MODULES__DefaultValue,
    "com_apple_compilers_llvm_clang_1_0__CLANG_ENABLE_APP_EXTENSION__DefaultValue": _com_apple_compilers_llvm_clang_1_0__CLANG_ENABLE_APP_EXTENSION__DefaultValue,
    "com_apple_compilers_llvm_clang_1_0__CLANG_ENABLE_BOUNDS_ATTRIBUTES__DefaultValue": _com_apple_compilers_llvm_clang_1_0__CLANG_ENABLE_BOUNDS_ATTRIBUTES__DefaultValue,
    "com_apple_compilers_llvm_clang_1_0__CLANG_ENABLE_BOUNDS_SAFETY__DefaultValue": _com_apple_compilers_llvm_clang_1_0__CLANG_ENABLE_BOUNDS_SAFETY__DefaultValue,
    "com_apple_compilers_llvm_clang_1_0__CLANG_ENABLE_CODE_COVERAGE__DefaultValue": _com_apple_compilers_llvm_clang_1_0__CLANG_ENABLE_CODE_COVERAGE__DefaultValue,
    "com_apple_compilers_llvm_clang_1_0__CLANG_ENABLE_CPP_STATIC_DESTRUCTORS__DefaultValue": _com_apple_compilers_llvm_clang_1_0__CLANG_ENABLE_CPP_STATIC_DESTRUCTORS__DefaultValue,
    "com_apple_compilers_llvm_clang_1_0__CLANG_ENABLE_MODULES__DefaultValue": _com_apple_compilers_llvm_clang_1_0__CLANG_ENABLE_MODULES__DefaultValue,
    "com_apple_compilers_llvm_clang_1_0__CLANG_ENABLE_MODULE_DEBUGGING__DefaultValue": _com_apple_compilers_llvm_clang_1_0__CLANG_ENABLE_MODULE_DEBUGGING__DefaultValue,
    "com_apple_compilers_llvm_clang_1_0__CLANG_ENABLE_MODULE_IMPLEMENTATION_OF__Condition": _com_apple_compilers_llvm_clang_1_0__CLANG_ENABLE_MODULE_IMPLEMENTATION_OF__Condition,
    "com_apple_compilers_llvm_clang_1_0__CLANG_ENABLE_MODULE_IMPLEMENTATION_OF__DefaultValue": _com_apple_compilers_llvm_clang_1_0__CLANG_ENABLE_MODULE_IMPLEMENTATION_OF__DefaultValue,
    "com_apple_compilers_llvm_clang_1_0__CLANG_ENABLE_OBJC_ARC_EXCEPTIONS__DefaultValue": _com_apple_compilers_llvm_clang_1_0__CLANG_ENABLE_OBJC_ARC_EXCEPTIONS__DefaultValue,
    "com_apple_compilers_llvm_clang_1_0__CLANG_ENABLE_OBJC_ARC__DefaultValue": _com_apple_compilers_llvm_clang_1_0__CLANG_ENABLE_OBJC_ARC__DefaultValue,
    "com_apple_compilers_llvm_clang_1_0__CLANG_ENABLE_OBJC_WEAK__DefaultValue": _com_apple_compilers_llvm_clang_1_0__CLANG_ENABLE_OBJC_WEAK__DefaultValue,
    "com_apple_compilers_llvm_clang_1_0__CLANG_ENABLE_PREFIX_MAPPING__Condition": _com_apple_compilers_llvm_clang_1_0__CLANG_ENABLE_PREFIX_MAPPING__Condition,
    "com_apple_compilers_llvm_clang_1_0__CLANG_INDEX_STORE_ENABLE__Condition": _com_apple_compilers_llvm_clang_1_0__CLANG_INDEX_STORE_ENABLE__Condition,
    "com_apple_compilers_llvm_clang_1_0__CLANG_INDEX_STORE_ENABLE__DefaultValue": _com_apple_compilers_llvm_clang_1_0__CLANG_INDEX_STORE_ENABLE__DefaultValue,
    "com_apple_compilers_llvm_clang_1_0__CLANG_INDEX_STORE_PATH__DefaultValue": _com_apple_compilers_llvm_clang_1_0__CLANG_INDEX_STORE_PATH__DefaultValue,
    "com_apple_compilers_llvm_clang_1_0__CLANG_INSTRUMENT_FOR_OPTIMIZATION_PROFILING__DefaultValue": _com_apple_compilers_llvm_clang_1_0__CLANG_INSTRUMENT_FOR_OPTIMIZATION_PROFILING__DefaultValue,
    "com_apple_compilers_llvm_clang_1_0__CLANG_LIBFUZZER__DefaultValue": _com_apple_compilers_llvm_clang_1_0__CLANG_LIBFUZZER__DefaultValue,
    "com_apple_compilers_llvm_clang_1_0__CLANG_LINK_OBJC_RUNTIME__DefaultValue": _com_apple_compilers_llvm_clang_1_0__CLANG_LINK_OBJC_RUNTIME__DefaultValue,
    "com_apple_compilers_llvm_clang_1_0__CLANG_MACRO_BACKTRACE_LIMIT__DefaultValue": _com_apple_compilers_llvm_clang_1_0__CLANG_MACRO_BACKTRACE_LIMIT__DefaultValue,
    "com_apple_compilers_llvm_clang_1_0__CLANG_MODULES_AUTOLINK__Condition": _com_apple_compilers_llvm_clang_1_0__CLANG_MODULES_AUTOLINK__Condition,
    "com_apple_compilers_llvm_clang_1_0__CLANG_MODULES_AUTOLINK__DefaultValue": _com_apple_compilers_llvm_clang_1_0__CLANG_MODULES_AUTOLINK__DefaultValue,
    "com_apple_compilers_llvm_clang_1_0__CLANG_MODULES_BUILD_SESSION_FILE__Condition": _com_apple_compilers_llvm_clang_1_0__CLANG_MODULES_BUILD_SESSION_FILE__Condition,
    "com_apple_compilers_llvm_clang_1_0__CLANG_MODULES_BUILD_SESSION_FILE__DefaultValue": _com_apple_compilers_llvm_clang_1_0__CLANG_MODULES_BUILD_SESSION_FILE__DefaultValue,
    "com_apple_compilers_llvm_clang_1_0__CLANG_MODULES_DISABLE_PRIVATE_WARNING__Condition": _com_apple_compilers_llvm_clang_1_0__CLANG_MODULES_DISABLE_PRIVATE_WARNING__Condition,
    "com_apple_compilers_llvm_clang_1_0__CLANG_MODULES_DISABLE_PRIVATE_WARNING__DefaultValue": _com_apple_compilers_llvm_clang_1_0__CLANG_MODULES_DISABLE_PRIVATE_WARNING__DefaultValue,
    "com_apple_compilers_llvm_clang_1_0__CLANG_MODULES_IGNORE_MACROS__Condition": _com_apple_compilers_llvm_clang_1_0__CLANG_MODULES_IGNORE_MACROS__Condition,
    "com_apple_compilers_llvm_clang_1_0__CLANG_MODULES_IGNORE_MACROS__DefaultValue": _com_apple_compilers_llvm_clang_1_0__CLANG_MODULES_IGNORE_MACROS__DefaultValue,
    "com_apple_compilers_llvm_clang_1_0__CLANG_MODULES_PRUNE_AFTER__Condition": _com_apple_compilers_llvm_clang_1_0__CLANG_MODULES_PRUNE_AFTER__Condition,
    "com_apple_compilers_llvm_clang_1_0__CLANG_MODULES_PRUNE_AFTER__DefaultValue": _com_apple_compilers_llvm_clang_1_0__CLANG_MODULES_PRUNE_AFTER__DefaultValue,
    "com_apple_compilers_llvm_clang_1_0__CLANG_MODULES_PRUNE_INTERVAL__Condition": _com_apple_compilers_llvm_clang_1_0__CLANG_MODULES_PRUNE_INTERVAL__Condition,
    "com_apple_compilers_llvm_clang_1_0__CLANG_MODULES_PRUNE_INTERVAL__DefaultValue": _com_apple_compilers_llvm_clang_1_0__CLANG_MODULES_PRUNE_INTERVAL__DefaultValue,
    "com_apple_compilers_llvm_clang_1_0__CLANG_MODULES_VALIDATE_SYSTEM_HEADERS__Condition": _com_apple_compilers_llvm_clang_1_0__CLANG_MODULES_VALIDATE_SYSTEM_HEADERS__Condition,
    "com_apple_compilers_llvm_clang_1_0__CLANG_MODULES_VALIDATE_SYSTEM_HEADERS__DefaultValue": _com_apple_compilers_llvm_clang_1_0__CLANG_MODULES_VALIDATE_SYSTEM_HEADERS__DefaultValue,
    "com_apple_compilers_llvm_clang_1_0__CLANG_MODULE_CACHE_PATH__Condition": _com_apple_compilers_llvm_clang_1_0__CLANG_MODULE_CACHE_PATH__Condition,
    "com_apple_compilers_llvm_clang_1_0__CLANG_MODULE_CACHE_PATH__DefaultValue": _com_apple_compilers_llvm_clang_1_0__CLANG_MODULE_CACHE_PATH__DefaultValue,
    "com_apple_compilers_llvm_clang_1_0__CLANG_MODULE_LSV__Condition": _com_apple_compilers_llvm_clang_1_0__CLANG_MODULE_LSV__Condition,
    "com_apple_compilers_llvm_clang_1_0__CLANG_MODULE_LSV__DefaultValue": _com_apple_compilers_llvm_clang_1_0__CLANG_MODULE_LSV__DefaultValue,
    "com_apple_compilers_llvm_clang_1_0__CLANG_OPTIMIZATION_PROFILE_FILE__DefaultValue": _com_apple_compilers_llvm_clang_1_0__CLANG_OPTIMIZATION_PROFILE_FILE__DefaultValue,
    "com_apple_compilers_llvm_clang_1_0__CLANG_OTHER_PREFIX_MAPPINGS__Condition": _com_apple_compilers_llvm_clang_1_0__CLANG_OTHER_PREFIX_MAPPINGS__Condition,
    "com_apple_compilers_llvm_clang_1_0__CLANG_OTHER_PREFIX_MAPPINGS__DefaultValue": _com_apple_compilers_llvm_clang_1_0__CLANG_OTHER_PREFIX_MAPPINGS__DefaultValue,
    "com_apple_compilers_llvm_clang_1_0__CLANG_RETAIN_COMMENTS_FROM_SYSTEM_HEADERS__DefaultValue": _com_apple_compilers_llvm_clang_1_0__CLANG_RETAIN_COMMENTS_FROM_SYSTEM_HEADERS__DefaultValue,
    "com_apple_compilers_llvm_clang_1_0__CLANG_SANITIZER_COVERAGE__Condition": _com_apple_compilers_llvm_clang_1_0__CLANG_SANITIZER_COVERAGE__Condition,
    "com_apple_compilers_llvm_clang_1_0__CLANG_SANITIZER_COVERAGE__DefaultValue": _com_apple_compilers_llvm_clang_1_0__CLANG_SANITIZER_COVERAGE__DefaultValue,
    "com_apple_compilers_llvm_clang_1_0__CLANG_TARGET_TRIPLE_ARCHS__DefaultValue": _com_apple_compilers_llvm_clang_1_0__CLANG_TARGET_TRIPLE_ARCHS__DefaultValue,
    "com_apple_compilers_llvm_clang_1_0__CLANG_THREAD_SANITIZER__DefaultValue": _com_apple_compilers_llvm_clang_1_0__CLANG_THREAD_SANITIZER__DefaultValue,
    "com_apple_compilers_llvm_clang_1_0__CLANG_TRIVIAL_AUTO_VAR_INIT__DefaultValue": _com_apple_compilers_llvm_clang_1_0__CLANG_TRIVIAL_AUTO_VAR_INIT__DefaultValue,
    "com_apple_compilers_llvm_clang_1_0__CLANG_UNDEFINED_BEHAVIOR_SANITIZER_INTEGER__Condition": _com_apple_compilers_llvm_clang_1_0__CLANG_UNDEFINED_BEHAVIOR_SANITIZER_INTEGER__Condition,
    "com_apple_compilers_llvm_clang_1_0__CLANG_UNDEFINED_BEHAVIOR_SANITIZER_INTEGER__DefaultValue": _com_apple_compilers_llvm_clang_1_0__CLANG_UNDEFINED_BEHAVIOR_SANITIZER_INTEGER__DefaultValue,
    "com_apple_compilers_llvm_clang_1_0__CLANG_UNDEFINED_BEHAVIOR_SANITIZER_NULLABILITY__Condition": _com_apple_compilers_llvm_clang_1_0__CLANG_UNDEFINED_BEHAVIOR_SANITIZER_NULLABILITY__Condition,
    "com_apple_compilers_llvm_clang_1_0__CLANG_UNDEFINED_BEHAVIOR_SANITIZER_NULLABILITY__DefaultValue": _com_apple_compilers_llvm_clang_1_0__CLANG_UNDEFINED_BEHAVIOR_SANITIZER_NULLABILITY__DefaultValue,
    "com_apple_compilers_llvm_clang_1_0__CLANG_UNDEFINED_BEHAVIOR_SANITIZER_TRAP_ON_SECURITY_ISSUES_OPT__Condition": _com_apple_compilers_llvm_clang_1_0__CLANG_UNDEFINED_BEHAVIOR_SANITIZER_TRAP_ON_SECURITY_ISSUES_OPT__Condition,
    "com_apple_compilers_llvm_clang_1_0__CLANG_UNDEFINED_BEHAVIOR_SANITIZER_TRAP_ON_SECURITY_ISSUES_OPT__DefaultValue": _com_apple_compilers_llvm_clang_1_0__CLANG_UNDEFINED_BEHAVIOR_SANITIZER_TRAP_ON_SECURITY_ISSUES_OPT__DefaultValue,
    "com_apple_compilers_llvm_clang_1_0__CLANG_UNDEFINED_BEHAVIOR_SANITIZER_TRAP_ON_SECURITY_ISSUES__DefaultValue": _com_apple_compilers_llvm_clang_1_0__CLANG_UNDEFINED_BEHAVIOR_SANITIZER_TRAP_ON_SECURITY_ISSUES__DefaultValue,
    "com_apple_compilers_llvm_clang_1_0__CLANG_UNDEFINED_BEHAVIOR_SANITIZER__DefaultValue": _com_apple_compilers_llvm_clang_1_0__CLANG_UNDEFINED_BEHAVIOR_SANITIZER__DefaultValue,
    "com_apple_compilers_llvm_clang_1_0__CLANG_USE_OPTIMIZATION_PROFILE__Condition": _com_apple_compilers_llvm_clang_1_0__CLANG_USE_OPTIMIZATION_PROFILE__Condition,
    "com_apple_compilers_llvm_clang_1_0__CLANG_USE_OPTIMIZATION_PROFILE__DefaultValue": _com_apple_compilers_llvm_clang_1_0__CLANG_USE_OPTIMIZATION_PROFILE__DefaultValue,
    "com_apple_compilers_llvm_clang_1_0__CLANG_WARN_ASSIGN_ENUM__DefaultValue": _com_apple_compilers_llvm_clang_1_0__CLANG_WARN_ASSIGN_ENUM__DefaultValue,
    "com_apple_compilers_llvm_clang_1_0__CLANG_WARN_ATOMIC_IMPLICIT_SEQ_CST__DefaultValue": _com_apple_compilers_llvm_clang_1_0__CLANG_WARN_ATOMIC_IMPLICIT_SEQ_CST__DefaultValue,
    "com_apple_compilers_llvm_clang_1_0__CLANG_WARN_BLOCK_CAPTURE_AUTORELEASING__DefaultValue": _com_apple_compilers_llvm_clang_1_0__CLANG_WARN_BLOCK_CAPTURE_AUTORELEASING__DefaultValue,
    "com_apple_compilers_llvm_clang_1_0__CLANG_WARN_BOOL_CONVERSION__DefaultValue": _com_apple_compilers_llvm_clang_1_0__CLANG_WARN_BOOL_CONVERSION__DefaultValue,
    "com_apple_compilers_llvm_clang_1_0__CLANG_WARN_COMMA__DefaultValue": _com_apple_compilers_llvm_clang_1_0__CLANG_WARN_COMMA__DefaultValue,
    "com_apple_compilers_llvm_clang_1_0__CLANG_WARN_COMPLETION_HANDLER_MISUSE__DefaultValue": _com_apple_compilers_llvm_clang_1_0__CLANG_WARN_COMPLETION_HANDLER_MISUSE__DefaultValue,
    "com_apple_compilers_llvm_clang_1_0__CLANG_WARN_CONSTANT_CONVERSION__DefaultValue": _com_apple_compilers_llvm_clang_1_0__CLANG_WARN_CONSTANT_CONVERSION__DefaultValue,
    "com_apple_compilers_llvm_clang_1_0__CLANG_WARN_CXX0X_EXTENSIONS__DefaultValue": _com_apple_compilers_llvm_clang_1_0__CLANG_WARN_CXX0X_EXTENSIONS__DefaultValue,
    "com_apple_compilers_llvm_clang_1_0__CLANG_WARN_DELETE_NON_VIRTUAL_DTOR__DefaultValue": _com_apple_compilers_llvm_clang_1_0__CLANG_WARN_DELETE_NON_VIRTUAL_DTOR__DefaultValue,
    "com_apple_compilers_llvm_clang_1_0__CLANG_WARN_DEPRECATED_OBJC_IMPLEMENTATIONS__DefaultValue": _com_apple_compilers_llvm_clang_1_0__CLANG_WARN_DEPRECATED_OBJC_IMPLEMENTATIONS__DefaultValue,
    "com_apple_compilers_llvm_clang_1_0__CLANG_WARN_DIRECT_OBJC_ISA_USAGE__DefaultValue": _com_apple_compilers_llvm_clang_1_0__CLANG_WARN_DIRECT_OBJC_ISA_USAGE__DefaultValue,
    "com_apple_compilers_llvm_clang_1_0__CLANG_WARN_DOCUMENTATION_COMMENTS__DefaultValue": _com_apple_compilers_llvm_clang_1_0__CLANG_WARN_DOCUMENTATION_COMMENTS__DefaultValue,
    "com_apple_compilers_llvm_clang_1_0__CLANG_WARN_EMPTY_BODY__DefaultValue": _com_apple_compilers_llvm_clang_1_0__CLANG_WARN_EMPTY_BODY__DefaultValue,
    "com_apple_compilers_llvm_clang_1_0__CLANG_WARN_ENUM_CONVERSION__DefaultValue": _com_apple_compilers_llvm_clang_1_0__CLANG_WARN_ENUM_CONVERSION__DefaultValue,
    "com_apple_compilers_llvm_clang_1_0__CLANG_WARN_FLOAT_CONVERSION__DefaultValue": _com_apple_compilers_llvm_clang_1_0__CLANG_WARN_FLOAT_CONVERSION__DefaultValue,
    "com_apple_compilers_llvm_clang_1_0__CLANG_WARN_FRAMEWORK_INCLUDE_PRIVATE_FROM_PUBLIC__DefaultValue": _com_apple_compilers_llvm_clang_1_0__CLANG_WARN_FRAMEWORK_INCLUDE_PRIVATE_FROM_PUBLIC__DefaultValue,
    "com_apple_compilers_llvm_clang_1_0__CLANG_WARN_IMPLICIT_FALLTHROUGH__DefaultValue": _com_apple_compilers_llvm_clang_1_0__CLANG_WARN_IMPLICIT_FALLTHROUGH__DefaultValue,
    "com_apple_compilers_llvm_clang_1_0__CLANG_WARN_IMPLICIT_SIGN_CONVERSION__DefaultValue": _com_apple_compilers_llvm_clang_1_0__CLANG_WARN_IMPLICIT_SIGN_CONVERSION__DefaultValue,
    "com_apple_compilers_llvm_clang_1_0__CLANG_WARN_INFINITE_RECURSION__DefaultValue": _com_apple_compilers_llvm_clang_1_0__CLANG_WARN_INFINITE_RECURSION__DefaultValue,
    "com_apple_compilers_llvm_clang_1_0__CLANG_WARN_INT_CONVERSION__DefaultValue": _com_apple_compilers_llvm_clang_1_0__CLANG_WARN_INT_CONVERSION__DefaultValue,
    "com_apple_compilers_llvm_clang_1_0__CLANG_WARN_MISSING_NOESCAPE__DefaultValue": _com_apple_compilers_llvm_clang_1_0__CLANG_WARN_MISSING_NOESCAPE__DefaultValue,
    "com_apple_compilers_llvm_clang_1_0__CLANG_WARN_NON_LITERAL_NULL_CONVERSION__DefaultValue": _com_apple_compilers_llvm_clang_1_0__CLANG_WARN_NON_LITERAL_NULL_CONVERSION__DefaultValue,
    "com_apple_compilers_llvm_clang_1_0__CLANG_WARN_NULLABLE_TO_NONNULL_CONVERSION__DefaultValue": _com_apple_compilers_llvm_clang_1_0__CLANG_WARN_NULLABLE_TO_NONNULL_CONVERSION__DefaultValue,
    "com_apple_compilers_llvm_clang_1_0__CLANG_WARN_OBJC_EXPLICIT_OWNERSHIP_TYPE__DefaultValue": _com_apple_compilers_llvm_clang_1_0__CLANG_WARN_OBJC_EXPLICIT_OWNERSHIP_TYPE__DefaultValue,
    "com_apple_compilers_llvm_clang_1_0__CLANG_WARN_OBJC_IMPLICIT_ATOMIC_PROPERTIES__DefaultValue": _com_apple_compilers_llvm_clang_1_0__CLANG_WARN_OBJC_IMPLICIT_ATOMIC_PROPERTIES__DefaultValue,
    "com_apple_compilers_llvm_clang_1_0__CLANG_WARN_OBJC_IMPLICIT_RETAIN_SELF__DefaultValue": _com_apple_compilers_llvm_clang_1_0__CLANG_WARN_OBJC_IMPLICIT_RETAIN_SELF__DefaultValue,
    "com_apple_compilers_llvm_clang_1_0__CLANG_WARN_OBJC_INTERFACE_IVARS__DefaultValue": _com_apple_compilers_llvm_clang_1_0__CLANG_WARN_OBJC_INTERFACE_IVARS__DefaultValue,
    "com_apple_compilers_llvm_clang_1_0__CLANG_WARN_OBJC_LITERAL_CONVERSION__DefaultValue": _com_apple_compilers_llvm_clang_1_0__CLANG_WARN_OBJC_LITERAL_CONVERSION__DefaultValue,
    "com_apple_compilers_llvm_clang_1_0__CLANG_WARN_OBJC_MISSING_PROPERTY_SYNTHESIS__DefaultValue": _com_apple_compilers_llvm_clang_1_0__CLANG_WARN_OBJC_MISSING_PROPERTY_SYNTHESIS__DefaultValue,
    "com_apple_compilers_llvm_clang_1_0__CLANG_WARN_OBJC_REPEATED_USE_OF_WEAK__DefaultValue": _com_apple_compilers_llvm_clang_1_0__CLANG_WARN_OBJC_REPEATED_USE_OF_WEAK__DefaultValue,
    "com_apple_compilers_llvm_clang_1_0__CLANG_WARN_OBJC_ROOT_CLASS__DefaultValue": _com_apple_compilers_llvm_clang_1_0__CLANG_WARN_OBJC_ROOT_CLASS__DefaultValue,
    "com_apple_compilers_llvm_clang_1_0__CLANG_WARN_PRAGMA_PACK__DefaultValue": _com_apple_compilers_llvm_clang_1_0__CLANG_WARN_PRAGMA_PACK__DefaultValue,
    "com_apple_compilers_llvm_clang_1_0__CLANG_WARN_PRIVATE_MODULE__DefaultValue": _com_apple_compilers_llvm_clang_1_0__CLANG_WARN_PRIVATE_MODULE__DefaultValue,
    "com_apple_compilers_llvm_clang_1_0__CLANG_WARN_QUOTED_INCLUDE_IN_FRAMEWORK_HEADER__DefaultValue": _com_apple_compilers_llvm_clang_1_0__CLANG_WARN_QUOTED_INCLUDE_IN_FRAMEWORK_HEADER__DefaultValue,
    "com_apple_compilers_llvm_clang_1_0__CLANG_WARN_RANGE_LOOP_ANALYSIS__DefaultValue": _com_apple_compilers_llvm_clang_1_0__CLANG_WARN_RANGE_LOOP_ANALYSIS__DefaultValue,
    "com_apple_compilers_llvm_clang_1_0__CLANG_WARN_SEMICOLON_BEFORE_METHOD_BODY__DefaultValue": _com_apple_compilers_llvm_clang_1_0__CLANG_WARN_SEMICOLON_BEFORE_METHOD_BODY__DefaultValue,
    "com_apple_compilers_llvm_clang_1_0__CLANG_WARN_STRICT_PROTOTYPES__DefaultValue": _com_apple_compilers_llvm_clang_1_0__CLANG_WARN_STRICT_PROTOTYPES__DefaultValue,
    "com_apple_compilers_llvm_clang_1_0__CLANG_WARN_SUSPICIOUS_IMPLICIT_CONVERSION__DefaultValue": _com_apple_compilers_llvm_clang_1_0__CLANG_WARN_SUSPICIOUS_IMPLICIT_CONVERSION__DefaultValue,
    "com_apple_compilers_llvm_clang_1_0__CLANG_WARN_SUSPICIOUS_MOVE__DefaultValue": _com_apple_compilers_llvm_clang_1_0__CLANG_WARN_SUSPICIOUS_MOVE__DefaultValue,
    "com_apple_compilers_llvm_clang_1_0__CLANG_WARN_UNGUARDED_AVAILABILITY__DefaultValue": _com_apple_compilers_llvm_clang_1_0__CLANG_WARN_UNGUARDED_AVAILABILITY__DefaultValue,
    "com_apple_compilers_llvm_clang_1_0__CLANG_WARN_UNREACHABLE_CODE__DefaultValue": _com_apple_compilers_llvm_clang_1_0__CLANG_WARN_UNREACHABLE_CODE__DefaultValue,
    "com_apple_compilers_llvm_clang_1_0__CLANG_WARN_VEXING_PARSE__DefaultValue": _com_apple_compilers_llvm_clang_1_0__CLANG_WARN_VEXING_PARSE__DefaultValue,
    "com_apple_compilers_llvm_clang_1_0__CLANG_WARN_XNU_TYPED_ALLOCATORS__DefaultValue": _com_apple_compilers_llvm_clang_1_0__CLANG_WARN_XNU_TYPED_ALLOCATORS__DefaultValue,
    "com_apple_compilers_llvm_clang_1_0__CLANG_WARN__ARC_BRIDGE_CAST_NONARC__DefaultValue": _com_apple_compilers_llvm_clang_1_0__CLANG_WARN__ARC_BRIDGE_CAST_NONARC__DefaultValue,
    "com_apple_compilers_llvm_clang_1_0__CLANG_WARN__DUPLICATE_METHOD_MATCH__DefaultValue": _com_apple_compilers_llvm_clang_1_0__CLANG_WARN__DUPLICATE_METHOD_MATCH__DefaultValue,
    "com_apple_compilers_llvm_clang_1_0__CLANG_WARN__EXIT_TIME_DESTRUCTORS__DefaultValue": _com_apple_compilers_llvm_clang_1_0__CLANG_WARN__EXIT_TIME_DESTRUCTORS__DefaultValue,
    "com_apple_compilers_llvm_clang_1_0__CLANG_X86_VECTOR_INSTRUCTIONS__DefaultValue": _com_apple_compilers_llvm_clang_1_0__CLANG_X86_VECTOR_INSTRUCTIONS__DefaultValue,
    "com_apple_compilers_llvm_clang_1_0__CPP_HEADERMAP_FILE_FOR_ALL_NON_FRAMEWORK_TARGET_HEADERS__DefaultValue": _com_apple_compilers_llvm_clang_1_0__CPP_HEADERMAP_FILE_FOR_ALL_NON_FRAMEWORK_TARGET_HEADERS__DefaultValue,
    "com_apple_compilers_llvm_clang_1_0__CPP_HEADERMAP_FILE_FOR_ALL_TARGET_HEADERS__DefaultValue": _com_apple_compilers_llvm_clang_1_0__CPP_HEADERMAP_FILE_FOR_ALL_TARGET_HEADERS__DefaultValue,
    "com_apple_compilers_llvm_clang_1_0__CPP_HEADERMAP_FILE_FOR_GENERATED_FILES__DefaultValue": _com_apple_compilers_llvm_clang_1_0__CPP_HEADERMAP_FILE_FOR_GENERATED_FILES__DefaultValue,
    "com_apple_compilers_llvm_clang_1_0__CPP_HEADERMAP_FILE_FOR_OWN_TARGET_HEADERS__DefaultValue": _com_apple_compilers_llvm_clang_1_0__CPP_HEADERMAP_FILE_FOR_OWN_TARGET_HEADERS__DefaultValue,
    "com_apple_compilers_llvm_clang_1_0__CPP_HEADERMAP_FILE_FOR_PROJECT_FILES__DefaultValue": _com_apple_compilers_llvm_clang_1_0__CPP_HEADERMAP_FILE_FOR_PROJECT_FILES__DefaultValue,
    "com_apple_compilers_llvm_clang_1_0__CPP_HEADERMAP_FILE__DefaultValue": _com_apple_compilers_llvm_clang_1_0__CPP_HEADERMAP_FILE__DefaultValue,
    "com_apple_compilers_llvm_clang_1_0__CPP_HEADERMAP_PRODUCT_HEADERS_VFS_FILE__DefaultValue": _com_apple_compilers_llvm_clang_1_0__CPP_HEADERMAP_PRODUCT_HEADERS_VFS_FILE__DefaultValue,
    "com_apple_compilers_llvm_clang_1_0__CPP_HEADER_SYMLINKS_DIR__DefaultValue": _com_apple_compilers_llvm_clang_1_0__CPP_HEADER_SYMLINKS_DIR__DefaultValue,
    "com_apple_compilers_llvm_clang_1_0__DEFAULT_SSE_LEVEL_3_NO__DefaultValue": _com_apple_compilers_llvm_clang_1_0__DEFAULT_SSE_LEVEL_3_NO__DefaultValue,
    "com_apple_compilers_llvm_clang_1_0__DEFAULT_SSE_LEVEL_3_SUPPLEMENTAL_NO__DefaultValue": _com_apple_compilers_llvm_clang_1_0__DEFAULT_SSE_LEVEL_3_SUPPLEMENTAL_NO__DefaultValue,
    "com_apple_compilers_llvm_clang_1_0__DEFAULT_SSE_LEVEL_3_SUPPLEMENTAL_YES__DefaultValue": _com_apple_compilers_llvm_clang_1_0__DEFAULT_SSE_LEVEL_3_SUPPLEMENTAL_YES__DefaultValue,
    "com_apple_compilers_llvm_clang_1_0__DEFAULT_SSE_LEVEL_3_YES__DefaultValue": _com_apple_compilers_llvm_clang_1_0__DEFAULT_SSE_LEVEL_3_YES__DefaultValue,
    "com_apple_compilers_llvm_clang_1_0__DEFAULT_SSE_LEVEL_4_1_NO__DefaultValue": _com_apple_compilers_llvm_clang_1_0__DEFAULT_SSE_LEVEL_4_1_NO__DefaultValue,
    "com_apple_compilers_llvm_clang_1_0__DEFAULT_SSE_LEVEL_4_1_YES__DefaultValue": _com_apple_compilers_llvm_clang_1_0__DEFAULT_SSE_LEVEL_4_1_YES__DefaultValue,
    "com_apple_compilers_llvm_clang_1_0__DEFAULT_SSE_LEVEL_4_2_NO__DefaultValue": _com_apple_compilers_llvm_clang_1_0__DEFAULT_SSE_LEVEL_4_2_NO__DefaultValue,
    "com_apple_compilers_llvm_clang_1_0__DEFAULT_SSE_LEVEL_4_2_YES__DefaultValue": _com_apple_compilers_llvm_clang_1_0__DEFAULT_SSE_LEVEL_4_2_YES__DefaultValue,
    "com_apple_compilers_llvm_clang_1_0__ENABLE_APPLE_KEXT_CODE_GENERATION__DefaultValue": _com_apple_compilers_llvm_clang_1_0__ENABLE_APPLE_KEXT_CODE_GENERATION__DefaultValue,
    "com_apple_compilers_llvm_clang_1_0__ENABLE_NS_ASSERTIONS__DefaultValue": _com_apple_compilers_llvm_clang_1_0__ENABLE_NS_ASSERTIONS__DefaultValue,
    "com_apple_compilers_llvm_clang_1_0__ENABLE_STRICT_OBJC_MSGSEND__DefaultValue": _com_apple_compilers_llvm_clang_1_0__ENABLE_STRICT_OBJC_MSGSEND__DefaultValue,
    "com_apple_compilers_llvm_clang_1_0__GCC_CHAR_IS_UNSIGNED_CHAR__DefaultValue": _com_apple_compilers_llvm_clang_1_0__GCC_CHAR_IS_UNSIGNED_CHAR__DefaultValue,
    "com_apple_compilers_llvm_clang_1_0__GCC_CW_ASM_SYNTAX__DefaultValue": _com_apple_compilers_llvm_clang_1_0__GCC_CW_ASM_SYNTAX__DefaultValue,
    "com_apple_compilers_llvm_clang_1_0__GCC_C_LANGUAGE_STANDARD__DefaultValue": _com_apple_compilers_llvm_clang_1_0__GCC_C_LANGUAGE_STANDARD__DefaultValue,
    "com_apple_compilers_llvm_clang_1_0__GCC_DEBUG_INFORMATION_FORMAT__Condition": _com_apple_compilers_llvm_clang_1_0__GCC_DEBUG_INFORMATION_FORMAT__Condition,
    "com_apple_compilers_llvm_clang_1_0__GCC_DEBUG_INFORMATION_FORMAT__DefaultValue": _com_apple_compilers_llvm_clang_1_0__GCC_DEBUG_INFORMATION_FORMAT__DefaultValue,
    "com_apple_compilers_llvm_clang_1_0__GCC_DYNAMIC_NO_PIC__DefaultValue": _com_apple_compilers_llvm_clang_1_0__GCC_DYNAMIC_NO_PIC__DefaultValue,
    "com_apple_compilers_llvm_clang_1_0__GCC_ENABLE_ASM_KEYWORD__DefaultValue": _com_apple_compilers_llvm_clang_1_0__GCC_ENABLE_ASM_KEYWORD__DefaultValue,
    "com_apple_compilers_llvm_clang_1_0__GCC_ENABLE_BUILTIN_FUNCTIONS__DefaultValue": _com_apple_compilers_llvm_clang_1_0__GCC_ENABLE_BUILTIN_FUNCTIONS__DefaultValue,
    "com_apple_compilers_llvm_clang_1_0__GCC_ENABLE_CPP_EXCEPTIONS__DefaultValue": _com_apple_compilers_llvm_clang_1_0__GCC_ENABLE_CPP_EXCEPTIONS__DefaultValue,
    "com_apple_compilers_llvm_clang_1_0__GCC_ENABLE_CPP_RTTI__DefaultValue": _com_apple_compilers_llvm_clang_1_0__GCC_ENABLE_CPP_RTTI__DefaultValue,
    "com_apple_compilers_llvm_clang_1_0__GCC_ENABLE_EXCEPTIONS__DefaultValue": _com_apple_compilers_llvm_clang_1_0__GCC_ENABLE_EXCEPTIONS__DefaultValue,
    "com_apple_compilers_llvm_clang_1_0__GCC_ENABLE_FLOATING_POINT_LIBRARY_CALLS__DefaultValue": _com_apple_compilers_llvm_clang_1_0__GCC_ENABLE_FLOATING_POINT_LIBRARY_CALLS__DefaultValue,
    "com_apple_compilers_llvm_clang_1_0__GCC_ENABLE_KERNEL_DEVELOPMENT__DefaultValue": _com_apple_compilers_llvm_clang_1_0__GCC_ENABLE_KERNEL_DEVELOPMENT__DefaultValue,
    "com_apple_compilers_llvm_clang_1_0__GCC_ENABLE_OBJC_EXCEPTIONS__DefaultValue": _com_apple_compilers_llvm_clang_1_0__GCC_ENABLE_OBJC_EXCEPTIONS__DefaultValue,
    "com_apple_compilers_llvm_clang_1_0__GCC_ENABLE_PASCAL_STRINGS__DefaultValue": _com_apple_compilers_llvm_clang_1_0__GCC_ENABLE_PASCAL_STRINGS__DefaultValue,
    "com_apple_compilers_llvm_clang_1_0__GCC_ENABLE_SSE3_EXTENSIONS__DefaultValue": _com_apple_compilers_llvm_clang_1_0__GCC_ENABLE_SSE3_EXTENSIONS__DefaultValue,
    "com_apple_compilers_llvm_clang_1_0__GCC_ENABLE_SSE41_EXTENSIONS__DefaultValue": _com_apple_compilers_llvm_clang_1_0__GCC_ENABLE_SSE41_EXTENSIONS__DefaultValue,
    "com_apple_compilers_llvm_clang_1_0__GCC_ENABLE_SSE42_EXTENSIONS__DefaultValue": _com_apple_compilers_llvm_clang_1_0__GCC_ENABLE_SSE42_EXTENSIONS__DefaultValue,
    "com_apple_compilers_llvm_clang_1_0__GCC_ENABLE_SUPPLEMENTAL_SSE3_INSTRUCTIONS__DefaultValue": _com_apple_compilers_llvm_clang_1_0__GCC_ENABLE_SUPPLEMENTAL_SSE3_INSTRUCTIONS__DefaultValue,
    "com_apple_compilers_llvm_clang_1_0__GCC_ENABLE_TRIGRAPHS__DefaultValue": _com_apple_compilers_llvm_clang_1_0__GCC_ENABLE_TRIGRAPHS__DefaultValue,
    "com_apple_compilers_llvm_clang_1_0__GCC_FAST_MATH__Condition": _com_apple_compilers_llvm_clang_1_0__GCC_FAST_MATH__Condition,
    "com_apple_compilers_llvm_clang_1_0__GCC_FAST_MATH__DefaultValue": _com_apple_compilers_llvm_clang_1_0__GCC_FAST_MATH__DefaultValue,
    "com_apple_compilers_llvm_clang_1_0__GCC_GENERATE_DEBUGGING_SYMBOLS__DefaultValue": _com_apple_compilers_llvm_clang_1_0__GCC_GENERATE_DEBUGGING_SYMBOLS__DefaultValue,
    "com_apple_compilers_llvm_clang_1_0__GCC_GENERATE_TEST_COVERAGE_FILES__DefaultValue": _com_apple_compilers_llvm_clang_1_0__GCC_GENERATE_TEST_COVERAGE_FILES__DefaultValue,
    "com_apple_compilers_llvm_clang_1_0__GCC_INCREASE_PRECOMPILED_HEADER_SHARING__DefaultValue": _com_apple_compilers_llvm_clang_1_0__GCC_INCREASE_PRECOMPILED_HEADER_SHARING__DefaultValue,
    "com_apple_compilers_llvm_clang_1_0__GCC_INLINES_ARE_PRIVATE_EXTERN__DefaultValue": _com_apple_compilers_llvm_clang_1_0__GCC_INLINES_ARE_PRIVATE_EXTERN__DefaultValue,
    "com_apple_compilers_llvm_clang_1_0__GCC_INPUT_FILETYPE__DefaultValue": _com_apple_compilers_llvm_clang_1_0__GCC_INPUT_FILETYPE__DefaultValue,
    "com_apple_compilers_llvm_clang_1_0__GCC_INSTRUMENT_PROGRAM_FLOW_ARCS__DefaultValue": _com_apple_compilers_llvm_clang_1_0__GCC_INSTRUMENT_PROGRAM_FLOW_ARCS__DefaultValue,
    "com_apple_compilers_llvm_clang_1_0__GCC_LINK_WITH_DYNAMIC_LIBRARIES__DefaultValue": _com_apple_compilers_llvm_clang_1_0__GCC_LINK_WITH_DYNAMIC_LIBRARIES__DefaultValue,
    "com_apple_compilers_llvm_clang_1_0__GCC_NO_COMMON_BLOCKS__DefaultValue": _com_apple_compilers_llvm_clang_1_0__GCC_NO_COMMON_BLOCKS__DefaultValue,
    "com_apple_compilers_llvm_clang_1_0__GCC_OBJC_ABI_VERSION__DefaultValue": _com_apple_compilers_llvm_clang_1_0__GCC_OBJC_ABI_VERSION__DefaultValue,
    "com_apple_compilers_llvm_clang_1_0__GCC_OBJC_LEGACY_DISPATCH__DefaultValue": _com_apple_compilers_llvm_clang_1_0__GCC_OBJC_LEGACY_DISPATCH__DefaultValue,
    "com_apple_compilers_llvm_clang_1_0__GCC_OPERATION__DefaultValue": _com_apple_compilers_llvm_clang_1_0__GCC_OPERATION__DefaultValue,
    "com_apple_compilers_llvm_clang_1_0__GCC_OPTIMIZATION_LEVEL__DefaultValue": _com_apple_compilers_llvm_clang_1_0__GCC_OPTIMIZATION_LEVEL__DefaultValue,
    "com_apple_compilers_llvm_clang_1_0__GCC_PFE_FILE_C_DIALECTS__DefaultValue": _com_apple_compilers_llvm_clang_1_0__GCC_PFE_FILE_C_DIALECTS__DefaultValue,
    "com_apple_compilers_llvm_clang_1_0__GCC_PRECOMPILE_PREFIX_HEADER__DefaultValue": _com_apple_compilers_llvm_clang_1_0__GCC_PRECOMPILE_PREFIX_HEADER__DefaultValue,
    "com_apple_compilers_llvm_clang_1_0__GCC_PREFIX_HEADER__DefaultValue": _com_apple_compilers_llvm_clang_1_0__GCC_PREFIX_HEADER__DefaultValue,
    "com_apple_compilers_llvm_clang_1_0__GCC_PREPROCESSOR_DEFINITIONS_NOT_USED_IN_PRECOMPS__DefaultValue": _com_apple_compilers_llvm_clang_1_0__GCC_PREPROCESSOR_DEFINITIONS_NOT_USED_IN_PRECOMPS__DefaultValue,
    "com_apple_compilers_llvm_clang_1_0__GCC_PREPROCESSOR_DEFINITIONS__DefaultValue": _com_apple_compilers_llvm_clang_1_0__GCC_PREPROCESSOR_DEFINITIONS__DefaultValue,
    "com_apple_compilers_llvm_clang_1_0__GCC_PRODUCT_TYPE_PREPROCESSOR_DEFINITIONS__DefaultValue": _com_apple_compilers_llvm_clang_1_0__GCC_PRODUCT_TYPE_PREPROCESSOR_DEFINITIONS__DefaultValue,
    "com_apple_compilers_llvm_clang_1_0__GCC_REUSE_STRINGS__DefaultValue": _com_apple_compilers_llvm_clang_1_0__GCC_REUSE_STRINGS__DefaultValue,
    "com_apple_compilers_llvm_clang_1_0__GCC_SHORT_ENUMS__DefaultValue": _com_apple_compilers_llvm_clang_1_0__GCC_SHORT_ENUMS__DefaultValue,
    "com_apple_compilers_llvm_clang_1_0__GCC_STRICT_ALIASING__DefaultValue": _com_apple_compilers_llvm_clang_1_0__GCC_STRICT_ALIASING__DefaultValue,
    "com_apple_compilers_llvm_clang_1_0__GCC_SYMBOLS_PRIVATE_EXTERN__DefaultValue": _com_apple_compilers_llvm_clang_1_0__GCC_SYMBOLS_PRIVATE_EXTERN__DefaultValue,
    "com_apple_compilers_llvm_clang_1_0__GCC_THREADSAFE_STATICS__DefaultValue": _com_apple_compilers_llvm_clang_1_0__GCC_THREADSAFE_STATICS__DefaultValue,
    "com_apple_compilers_llvm_clang_1_0__GCC_TREAT_IMPLICIT_FUNCTION_DECLARATIONS_AS_ERRORS__DefaultValue": _com_apple_compilers_llvm_clang_1_0__GCC_TREAT_IMPLICIT_FUNCTION_DECLARATIONS_AS_ERRORS__DefaultValue,
    "com_apple_compilers_llvm_clang_1_0__GCC_TREAT_INCOMPATIBLE_POINTER_TYPE_WARNINGS_AS_ERRORS__DefaultValue": _com_apple_compilers_llvm_clang_1_0__GCC_TREAT_INCOMPATIBLE_POINTER_TYPE_WARNINGS_AS_ERRORS__DefaultValue,
    "com_apple_compilers_llvm_clang_1_0__GCC_TREAT_WARNINGS_AS_ERRORS__DefaultValue": _com_apple_compilers_llvm_clang_1_0__GCC_TREAT_WARNINGS_AS_ERRORS__DefaultValue,
    "com_apple_compilers_llvm_clang_1_0__GCC_UNROLL_LOOPS__DefaultValue": _com_apple_compilers_llvm_clang_1_0__GCC_UNROLL_LOOPS__DefaultValue,
    "com_apple_compilers_llvm_clang_1_0__GCC_USE_GCC3_PFE_SUPPORT__DefaultValue": _com_apple_compilers_llvm_clang_1_0__GCC_USE_GCC3_PFE_SUPPORT__DefaultValue,
    "com_apple_compilers_llvm_clang_1_0__GCC_USE_STANDARD_INCLUDE_SEARCHING__DefaultValue": _com_apple_compilers_llvm_clang_1_0__GCC_USE_STANDARD_INCLUDE_SEARCHING__DefaultValue,
    "com_apple_compilers_llvm_clang_1_0__GCC_WARN_64_TO_32_BIT_CONVERSION__DefaultValue": _com_apple_compilers_llvm_clang_1_0__GCC_WARN_64_TO_32_BIT_CONVERSION__DefaultValue,
    "com_apple_compilers_llvm_clang_1_0__GCC_WARN_ABOUT_DEPRECATED_FUNCTIONS__DefaultValue": _com_apple_compilers_llvm_clang_1_0__GCC_WARN_ABOUT_DEPRECATED_FUNCTIONS__DefaultValue,
    "com_apple_compilers_llvm_clang_1_0__GCC_WARN_ABOUT_INVALID_OFFSETOF_MACRO__DefaultValue": _com_apple_compilers_llvm_clang_1_0__GCC_WARN_ABOUT_INVALID_OFFSETOF_MACRO__DefaultValue,
    "com_apple_compilers_llvm_clang_1_0__GCC_WARN_ABOUT_MISSING_FIELD_INITIALIZERS__DefaultValue": _com_apple_compilers_llvm_clang_1_0__GCC_WARN_ABOUT_MISSING_FIELD_INITIALIZERS__DefaultValue,
    "com_apple_compilers_llvm_clang_1_0__GCC_WARN_ABOUT_MISSING_NEWLINE__DefaultValue": _com_apple_compilers_llvm_clang_1_0__GCC_WARN_ABOUT_MISSING_NEWLINE__DefaultValue,
    "com_apple_compilers_llvm_clang_1_0__GCC_WARN_ABOUT_MISSING_PROTOTYPES__DefaultValue": _com_apple_compilers_llvm_clang_1_0__GCC_WARN_ABOUT_MISSING_PROTOTYPES__DefaultValue,
    "com_apple_compilers_llvm_clang_1_0__GCC_WARN_ABOUT_POINTER_SIGNEDNESS__DefaultValue": _com_apple_compilers_llvm_clang_1_0__GCC_WARN_ABOUT_POINTER_SIGNEDNESS__DefaultValue,
    "com_apple_compilers_llvm_clang_1_0__GCC_WARN_ABOUT_RETURN_TYPE__DefaultValue": _com_apple_compilers_llvm_clang_1_0__GCC_WARN_ABOUT_RETURN_TYPE__DefaultValue,
    "com_apple_compilers_llvm_clang_1_0__GCC_WARN_ALLOW_INCOMPLETE_PROTOCOL__DefaultValue": _com_apple_compilers_llvm_clang_1_0__GCC_WARN_ALLOW_INCOMPLETE_PROTOCOL__DefaultValue,
    "com_apple_compilers_llvm_clang_1_0__GCC_WARN_CHECK_SWITCH_STATEMENTS__DefaultValue": _com_apple_compilers_llvm_clang_1_0__GCC_WARN_CHECK_SWITCH_STATEMENTS__DefaultValue,
    "com_apple_compilers_llvm_clang_1_0__GCC_WARN_FOUR_CHARACTER_CONSTANTS__DefaultValue": _com_apple_compilers_llvm_clang_1_0__GCC_WARN_FOUR_CHARACTER_CONSTANTS__DefaultValue,
    "com_apple_compilers_llvm_clang_1_0__GCC_WARN_HIDDEN_VIRTUAL_FUNCTIONS__DefaultValue": _com_apple_compilers_llvm_clang_1_0__GCC_WARN_HIDDEN_VIRTUAL_FUNCTIONS__DefaultValue,
    "com_apple_compilers_llvm_clang_1_0__GCC_WARN_INHIBIT_ALL_WARNINGS__DefaultValue": _com_apple_compilers_llvm_clang_1_0__GCC_WARN_INHIBIT_ALL_WARNINGS__DefaultValue,
    "com_apple_compilers_llvm_clang_1_0__GCC_WARN_INITIALIZER_NOT_FULLY_BRACKETED__DefaultValue": _com_apple_compilers_llvm_clang_1_0__GCC_WARN_INITIALIZER_NOT_FULLY_BRACKETED__DefaultValue,
    "com_apple_compilers_llvm_clang_1_0__GCC_WARN_MISSING_PARENTHESES__DefaultValue": _com_apple_compilers_llvm_clang_1_0__GCC_WARN_MISSING_PARENTHESES__DefaultValue,
    "com_apple_compilers_llvm_clang_1_0__GCC_WARN_MULTIPLE_DEFINITION_TYPES_FOR_SELECTOR__DefaultValue": _com_apple_compilers_llvm_clang_1_0__GCC_WARN_MULTIPLE_DEFINITION_TYPES_FOR_SELECTOR__DefaultValue,
    "com_apple_compilers_llvm_clang_1_0__GCC_WARN_NON_VIRTUAL_DESTRUCTOR__DefaultValue": _com_apple_compilers_llvm_clang_1_0__GCC_WARN_NON_VIRTUAL_DESTRUCTOR__DefaultValue,
    "com_apple_compilers_llvm_clang_1_0__GCC_WARN_PEDANTIC__DefaultValue": _com_apple_compilers_llvm_clang_1_0__GCC_WARN_PEDANTIC__DefaultValue,
    "com_apple_compilers_llvm_clang_1_0__GCC_WARN_SHADOW__DefaultValue": _com_apple_compilers_llvm_clang_1_0__GCC_WARN_SHADOW__DefaultValue,
    "com_apple_compilers_llvm_clang_1_0__GCC_WARN_SIGN_COMPARE__DefaultValue": _com_apple_compilers_llvm_clang_1_0__GCC_WARN_SIGN_COMPARE__DefaultValue,
    "com_apple_compilers_llvm_clang_1_0__GCC_WARN_STRICT_SELECTOR_MATCH__DefaultValue": _com_apple_compilers_llvm_clang_1_0__GCC_WARN_STRICT_SELECTOR_MATCH__DefaultValue,
    "com_apple_compilers_llvm_clang_1_0__GCC_WARN_TYPECHECK_CALLS_TO_PRINTF__DefaultValue": _com_apple_compilers_llvm_clang_1_0__GCC_WARN_TYPECHECK_CALLS_TO_PRINTF__DefaultValue,
    "com_apple_compilers_llvm_clang_1_0__GCC_WARN_UNDECLARED_SELECTOR__DefaultValue": _com_apple_compilers_llvm_clang_1_0__GCC_WARN_UNDECLARED_SELECTOR__DefaultValue,
    "com_apple_compilers_llvm_clang_1_0__GCC_WARN_UNINITIALIZED_AUTOS__DefaultValue": _com_apple_compilers_llvm_clang_1_0__GCC_WARN_UNINITIALIZED_AUTOS__DefaultValue,
    "com_apple_compilers_llvm_clang_1_0__GCC_WARN_UNKNOWN_PRAGMAS__DefaultValue": _com_apple_compilers_llvm_clang_1_0__GCC_WARN_UNKNOWN_PRAGMAS__DefaultValue,
    "com_apple_compilers_llvm_clang_1_0__GCC_WARN_UNUSED_FUNCTION__DefaultValue": _com_apple_compilers_llvm_clang_1_0__GCC_WARN_UNUSED_FUNCTION__DefaultValue,
    "com_apple_compilers_llvm_clang_1_0__GCC_WARN_UNUSED_LABEL__DefaultValue": _com_apple_compilers_llvm_clang_1_0__GCC_WARN_UNUSED_LABEL__DefaultValue,
    "com_apple_compilers_llvm_clang_1_0__GCC_WARN_UNUSED_PARAMETER__DefaultValue": _com_apple_compilers_llvm_clang_1_0__GCC_WARN_UNUSED_PARAMETER__DefaultValue,
    "com_apple_compilers_llvm_clang_1_0__GCC_WARN_UNUSED_VALUE__DefaultValue": _com_apple_compilers_llvm_clang_1_0__GCC_WARN_UNUSED_VALUE__DefaultValue,
    "com_apple_compilers_llvm_clang_1_0__GCC_WARN_UNUSED_VARIABLE__DefaultValue": _com_apple_compilers_llvm_clang_1_0__GCC_WARN_UNUSED_VARIABLE__DefaultValue,
    "com_apple_compilers_llvm_clang_1_0__HEADERMAP_FILE_FORMAT__DefaultValue": _com_apple_compilers_llvm_clang_1_0__HEADERMAP_FILE_FORMAT__DefaultValue,
    "com_apple_compilers_llvm_clang_1_0__LLVM_IMPLICIT_AGGRESSIVE_OPTIMIZATIONS__DefaultValue": _com_apple_compilers_llvm_clang_1_0__LLVM_IMPLICIT_AGGRESSIVE_OPTIMIZATIONS__DefaultValue,
    "com_apple_compilers_llvm_clang_1_0__LLVM_LTO__DefaultValue": _com_apple_compilers_llvm_clang_1_0__LLVM_LTO__DefaultValue,
    "com_apple_compilers_llvm_clang_1_0__LLVM_OPTIMIZATION_LEVEL_VAL_0__DefaultValue": _com_apple_compilers_llvm_clang_1_0__LLVM_OPTIMIZATION_LEVEL_VAL_0__DefaultValue,
    "com_apple_compilers_llvm_clang_1_0__LLVM_OPTIMIZATION_LEVEL_VAL_1__DefaultValue": _com_apple_compilers_llvm_clang_1_0__LLVM_OPTIMIZATION_LEVEL_VAL_1__DefaultValue,
    "com_apple_compilers_llvm_clang_1_0__LLVM_OPTIMIZATION_LEVEL_VAL_2__DefaultValue": _com_apple_compilers_llvm_clang_1_0__LLVM_OPTIMIZATION_LEVEL_VAL_2__DefaultValue,
    "com_apple_compilers_llvm_clang_1_0__LLVM_OPTIMIZATION_LEVEL_VAL_3__DefaultValue": _com_apple_compilers_llvm_clang_1_0__LLVM_OPTIMIZATION_LEVEL_VAL_3__DefaultValue,
    "com_apple_compilers_llvm_clang_1_0__LLVM_OPTIMIZATION_LEVEL_VAL_fast__DefaultValue": _com_apple_compilers_llvm_clang_1_0__LLVM_OPTIMIZATION_LEVEL_VAL_fast__DefaultValue,
    "com_apple_compilers_llvm_clang_1_0__LLVM_OPTIMIZATION_LEVEL_VAL_s__DefaultValue": _com_apple_compilers_llvm_clang_1_0__LLVM_OPTIMIZATION_LEVEL_VAL_s__DefaultValue,
    "com_apple_compilers_llvm_clang_1_0__LLVM_OPTIMIZATION_LEVEL_VAL_z__DefaultValue": _com_apple_compilers_llvm_clang_1_0__LLVM_OPTIMIZATION_LEVEL_VAL_z__DefaultValue,
    "com_apple_compilers_llvm_clang_1_0__USE_HEADERMAP__DefaultValue": _com_apple_compilers_llvm_clang_1_0__USE_HEADERMAP__DefaultValue,
    "com_apple_compilers_llvm_clang_1_0__USE_HEADER_SYMLINKS__DefaultValue": _com_apple_compilers_llvm_clang_1_0__USE_HEADER_SYMLINKS__DefaultValue,
    "com_apple_compilers_llvm_clang_1_0__WARNING_CFLAGS__DefaultValue": _com_apple_compilers_llvm_clang_1_0__WARNING_CFLAGS__DefaultValue,
    "com_apple_compilers_llvm_clang_1_0__diagnostic_message_length__DefaultValue": _com_apple_compilers_llvm_clang_1_0__diagnostic_message_length__DefaultValue,
    "com_apple_compilers_llvm_clang_1_0__print_note_include_stack__DefaultValue": _com_apple_compilers_llvm_clang_1_0__print_note_include_stack__DefaultValue,
    "com_apple_compilers_model_coredata__DEPLOYMENT_TARGET__DefaultValue": _com_apple_compilers_model_coredata__DEPLOYMENT_TARGET__DefaultValue,
    "com_apple_compilers_model_coredata__MOMC_MODULE__DefaultValue": _com_apple_compilers_model_coredata__MOMC_MODULE__DefaultValue,
    "com_apple_compilers_model_coredata__MOMC_NO_DELETE_RULE_WARNINGS__DefaultValue": _com_apple_compilers_model_coredata__MOMC_NO_DELETE_RULE_WARNINGS__DefaultValue,
    "com_apple_compilers_model_coredata__MOMC_NO_INVERSE_RELATIONSHIP_WARNINGS__DefaultValue": _com_apple_compilers_model_coredata__MOMC_NO_INVERSE_RELATIONSHIP_WARNINGS__DefaultValue,
    "com_apple_compilers_model_coredata__MOMC_NO_MAX_PROPERTY_COUNT_WARNINGS__DefaultValue": _com_apple_compilers_model_coredata__MOMC_NO_MAX_PROPERTY_COUNT_WARNINGS__DefaultValue,
    "com_apple_compilers_model_coredata__MOMC_NO_WARNINGS__DefaultValue": _com_apple_compilers_model_coredata__MOMC_NO_WARNINGS__DefaultValue,
    "com_apple_compilers_model_coredata__MOMC_OUTPUT_SUFFIX__DefaultValue": _com_apple_compilers_model_coredata__MOMC_OUTPUT_SUFFIX__DefaultValue,
    "com_apple_compilers_model_coredata__MOMC_OUTPUT_SUFFIX__xcdatamodel__DefaultValue": _com_apple_compilers_model_coredata__MOMC_OUTPUT_SUFFIX__xcdatamodel__DefaultValue,
    "com_apple_compilers_model_coredata__MOMC_OUTPUT_SUFFIX__xcdatamodeld__DefaultValue": _com_apple_compilers_model_coredata__MOMC_OUTPUT_SUFFIX__xcdatamodeld__DefaultValue,
    "com_apple_compilers_model_coredata__MOMC_SUPPRESS_INVERSE_TRANSIENT_ERROR__DefaultValue": _com_apple_compilers_model_coredata__MOMC_SUPPRESS_INVERSE_TRANSIENT_ERROR__DefaultValue,
    "com_apple_compilers_model_coredata__build_file_compiler_flags__DefaultValue": _com_apple_compilers_model_coredata__build_file_compiler_flags__DefaultValue,
    "com_apple_compilers_model_coredatamapping__DEPLOYMENT_TARGET__DefaultValue": _com_apple_compilers_model_coredatamapping__DEPLOYMENT_TARGET__DefaultValue,
    "com_apple_compilers_model_coredatamapping__MAPC_MODULE__DefaultValue": _com_apple_compilers_model_coredatamapping__MAPC_MODULE__DefaultValue,
    "com_apple_compilers_model_coredatamapping__MAPC_NO_WARNINGS__DefaultValue": _com_apple_compilers_model_coredatamapping__MAPC_NO_WARNINGS__DefaultValue,
    "com_apple_compilers_model_coredatamapping__build_file_compiler_flags__DefaultValue": _com_apple_compilers_model_coredatamapping__build_file_compiler_flags__DefaultValue,
    "com_apple_pbx_linkers_ld__ALL_OTHER_LDFLAGS__Condition": _com_apple_pbx_linkers_ld__ALL_OTHER_LDFLAGS__Condition,
    "com_apple_pbx_linkers_ld__ALL_OTHER_LDFLAGS__DefaultValue": _com_apple_pbx_linkers_ld__ALL_OTHER_LDFLAGS__DefaultValue,
    "com_apple_pbx_linkers_ld__BUNDLE_LOADER__DefaultValue": _com_apple_pbx_linkers_ld__BUNDLE_LOADER__DefaultValue,
    "com_apple_pbx_linkers_ld__CLANG_ARC_MIGRATE_PRECHECK__DefaultValue": _com_apple_pbx_linkers_ld__CLANG_ARC_MIGRATE_PRECHECK__DefaultValue,
    "com_apple_pbx_linkers_ld__DEAD_CODE_STRIPPING__Condition": _com_apple_pbx_linkers_ld__DEAD_CODE_STRIPPING__Condition,
    "com_apple_pbx_linkers_ld__DEAD_CODE_STRIPPING__DefaultValue": _com_apple_pbx_linkers_ld__DEAD_CODE_STRIPPING__DefaultValue,
    "com_apple_pbx_linkers_ld__EXPORTED_SYMBOLS_FILE__Condition": _com_apple_pbx_linkers_ld__EXPORTED_SYMBOLS_FILE__Condition,
    "com_apple_pbx_linkers_ld__GENERATE_PROFILING_CODE__Condition": _com_apple_pbx_linkers_ld__GENERATE_PROFILING_CODE__Condition,
    "com_apple_pbx_linkers_ld__KEEP_PRIVATE_EXTERNS__DefaultValue": _com_apple_pbx_linkers_ld__KEEP_PRIVATE_EXTERNS__DefaultValue,
    "com_apple_pbx_linkers_ld__LD_BITCODE_GENERATION_MODE__Condition": _com_apple_pbx_linkers_ld__LD_BITCODE_GENERATION_MODE__Condition,
    "com_apple_pbx_linkers_ld__LD_BITCODE_GENERATION_MODE__DefaultValue": _com_apple_pbx_linkers_ld__LD_BITCODE_GENERATION_MODE__DefaultValue,
    "com_apple_pbx_linkers_ld__LD_DEBUG_VARIANT__Condition": _com_apple_pbx_linkers_ld__LD_DEBUG_VARIANT__Condition,
    "com_apple_pbx_linkers_ld__LD_DEBUG_VARIANT__DefaultValue": _com_apple_pbx_linkers_ld__LD_DEBUG_VARIANT__DefaultValue,
    "com_apple_pbx_linkers_ld__LD_DEPENDENCY_INFO_FILE__DefaultValue": _com_apple_pbx_linkers_ld__LD_DEPENDENCY_INFO_FILE__DefaultValue,
    "com_apple_pbx_linkers_ld__LD_DETERMINISTIC_MODE__DefaultValue": _com_apple_pbx_linkers_ld__LD_DETERMINISTIC_MODE__DefaultValue,
    "com_apple_pbx_linkers_ld__LD_DONT_RUN_DEDUPLICATION__Condition": _com_apple_pbx_linkers_ld__LD_DONT_RUN_DEDUPLICATION__Condition,
    "com_apple_pbx_linkers_ld__LD_DONT_RUN_DEDUPLICATION__DefaultValue": _com_apple_pbx_linkers_ld__LD_DONT_RUN_DEDUPLICATION__DefaultValue,
    "com_apple_pbx_linkers_ld__LD_DYLIB_ALLOWABLE_CLIENTS__DefaultValue": _com_apple_pbx_linkers_ld__LD_DYLIB_ALLOWABLE_CLIENTS__DefaultValue,
    "com_apple_pbx_linkers_ld__LD_DYLIB_INSTALL_NAME__Condition": _com_apple_pbx_linkers_ld__LD_DYLIB_INSTALL_NAME__Condition,
    "com_apple_pbx_linkers_ld__LD_DYLIB_INSTALL_NAME__DefaultValue": _com_apple_pbx_linkers_ld__LD_DYLIB_INSTALL_NAME__DefaultValue,
    "com_apple_pbx_linkers_ld__LD_ENTRY_POINT__Condition": _com_apple_pbx_linkers_ld__LD_ENTRY_POINT__Condition,
    "com_apple_pbx_linkers_ld__LD_EXPORT_GLOBAL_SYMBOLS__DefaultValue": _com_apple_pbx_linkers_ld__LD_EXPORT_GLOBAL_SYMBOLS__DefaultValue,
    "com_apple_pbx_linkers_ld__LD_EXPORT_SYMBOLS__DefaultValue": _com_apple_pbx_linkers_ld__LD_EXPORT_SYMBOLS__DefaultValue,
    "com_apple_pbx_linkers_ld__LD_FINAL_OUTPUT_FILE__Condition": _com_apple_pbx_linkers_ld__LD_FINAL_OUTPUT_FILE__Condition,
    "com_apple_pbx_linkers_ld__LD_FINAL_OUTPUT_FILE__DefaultValue": _com_apple_pbx_linkers_ld__LD_FINAL_OUTPUT_FILE__DefaultValue,
    "com_apple_pbx_linkers_ld__LD_GENERATE_BITCODE_SYMBOL_MAP__Condition": _com_apple_pbx_linkers_ld__LD_GENERATE_BITCODE_SYMBOL_MAP__Condition,
    "com_apple_pbx_linkers_ld__LD_GENERATE_BITCODE_SYMBOL_MAP__DefaultValue": _com_apple_pbx_linkers_ld__LD_GENERATE_BITCODE_SYMBOL_MAP__DefaultValue,
    "com_apple_pbx_linkers_ld__LD_GENERATE_MAP_FILE__DefaultValue": _com_apple_pbx_linkers_ld__LD_GENERATE_MAP_FILE__DefaultValue,
    "com_apple_pbx_linkers_ld__LD_HIDE_BITCODE_SYMBOLS__Condition": _com_apple_pbx_linkers_ld__LD_HIDE_BITCODE_SYMBOLS__Condition,
    "com_apple_pbx_linkers_ld__LD_HIDE_BITCODE_SYMBOLS__DefaultValue": _com_apple_pbx_linkers_ld__LD_HIDE_BITCODE_SYMBOLS__DefaultValue,
    "com_apple_pbx_linkers_ld__LD_LTO_OBJECT_FILE__Condition": _com_apple_pbx_linkers_ld__LD_LTO_OBJECT_FILE__Condition,
    "com_apple_pbx_linkers_ld__LD_LTO_OBJECT_FILE__DefaultValue": _com_apple_pbx_linkers_ld__LD_LTO_OBJECT_FILE__DefaultValue,
    "com_apple_pbx_linkers_ld__LD_MAKE_MERGEABLE__DefaultValue": _com_apple_pbx_linkers_ld__LD_MAKE_MERGEABLE__DefaultValue,
    "com_apple_pbx_linkers_ld__LD_MAP_FILE_PATH__DefaultValue": _com_apple_pbx_linkers_ld__LD_MAP_FILE_PATH__DefaultValue,
    "com_apple_pbx_linkers_ld__LD_NO_PIE__DefaultValue": _com_apple_pbx_linkers_ld__LD_NO_PIE__DefaultValue,
    "com_apple_pbx_linkers_ld__LD_OBJC_ABI_VERSION__DefaultValue": _com_apple_pbx_linkers_ld__LD_OBJC_ABI_VERSION__DefaultValue,
    "com_apple_pbx_linkers_ld__LD_OPTIMIZATION_LEVEL__DefaultValue": _com_apple_pbx_linkers_ld__LD_OPTIMIZATION_LEVEL__DefaultValue,
    "com_apple_pbx_linkers_ld__LD_QUOTE_LINKER_ARGUMENTS_FOR_COMPILER_DRIVER__DefaultValue": _com_apple_pbx_linkers_ld__LD_QUOTE_LINKER_ARGUMENTS_FOR_COMPILER_DRIVER__DefaultValue,
    "com_apple_pbx_linkers_ld__LD_RUNPATH_SEARCH_PATHS__DefaultValue": _com_apple_pbx_linkers_ld__LD_RUNPATH_SEARCH_PATHS__DefaultValue,
    "com_apple_pbx_linkers_ld__LD_SUPPRESS_WARNINGS__DefaultValue": _com_apple_pbx_linkers_ld__LD_SUPPRESS_WARNINGS__DefaultValue,
    "com_apple_pbx_linkers_ld__LD_TARGET_TRIPLE_ARCHS__DefaultValue": _com_apple_pbx_linkers_ld__LD_TARGET_TRIPLE_ARCHS__DefaultValue,
    "com_apple_pbx_linkers_ld__LD_THREAD_SANITIZER__DefaultValue": _com_apple_pbx_linkers_ld__LD_THREAD_SANITIZER__DefaultValue,
    "com_apple_pbx_linkers_ld__LD_VERIFY_BITCODE__Condition": _com_apple_pbx_linkers_ld__LD_VERIFY_BITCODE__Condition,
    "com_apple_pbx_linkers_ld__LD_VERIFY_BITCODE__DefaultValue": _com_apple_pbx_linkers_ld__LD_VERIFY_BITCODE__DefaultValue,
    "com_apple_pbx_linkers_ld__LINKER_DISPLAYS_MANGLED_NAMES__DefaultValue": _com_apple_pbx_linkers_ld__LINKER_DISPLAYS_MANGLED_NAMES__DefaultValue,
    "com_apple_pbx_linkers_ld__LINK_WITH_STANDARD_LIBRARIES__DefaultValue": _com_apple_pbx_linkers_ld__LINK_WITH_STANDARD_LIBRARIES__DefaultValue,
    "com_apple_pbx_linkers_ld__ORDER_FILE__DefaultValue": _com_apple_pbx_linkers_ld__ORDER_FILE__DefaultValue,
    "com_apple_pbx_linkers_ld__OTHER_LDRFLAGS__Condition": _com_apple_pbx_linkers_ld__OTHER_LDRFLAGS__Condition,
    "com_apple_pbx_linkers_ld__OTHER_LDRFLAGS__DefaultValue": _com_apple_pbx_linkers_ld__OTHER_LDRFLAGS__DefaultValue,
    "com_apple_pbx_linkers_ld__PRESERVE_DEAD_CODE_INITS_AND_TERMS__DefaultValue": _com_apple_pbx_linkers_ld__PRESERVE_DEAD_CODE_INITS_AND_TERMS__DefaultValue,
    "com_apple_pbx_linkers_ld__UNEXPORTED_SYMBOLS_FILE__Condition": _com_apple_pbx_linkers_ld__UNEXPORTED_SYMBOLS_FILE__Condition,
    "com_apple_pbx_linkers_ld____INPUT_FILE_LIST_PATH____DefaultValue": _com_apple_pbx_linkers_ld____INPUT_FILE_LIST_PATH____DefaultValue,
    "com_apple_xcode_tools_ibtool_compiler__IBC_COMPILER_AUTO_ACTIVATE_CUSTOM_FONTS__DefaultValue": _com_apple_xcode_tools_ibtool_compiler__IBC_COMPILER_AUTO_ACTIVATE_CUSTOM_FONTS__DefaultValue,
    "com_apple_xcode_tools_ibtool_compiler__IBC_COMPILER_USE_NIBKEYEDARCHIVER_FOR_MACOS__DefaultValue": _com_apple_xcode_tools_ibtool_compiler__IBC_COMPILER_USE_NIBKEYEDARCHIVER_FOR_MACOS__DefaultValue,
    "com_apple_xcode_tools_ibtool_compiler__IBC_ERRORS__DefaultValue": _com_apple_xcode_tools_ibtool_compiler__IBC_ERRORS__DefaultValue,
    "com_apple_xcode_tools_ibtool_compiler__IBC_EXEC__DefaultValue": _com_apple_xcode_tools_ibtool_compiler__IBC_EXEC__DefaultValue,
    "com_apple_xcode_tools_ibtool_compiler__IBC_FLATTEN_NIBS__DefaultValue": _com_apple_xcode_tools_ibtool_compiler__IBC_FLATTEN_NIBS__DefaultValue,
    "com_apple_xcode_tools_ibtool_compiler__IBC_MODULE__DefaultValue": _com_apple_xcode_tools_ibtool_compiler__IBC_MODULE__DefaultValue,
    "com_apple_xcode_tools_ibtool_compiler__IBC_NOTICES__DefaultValue": _com_apple_xcode_tools_ibtool_compiler__IBC_NOTICES__DefaultValue,
    "com_apple_xcode_tools_ibtool_compiler__IBC_OTHER_FLAGS__DefaultValue": _com_apple_xcode_tools_ibtool_compiler__IBC_OTHER_FLAGS__DefaultValue,
    "com_apple_xcode_tools_ibtool_compiler__IBC_PLUGINS__DefaultValue": _com_apple_xcode_tools_ibtool_compiler__IBC_PLUGINS__DefaultValue,
    "com_apple_xcode_tools_ibtool_compiler__IBC_PLUGIN_SEARCH_PATHS__DefaultValue": _com_apple_xcode_tools_ibtool_compiler__IBC_PLUGIN_SEARCH_PATHS__DefaultValue,
    "com_apple_xcode_tools_ibtool_compiler__IBC_REGIONS_AND_STRINGS_FILES__DefaultValue": _com_apple_xcode_tools_ibtool_compiler__IBC_REGIONS_AND_STRINGS_FILES__DefaultValue,
    "com_apple_xcode_tools_ibtool_compiler__IBC_WARNINGS__DefaultValue": _com_apple_xcode_tools_ibtool_compiler__IBC_WARNINGS__DefaultValue,
    "com_apple_xcode_tools_ibtool_compiler__XIB_COMPILER_INFOPLIST_CONTENT_FILE__DefaultValue": _com_apple_xcode_tools_ibtool_compiler__XIB_COMPILER_INFOPLIST_CONTENT_FILE__DefaultValue,
    "com_apple_xcode_tools_ibtool_compiler__build_file_compiler_flags__DefaultValue": _com_apple_xcode_tools_ibtool_compiler__build_file_compiler_flags__DefaultValue,
    "com_apple_xcode_tools_swift_compiler__CLANG_COVERAGE_MAPPING_LINKER_ARGS__DefaultValue": _com_apple_xcode_tools_swift_compiler__CLANG_COVERAGE_MAPPING_LINKER_ARGS__DefaultValue,
    "com_apple_xcode_tools_swift_compiler__CLANG_COVERAGE_MAPPING__Condition": _com_apple_xcode_tools_swift_compiler__CLANG_COVERAGE_MAPPING__Condition,
    "com_apple_xcode_tools_swift_compiler__CLANG_COVERAGE_MAPPING__DefaultValue": _com_apple_xcode_tools_swift_compiler__CLANG_COVERAGE_MAPPING__DefaultValue,
    "com_apple_xcode_tools_swift_compiler__SWIFT_ACTIVE_COMPILATION_CONDITIONS__DefaultValue": _com_apple_xcode_tools_swift_compiler__SWIFT_ACTIVE_COMPILATION_CONDITIONS__DefaultValue,
    "com_apple_xcode_tools_swift_compiler__SWIFT_ADDRESS_SANITIZER_ALLOW_ERROR_RECOVERY__Condition": _com_apple_xcode_tools_swift_compiler__SWIFT_ADDRESS_SANITIZER_ALLOW_ERROR_RECOVERY__Condition,
    "com_apple_xcode_tools_swift_compiler__SWIFT_ADDRESS_SANITIZER_ALLOW_ERROR_RECOVERY__DefaultValue": _com_apple_xcode_tools_swift_compiler__SWIFT_ADDRESS_SANITIZER_ALLOW_ERROR_RECOVERY__DefaultValue,
    "com_apple_xcode_tools_swift_compiler__SWIFT_ADDRESS_SANITIZER__DefaultValue": _com_apple_xcode_tools_swift_compiler__SWIFT_ADDRESS_SANITIZER__DefaultValue,
    "com_apple_xcode_tools_swift_compiler__SWIFT_BITCODE_GENERATION_MODE__Condition": _com_apple_xcode_tools_swift_compiler__SWIFT_BITCODE_GENERATION_MODE__Condition,
    "com_apple_xcode_tools_swift_compiler__SWIFT_BITCODE_GENERATION_MODE__DefaultValue": _com_apple_xcode_tools_swift_compiler__SWIFT_BITCODE_GENERATION_MODE__DefaultValue,
    "com_apple_xcode_tools_swift_compiler__SWIFT_CLANG_CXX_LANGUAGE_STANDARD__DefaultValue": _com_apple_xcode_tools_swift_compiler__SWIFT_CLANG_CXX_LANGUAGE_STANDARD__DefaultValue,
    "com_apple_xcode_tools_swift_compiler__SWIFT_COMPILATION_MODE__Condition": _com_apple_xcode_tools_swift_compiler__SWIFT_COMPILATION_MODE__Condition,
    "com_apple_xcode_tools_swift_compiler__SWIFT_COMPILATION_MODE__DefaultValue": _com_apple_xcode_tools_swift_compiler__SWIFT_COMPILATION_MODE__DefaultValue,
    "com_apple_xcode_tools_swift_compiler__SWIFT_CROSS_MODULE_OPTIMIZATION__DefaultValue": _com_apple_xcode_tools_swift_compiler__SWIFT_CROSS_MODULE_OPTIMIZATION__DefaultValue,
    "com_apple_xcode_tools_swift_compiler__SWIFT_DEPLOYMENT_TARGET__DefaultValue": _com_apple_xcode_tools_swift_compiler__SWIFT_DEPLOYMENT_TARGET__DefaultValue,
    "com_apple_xcode_tools_swift_compiler__SWIFT_DISABLE_SAFETY_CHECKS__DefaultValue": _com_apple_xcode_tools_swift_compiler__SWIFT_DISABLE_SAFETY_CHECKS__DefaultValue,
    "com_apple_xcode_tools_swift_compiler__SWIFT_EMIT_CONST_VALUE_PROTOCOLS__DefaultValue": _com_apple_xcode_tools_swift_compiler__SWIFT_EMIT_CONST_VALUE_PROTOCOLS__DefaultValue,
    "com_apple_xcode_tools_swift_compiler__SWIFT_EMIT_MODULE_INTERFACE__DefaultValue": _com_apple_xcode_tools_swift_compiler__SWIFT_EMIT_MODULE_INTERFACE__DefaultValue,
    "com_apple_xcode_tools_swift_compiler__SWIFT_ENABLE_APP_EXTENSION__DefaultValue": _com_apple_xcode_tools_swift_compiler__SWIFT_ENABLE_APP_EXTENSION__DefaultValue,
    "com_apple_xcode_tools_swift_compiler__SWIFT_ENABLE_BARE_SLASH_REGEX__DefaultValue": _com_apple_xcode_tools_swift_compiler__SWIFT_ENABLE_BARE_SLASH_REGEX__DefaultValue,
    "com_apple_xcode_tools_swift_compiler__SWIFT_ENABLE_BATCH_MODE__DefaultValue": _com_apple_xcode_tools_swift_compiler__SWIFT_ENABLE_BATCH_MODE__DefaultValue,
    "com_apple_xcode_tools_swift_compiler__SWIFT_ENABLE_EMIT_CONST_VALUES__DefaultValue": _com_apple_xcode_tools_swift_compiler__SWIFT_ENABLE_EMIT_CONST_VALUES__DefaultValue,
    "com_apple_xcode_tools_swift_compiler__SWIFT_ENABLE_INCREMENTAL_COMPILATION__DefaultValue": _com_apple_xcode_tools_swift_compiler__SWIFT_ENABLE_INCREMENTAL_COMPILATION__DefaultValue,
    "com_apple_xcode_tools_swift_compiler__SWIFT_ENABLE_LIBRARY_EVOLUTION__DefaultValue": _com_apple_xcode_tools_swift_compiler__SWIFT_ENABLE_LIBRARY_EVOLUTION__DefaultValue,
    "com_apple_xcode_tools_swift_compiler__SWIFT_ENABLE_OPAQUE_TYPE_ERASURE__Condition": _com_apple_xcode_tools_swift_compiler__SWIFT_ENABLE_OPAQUE_TYPE_ERASURE__Condition,
    "com_apple_xcode_tools_swift_compiler__SWIFT_ENABLE_OPAQUE_TYPE_ERASURE__DefaultValue": _com_apple_xcode_tools_swift_compiler__SWIFT_ENABLE_OPAQUE_TYPE_ERASURE__DefaultValue,
    "com_apple_xcode_tools_swift_compiler__SWIFT_ENABLE_TESTABILITY__DefaultValue": _com_apple_xcode_tools_swift_compiler__SWIFT_ENABLE_TESTABILITY__DefaultValue,
    "com_apple_xcode_tools_swift_compiler__SWIFT_ENFORCE_EXCLUSIVE_ACCESS__DefaultValue": _com_apple_xcode_tools_swift_compiler__SWIFT_ENFORCE_EXCLUSIVE_ACCESS__DefaultValue,
    "com_apple_xcode_tools_swift_compiler__SWIFT_EXEC__DefaultValue": _com_apple_xcode_tools_swift_compiler__SWIFT_EXEC__DefaultValue,
    "com_apple_xcode_tools_swift_compiler__SWIFT_INDEX_STORE_ENABLE__Condition": _com_apple_xcode_tools_swift_compiler__SWIFT_INDEX_STORE_ENABLE__Condition,
    "com_apple_xcode_tools_swift_compiler__SWIFT_INDEX_STORE_ENABLE__DefaultValue": _com_apple_xcode_tools_swift_compiler__SWIFT_INDEX_STORE_ENABLE__DefaultValue,
    "com_apple_xcode_tools_swift_compiler__SWIFT_INDEX_STORE_PATH__DefaultValue": _com_apple_xcode_tools_swift_compiler__SWIFT_INDEX_STORE_PATH__DefaultValue,
    "com_apple_xcode_tools_swift_compiler__SWIFT_INSTALL_MODULE__DefaultValue": _com_apple_xcode_tools_swift_compiler__SWIFT_INSTALL_MODULE__DefaultValue,
    "com_apple_xcode_tools_swift_compiler__SWIFT_INSTALL_OBJC_HEADER__DefaultValue": _com_apple_xcode_tools_swift_compiler__SWIFT_INSTALL_OBJC_HEADER__DefaultValue,
    "com_apple_xcode_tools_swift_compiler__SWIFT_LIBRARIES_ONLY__DefaultValue": _com_apple_xcode_tools_swift_compiler__SWIFT_LIBRARIES_ONLY__DefaultValue,
    "com_apple_xcode_tools_swift_compiler__SWIFT_LIBRARY_PATH__DefaultValue": _com_apple_xcode_tools_swift_compiler__SWIFT_LIBRARY_PATH__DefaultValue,
    "com_apple_xcode_tools_swift_compiler__SWIFT_LINK_OBJC_RUNTIME__DefaultValue": _com_apple_xcode_tools_swift_compiler__SWIFT_LINK_OBJC_RUNTIME__DefaultValue,
    "com_apple_xcode_tools_swift_compiler__SWIFT_MODULE_ALIASES__DefaultValue": _com_apple_xcode_tools_swift_compiler__SWIFT_MODULE_ALIASES__DefaultValue,
    "com_apple_xcode_tools_swift_compiler__SWIFT_MODULE_NAME__DefaultValue": _com_apple_xcode_tools_swift_compiler__SWIFT_MODULE_NAME__DefaultValue,
    "com_apple_xcode_tools_swift_compiler__SWIFT_OBJC_BRIDGING_HEADER__DefaultValue": _com_apple_xcode_tools_swift_compiler__SWIFT_OBJC_BRIDGING_HEADER__DefaultValue,
    "com_apple_xcode_tools_swift_compiler__SWIFT_OBJC_INTERFACE_HEADER_NAME__DefaultValue": _com_apple_xcode_tools_swift_compiler__SWIFT_OBJC_INTERFACE_HEADER_NAME__DefaultValue,
    "com_apple_xcode_tools_swift_compiler__SWIFT_OBJC_INTEROP_MODE__DefaultValue": _com_apple_xcode_tools_swift_compiler__SWIFT_OBJC_INTEROP_MODE__DefaultValue,
    "com_apple_xcode_tools_swift_compiler__SWIFT_OPTIMIZATION_LEVEL__DefaultValue": _com_apple_xcode_tools_swift_compiler__SWIFT_OPTIMIZATION_LEVEL__DefaultValue,
    "com_apple_xcode_tools_swift_compiler__SWIFT_PACKAGE_NAME__Condition": _com_apple_xcode_tools_swift_compiler__SWIFT_PACKAGE_NAME__Condition,
    "com_apple_xcode_tools_swift_compiler__SWIFT_PRECOMPILE_BRIDGING_HEADER__DefaultValue": _com_apple_xcode_tools_swift_compiler__SWIFT_PRECOMPILE_BRIDGING_HEADER__DefaultValue,
    "com_apple_xcode_tools_swift_compiler__SWIFT_REFLECTION_METADATA_LEVEL__DefaultValue": _com_apple_xcode_tools_swift_compiler__SWIFT_REFLECTION_METADATA_LEVEL__DefaultValue,
    "com_apple_xcode_tools_swift_compiler__SWIFT_RESPONSE_FILE_PATH__DefaultValue": _com_apple_xcode_tools_swift_compiler__SWIFT_RESPONSE_FILE_PATH__DefaultValue,
    "com_apple_xcode_tools_swift_compiler__SWIFT_SERIALIZE_DEBUGGING_OPTIONS__DefaultValue": _com_apple_xcode_tools_swift_compiler__SWIFT_SERIALIZE_DEBUGGING_OPTIONS__DefaultValue,
    "com_apple_xcode_tools_swift_compiler__SWIFT_STDLIB__DefaultValue": _com_apple_xcode_tools_swift_compiler__SWIFT_STDLIB__DefaultValue,
    "com_apple_xcode_tools_swift_compiler__SWIFT_STRICT_CONCURRENCY__DefaultValue": _com_apple_xcode_tools_swift_compiler__SWIFT_STRICT_CONCURRENCY__DefaultValue,
    "com_apple_xcode_tools_swift_compiler__SWIFT_SUPPRESS_WARNINGS__DefaultValue": _com_apple_xcode_tools_swift_compiler__SWIFT_SUPPRESS_WARNINGS__DefaultValue,
    "com_apple_xcode_tools_swift_compiler__SWIFT_TARGET_TRIPLE__DefaultValue": _com_apple_xcode_tools_swift_compiler__SWIFT_TARGET_TRIPLE__DefaultValue,
    "com_apple_xcode_tools_swift_compiler__SWIFT_THREAD_SANITIZER__DefaultValue": _com_apple_xcode_tools_swift_compiler__SWIFT_THREAD_SANITIZER__DefaultValue,
    "com_apple_xcode_tools_swift_compiler__SWIFT_TREAT_WARNINGS_AS_ERRORS__DefaultValue": _com_apple_xcode_tools_swift_compiler__SWIFT_TREAT_WARNINGS_AS_ERRORS__DefaultValue,
    "com_apple_xcode_tools_swift_compiler__SWIFT_USE_PARALLEL_WHOLE_MODULE_OPTIMIZATION__DefaultValue": _com_apple_xcode_tools_swift_compiler__SWIFT_USE_PARALLEL_WHOLE_MODULE_OPTIMIZATION__DefaultValue,
    "com_apple_xcode_tools_swift_compiler__SWIFT_USE_PARALLEL_WMO_TARGETS__DefaultValue": _com_apple_xcode_tools_swift_compiler__SWIFT_USE_PARALLEL_WMO_TARGETS__DefaultValue,
    "com_apple_xcode_tools_swift_compiler__SWIFT_VALIDATE_CLANG_MODULES_ONCE_PER_BUILD_SESSION__DefaultValue": _com_apple_xcode_tools_swift_compiler__SWIFT_VALIDATE_CLANG_MODULES_ONCE_PER_BUILD_SESSION__DefaultValue,
    "com_apple_xcode_tools_swift_compiler__SWIFT_VERSION__DefaultValue": _com_apple_xcode_tools_swift_compiler__SWIFT_VERSION__DefaultValue,
    "com_apple_xcode_tools_swift_compiler__SWIFT_WHOLE_MODULE_OPTIMIZATION__DefaultValue": _com_apple_xcode_tools_swift_compiler__SWIFT_WHOLE_MODULE_OPTIMIZATION__DefaultValue,
    "com_apple_xcode_tools_swift_compiler____SWIFT_ENFORCE_EXCLUSIVE_ACCESS_DEBUG_ENFORCEMENT_DEBUG__Condition": _com_apple_xcode_tools_swift_compiler____SWIFT_ENFORCE_EXCLUSIVE_ACCESS_DEBUG_ENFORCEMENT_DEBUG__Condition,
    "com_apple_xcode_tools_swift_compiler____SWIFT_ENFORCE_EXCLUSIVE_ACCESS_DEBUG_ENFORCEMENT_DEBUG__DefaultValue": _com_apple_xcode_tools_swift_compiler____SWIFT_ENFORCE_EXCLUSIVE_ACCESS_DEBUG_ENFORCEMENT_DEBUG__DefaultValue,
    "com_apple_xcode_tools_swift_compiler____SWIFT_ENFORCE_EXCLUSIVE_ACCESS_DEBUG_ENFORCEMENT_RELEASE__Condition": _com_apple_xcode_tools_swift_compiler____SWIFT_ENFORCE_EXCLUSIVE_ACCESS_DEBUG_ENFORCEMENT_RELEASE__Condition,
    "com_apple_xcode_tools_swift_compiler____SWIFT_ENFORCE_EXCLUSIVE_ACCESS_DEBUG_ENFORCEMENT_RELEASE__DefaultValue": _com_apple_xcode_tools_swift_compiler____SWIFT_ENFORCE_EXCLUSIVE_ACCESS_DEBUG_ENFORCEMENT_RELEASE__DefaultValue,
}
