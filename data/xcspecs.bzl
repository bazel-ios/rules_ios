"""
############################################################################
#                   THIS IS GENERATED CODE                                 #
# Extracted from Xcode 15.2                                     #
# To update, in rules_ios run `bazel run data_generators:extract_xcspecs`  #
############################################################################
"""

SETTINGS = {
    "com.apple.compilers.llvm.clang.1_0": {
        "BuiltinJambaseRuleName": "ProcessC",
        "Class": "XCCompilerSpecificationClang",
        "CommandOutputParser": "XCSimpleBufferedCommandOutputParser",
        "DashIFlagAcceptsHeadermaps": "Yes",
        "Description": "Apple Clang compiler",
        "ExecDescription": "Compile $(InputFileName)",
        "ExecDescriptionForPrecompile": "Precompile $(InputFileName)",
        "ExecPath": "clang",
        "Identifier": "com.apple.compilers.llvm.clang.1_0",
        "InputFileTypes": [
            "sourcecode.c.c",
            "sourcecode.c.objc",
            "sourcecode.cpp.cpp",
            "sourcecode.cpp.objcpp",
            "sourcecode.asm",
        ],
        "IsAbstract": "NO",
        "MessageCategoryInfoOptions": ["--print-diagnostic-categories"],
        "Name": "Apple Clang",
        "OptionConditionFlavors": ["arch", "sdk"],
        "Options": {
            "CLANG_TARGET_TRIPLE_ARCHS": {
                "CommandLineArgs": [
                    "-target",
                    "$(value)-$(LLVM_TARGET_TRIPLE_VENDOR)-$(LLVM_TARGET_TRIPLE_OS_VERSION)$(LLVM_TARGET_TRIPLE_SUFFIX)",
                ],
                "DefaultValue": "com_apple_compilers_llvm_clang_1_0__CLANG_TARGET_TRIPLE_ARCHS__DefaultValue",
                "Type": "StringList",
            },
            "CLANG_TARGET_TRIPLE_VARIANTS": {
                "CommandLineFlag": "-target-variant",
                "ConditionFlavors": ["arch"],
                "Type": "StringList",
            },
            "CLANG_TOOLCHAIN_FLAGS": {"CommandLineArgs": ["$(value)"], "Type": "StringList"},
            "diagnostic_message_length": {
                "CommandLinePrefixFlag": "-fmessage-length=",
                "DefaultValue": "com_apple_compilers_llvm_clang_1_0__diagnostic_message_length__DefaultValue",
                "Type": "String",
            },
            "print_note_include_stack": {
                "CommandLineArgs": {
                    "NO": [],
                    "YES": ["-fdiagnostics-show-note-include-stack"],
                },
                "DefaultValue": "com_apple_compilers_llvm_clang_1_0__print_note_include_stack__DefaultValue",
                "Type": "Boolean",
            },
            "CLANG_MACRO_BACKTRACE_LIMIT": {
                "CommandLinePrefixFlag": "-fmacro-backtrace-limit=",
                "DefaultValue": "com_apple_compilers_llvm_clang_1_0__CLANG_MACRO_BACKTRACE_LIMIT__DefaultValue",
                "Type": "String",
            },
            "CLANG_RETAIN_COMMENTS_FROM_SYSTEM_HEADERS": {
                "CommandLineArgs": {
                    "NO": [],
                    "YES": ["-fretain-comments-from-system-headers"],
                },
                "DefaultValue": "com_apple_compilers_llvm_clang_1_0__CLANG_RETAIN_COMMENTS_FROM_SYSTEM_HEADERS__DefaultValue",
                "Type": "Boolean",
            },
            "CLANG_COLOR_DIAGNOSTICS": {
                "CommandLineArgs": {
                    "NO": ["-fno-color-diagnostics"],
                    "YES": ["-fcolor-diagnostics"],
                },
                "DefaultValue": "com_apple_compilers_llvm_clang_1_0__CLANG_COLOR_DIAGNOSTICS__DefaultValue",
                "Type": "Boolean",
            },
            "GCC_INPUT_FILETYPE": {
                "Category": "Language",
                "DefaultValue": "com_apple_compilers_llvm_clang_1_0__GCC_INPUT_FILETYPE__DefaultValue",
                "Type": "Enumeration",
                "Values": [
                    "automatic",
                    "sourcecode.c.c",
                    "sourcecode.c.objc",
                    "sourcecode.cpp.cpp",
                    "sourcecode.cpp.objcpp",
                ],
            },
            "GCC_OPERATION": {
                "DefaultValue": "com_apple_compilers_llvm_clang_1_0__GCC_OPERATION__DefaultValue",
                "Type": "Enumeration",
                "Values": [
                    "compile",
                    "generate-preprocessed",
                    "generate-assembler",
                    "precompile",
                    "separate-symbols",
                ],
            },
            "GCC_USE_STANDARD_INCLUDE_SEARCHING": {
                "Category": "Language",
                "CommandLineArgs": {"NO": ["-nostdinc"], "YES": []},
                "DefaultValue": "com_apple_compilers_llvm_clang_1_0__GCC_USE_STANDARD_INCLUDE_SEARCHING__DefaultValue",
                "Type": "Boolean",
            },
            "GCC_C_LANGUAGE_STANDARD": {
                "Category": "Language",
                "CommandLineArgs": {
                    "<<otherwise>>": ["-std=$(value)"],
                    "ansi": ["-ansi"],
                    "compiler-default": [],
                },
                "DefaultValue": "com_apple_compilers_llvm_clang_1_0__GCC_C_LANGUAGE_STANDARD__DefaultValue",
                "FileTypes": ["sourcecode.c.c", "sourcecode.c.objc"],
                "Type": "Enumeration",
                "Values": [
                    "ansi",
                    "c89",
                    "gnu89",
                    "c99",
                    "gnu99",
                    "c11",
                    "gnu11",
                    "c17",
                    "gnu17",
                    "compiler-default",
                ],
            },
            "CLANG_CXX_LANGUAGE_STANDARD": {
                "Category": "LanguageCXX",
                "CommandLineArgs": {
                    "<<otherwise>>": ["-std=$(value)"],
                    "c++0x": ["-std=c++11"],
                    "c++23": ["-std=c++2b"],
                    "compiler-default": [],
                    "gnu++0x": ["-std=gnu++11"],
                    "gnu++23": ["-std=gnu++2b"],
                },
                "DefaultValue": "com_apple_compilers_llvm_clang_1_0__CLANG_CXX_LANGUAGE_STANDARD__DefaultValue",
                "FileTypes": ["sourcecode.cpp.cpp", "sourcecode.cpp.objcpp"],
                "Type": "Enumeration",
                "Values": [
                    "c++98",
                    "gnu++98",
                    "c++0x",
                    "gnu++0x",
                    "c++14",
                    "gnu++14",
                    "c++17",
                    "gnu++17",
                    "c++20",
                    "gnu++20",
                    "c++23",
                    "gnu++23",
                    "compiler-default",
                ],
            },
            "CLANG_CXX_LIBRARY": {
                "AdditionalLinkerArgs": {
                    "<<otherwise>>": ["-stdlib=$(value)"],
                    "compiler-default": [],
                    "libstdc++": [],
                },
                "AppearsAfter": "CLANG_CXX_LANGUAGE_STANDARD",
                "CommandLineArgs": {
                    "<<otherwise>>": ["-stdlib=$(value)"],
                    "compiler-default": [],
                    "libstdc++": [],
                },
                "DefaultValue": "com_apple_compilers_llvm_clang_1_0__CLANG_CXX_LIBRARY__DefaultValue",
                "FileTypes": ["sourcecode.cpp.cpp", "sourcecode.cpp.objcpp"],
                "Type": "Enumeration",
                "Values": ["libc++", "compiler-default"],
            },
            "CLANG_ENABLE_OBJC_ARC": {
                "AdditionalLinkerArgs": {"NO": [], "YES": ["-fobjc-arc"]},
                "Category": "LanguageObjC",
                "CommandLineArgs": {"NO": [], "YES": ["-fobjc-arc"]},
                "DefaultValue": "com_apple_compilers_llvm_clang_1_0__CLANG_ENABLE_OBJC_ARC__DefaultValue",
                "FileTypes": ["sourcecode.c.objc", "sourcecode.cpp.objcpp"],
                "Type": "Boolean",
            },
            "CLANG_ENABLE_OBJC_WEAK": {
                "Category": "LanguageObjC",
                "CommandLineArgs": {"NO": [], "YES": ["-fobjc-weak"]},
                "DefaultValue": "com_apple_compilers_llvm_clang_1_0__CLANG_ENABLE_OBJC_WEAK__DefaultValue",
                "FileTypes": ["sourcecode.c.objc", "sourcecode.cpp.objcpp"],
                "Type": "Boolean",
            },
            "CLANG_LINK_OBJC_RUNTIME": {
                "AdditionalLinkerArgs": {"NO": [], "YES": ["-fobjc-link-runtime"]},
                "Category": "LanguageObjC",
                "CommandLineArgs": {"NO": [], "YES": []},
                "DefaultValue": "com_apple_compilers_llvm_clang_1_0__CLANG_LINK_OBJC_RUNTIME__DefaultValue",
                "FileTypes": ["sourcecode.c.objc", "sourcecode.cpp.objcpp"],
                "Type": "Boolean",
            },
            "CLANG_ENABLE_MODULES": {
                "Category": "LanguageModules",
                "CommandLineArgs": {"NO": [], "YES": ["-fmodules"]},
                "DefaultValue": "com_apple_compilers_llvm_clang_1_0__CLANG_ENABLE_MODULES__DefaultValue",
                "Type": "Boolean",
            },
            "CLANG_ENABLE_MODULE_DEBUGGING": {
                "Category": "LanguageModules",
                "DefaultValue": "com_apple_compilers_llvm_clang_1_0__CLANG_ENABLE_MODULE_DEBUGGING__DefaultValue",
                "Description": "When this setting is enabled, `clang` will use " +
                               "the shared debug info available in `clang` " +
                               "modules and precompiled headers. This results " +
                               "in smaller build artifacts, faster compile " +
                               "times, and more complete debug info. This " +
                               "setting should only be disabled when building " +
                               "static libraries with debug info for " +
                               "distribution.",
                "DisplayName": "Enable Clang Module Debugging",
                "Type": "Boolean",
            },
            "CLANG_DEBUG_MODULES": {
                "CommandLineArgs": {"NO": [], "YES": ["-gmodules"]},
                "Condition": "com_apple_compilers_llvm_clang_1_0__CLANG_DEBUG_MODULES__Condition",
                "DefaultValue": "com_apple_compilers_llvm_clang_1_0__CLANG_DEBUG_MODULES__DefaultValue",
                "SupportedVersionRanges": ["800.0.0"],
                "Type": "Boolean",
            },
            "CLANG_MODULE_CACHE_PATH": {
                "CommandLineArgs": {
                    "": [],
                    "<<otherwise>>": ["-fmodules-cache-path=$(CLANG_MODULE_CACHE_PATH)"],
                },
                "Condition": "com_apple_compilers_llvm_clang_1_0__CLANG_MODULE_CACHE_PATH__Condition",
                "DefaultValue": "com_apple_compilers_llvm_clang_1_0__CLANG_MODULE_CACHE_PATH__DefaultValue",
                "Type": "String",
            },
            "CLANG_MODULE_LSV": {
                "CommandLineArgs": {
                    "NO": [],
                    "YES": [
                        "-Xclang",
                        "-fmodules-local-submodule-visibility",
                    ],
                },
                "Condition": "com_apple_compilers_llvm_clang_1_0__CLANG_MODULE_LSV__Condition",
                "DefaultValue": "com_apple_compilers_llvm_clang_1_0__CLANG_MODULE_LSV__DefaultValue",
                "Type": "Boolean",
            },
            "CLANG_MODULES_AUTOLINK": {
                "Category": "LanguageModules",
                "CommandLineArgs": {"NO": ["-fno-autolink"], "YES": []},
                "Condition": "com_apple_compilers_llvm_clang_1_0__CLANG_MODULES_AUTOLINK__Condition",
                "DefaultValue": "com_apple_compilers_llvm_clang_1_0__CLANG_MODULES_AUTOLINK__DefaultValue",
                "Type": "Boolean",
            },
            "CLANG_MODULES_DISABLE_PRIVATE_WARNING": {
                "Category": "LanguageModules",
                "CommandLineArgs": {
                    "NO": [],
                    "YES": ["-Wno-private-module"],
                },
                "Condition": "com_apple_compilers_llvm_clang_1_0__CLANG_MODULES_DISABLE_PRIVATE_WARNING__Condition",
                "DefaultValue": "com_apple_compilers_llvm_clang_1_0__CLANG_MODULES_DISABLE_PRIVATE_WARNING__DefaultValue",
                "Type": "Boolean",
            },
            "CLANG_MODULES_PRUNE_INTERVAL": {
                "CommandLineArgs": {
                    "": [],
                    "<<otherwise>>": ["-fmodules-prune-interval=$(value)"],
                },
                "Condition": "com_apple_compilers_llvm_clang_1_0__CLANG_MODULES_PRUNE_INTERVAL__Condition",
                "DefaultValue": "com_apple_compilers_llvm_clang_1_0__CLANG_MODULES_PRUNE_INTERVAL__DefaultValue",
                "Type": "String",
            },
            "CLANG_MODULES_PRUNE_AFTER": {
                "CommandLineArgs": {
                    "": [],
                    "<<otherwise>>": ["-fmodules-prune-after=$(value)"],
                },
                "Condition": "com_apple_compilers_llvm_clang_1_0__CLANG_MODULES_PRUNE_AFTER__Condition",
                "DefaultValue": "com_apple_compilers_llvm_clang_1_0__CLANG_MODULES_PRUNE_AFTER__DefaultValue",
                "Type": "String",
            },
            "CLANG_MODULES_IGNORE_MACROS": {
                "CommandLineArgs": ["-fmodules-ignore-macro=$(value)"],
                "Condition": "com_apple_compilers_llvm_clang_1_0__CLANG_MODULES_IGNORE_MACROS__Condition",
                "DefaultValue": "com_apple_compilers_llvm_clang_1_0__CLANG_MODULES_IGNORE_MACROS__DefaultValue",
                "Type": "StringList",
            },
            "CLANG_MODULES_VALIDATE_SYSTEM_HEADERS": {
                "CommandLineArgs": {
                    "NO": [],
                    "YES": ["-fmodules-validate-system-headers"],
                },
                "Condition": "com_apple_compilers_llvm_clang_1_0__CLANG_MODULES_VALIDATE_SYSTEM_HEADERS__Condition",
                "DefaultValue": "com_apple_compilers_llvm_clang_1_0__CLANG_MODULES_VALIDATE_SYSTEM_HEADERS__DefaultValue",
                "Type": "Boolean",
            },
            "CLANG_MODULES_BUILD_SESSION_FILE": {
                "CommandLineArgs": {
                    "": [],
                    "<<otherwise>>": [
                        "-fbuild-session-file=$(value)",
                        "-fmodules-validate-once-per-build-session",
                    ],
                },
                "Condition": "com_apple_compilers_llvm_clang_1_0__CLANG_MODULES_BUILD_SESSION_FILE__Condition",
                "DefaultValue": "com_apple_compilers_llvm_clang_1_0__CLANG_MODULES_BUILD_SESSION_FILE__DefaultValue",
                "SupportedVersionRanges": ["602.0.0"],
                "Type": "String",
            },
            "CLANG_ALLOW_NON_MODULAR_INCLUDES_IN_FRAMEWORK_MODULES": {
                "Category": "LanguageModules",
                "CommandLineArgs": {
                    "NO": [
                        "-Wnon-modular-include-in-framework-module",
                        "-Werror=non-modular-include-in-framework-module",
                    ],
                    "YES": [],
                },
                "Condition": "com_apple_compilers_llvm_clang_1_0__CLANG_ALLOW_NON_MODULAR_INCLUDES_IN_FRAMEWORK_MODULES__Condition",
                "DefaultValue": "com_apple_compilers_llvm_clang_1_0__CLANG_ALLOW_NON_MODULAR_INCLUDES_IN_FRAMEWORK_MODULES__DefaultValue",
                "Description": "Enabling this setting " +
                               "allows non-modular " +
                               "includes to be used " +
                               "from within framework " +
                               "modules. This is " +
                               "inherently unsafe, as " +
                               "such headers might " +
                               "cause duplicate " +
                               "definitions when used " +
                               "by any client that " +
                               "imports both the " +
                               "framework and the " +
                               "non-modular includes.",
                "DisplayName": "Allow Non-modular " +
                               "Includes In Framework " +
                               "Modules",
                "Type": "Boolean",
            },
            "CLANG_ENABLE_MODULE_IMPLEMENTATION_OF": {
                "CommandLineArgs": {
                    "NO": [],
                    "YES": ["-fmodule-name=$(PRODUCT_MODULE_NAME)"],
                },
                "Condition": "com_apple_compilers_llvm_clang_1_0__CLANG_ENABLE_MODULE_IMPLEMENTATION_OF__Condition",
                "DefaultValue": "com_apple_compilers_llvm_clang_1_0__CLANG_ENABLE_MODULE_IMPLEMENTATION_OF__DefaultValue",
                "Type": "Boolean",
            },
            "CLANG_ENABLE_BOUNDS_ATTRIBUTES": {
                "CommandLineArgs": {"NO": [], "YES": ["-fbounds-attributes"]},
                "DefaultValue": "com_apple_compilers_llvm_clang_1_0__CLANG_ENABLE_BOUNDS_ATTRIBUTES__DefaultValue",
                "FileTypes": ["sourcecode.c.c"],
                "Type": "Boolean",
            },
            "CLANG_ENABLE_BOUNDS_SAFETY": {
                "CommandLineArgs": {"NO": [], "YES": ["-fbounds-safety"]},
                "DefaultValue": "com_apple_compilers_llvm_clang_1_0__CLANG_ENABLE_BOUNDS_SAFETY__DefaultValue",
                "FileTypes": ["sourcecode.c.c"],
                "Type": "Boolean",
            },
            "CLANG_ENABLE_APP_EXTENSION": {
                "AdditionalLinkerArgs": {
                    "NO": [],
                    "YES": ["-fapplication-extension"],
                },
                "CommandLineArgs": {"NO": [], "YES": ["-fapplication-extension"]},
                "DefaultValue": "com_apple_compilers_llvm_clang_1_0__CLANG_ENABLE_APP_EXTENSION__DefaultValue",
                "Type": "Boolean",
            },
            "GCC_CHAR_IS_UNSIGNED_CHAR": {
                "Category": "Language",
                "CommandLineArgs": {"NO": [], "YES": ["-funsigned-char"]},
                "DefaultValue": "com_apple_compilers_llvm_clang_1_0__GCC_CHAR_IS_UNSIGNED_CHAR__DefaultValue",
                "Type": "Boolean",
            },
            "GCC_ENABLE_ASM_KEYWORD": {
                "Category": "Language",
                "CommandLineArgs": {"NO": ["-fno-asm"], "YES": []},
                "DefaultValue": "com_apple_compilers_llvm_clang_1_0__GCC_ENABLE_ASM_KEYWORD__DefaultValue",
                "Type": "Boolean",
            },
            "GCC_ENABLE_BUILTIN_FUNCTIONS": {
                "Category": "Language",
                "CommandLineArgs": {"NO": ["-fno-builtin"], "YES": []},
                "DefaultValue": "com_apple_compilers_llvm_clang_1_0__GCC_ENABLE_BUILTIN_FUNCTIONS__DefaultValue",
                "Type": "Boolean",
            },
            "GCC_ENABLE_TRIGRAPHS": {
                "Category": "Language",
                "CommandLineArgs": {"NO": ["-Wno-trigraphs"], "YES": ["-trigraphs"]},
                "DefaultValue": "com_apple_compilers_llvm_clang_1_0__GCC_ENABLE_TRIGRAPHS__DefaultValue",
                "Type": "Boolean",
            },
            "GCC_ENABLE_CPP_EXCEPTIONS": {
                "Category": "LanguageCXX",
                "CommandLineArgs": {"NO": ["-fno-exceptions"], "YES": []},
                "DefaultValue": "com_apple_compilers_llvm_clang_1_0__GCC_ENABLE_CPP_EXCEPTIONS__DefaultValue",
                "FileTypes": ["sourcecode.cpp.cpp", "sourcecode.cpp.objcpp"],
                "Type": "Boolean",
            },
            "GCC_ENABLE_CPP_RTTI": {
                "Category": "LanguageCXX",
                "CommandLineArgs": {"NO": ["-fno-rtti", "-fno-sanitize=vptr"], "YES": []},
                "DefaultValue": "com_apple_compilers_llvm_clang_1_0__GCC_ENABLE_CPP_RTTI__DefaultValue",
                "FileTypes": ["sourcecode.cpp.cpp", "sourcecode.cpp.objcpp"],
                "Type": "Boolean",
            },
            "GCC_ENABLE_PASCAL_STRINGS": {
                "Category": "Language",
                "CommandLineArgs": {"NO": [], "YES": ["-fpascal-strings"]},
                "DefaultValue": "com_apple_compilers_llvm_clang_1_0__GCC_ENABLE_PASCAL_STRINGS__DefaultValue",
                "Type": "Boolean",
            },
            "GCC_SHORT_ENUMS": {
                "Category": "Language",
                "CommandLineArgs": {"NO": [], "YES": ["-fshort-enums"]},
                "DefaultValue": "com_apple_compilers_llvm_clang_1_0__GCC_SHORT_ENUMS__DefaultValue",
                "Type": "Boolean",
            },
            "GCC_LINK_WITH_DYNAMIC_LIBRARIES": {
                "Category": "Language",
                "CommandLineArgs": {"NO": ["-static"], "YES": []},
                "DefaultValue": "com_apple_compilers_llvm_clang_1_0__GCC_LINK_WITH_DYNAMIC_LIBRARIES__DefaultValue",
                "Type": "Boolean",
            },
            "GCC_ENABLE_FLOATING_POINT_LIBRARY_CALLS": {
                "Category": "Language",
                "CommandLineArgs": {
                    "NO": [],
                    "YES": ["-msoft-float"],
                },
                "DefaultValue": "com_apple_compilers_llvm_clang_1_0__GCC_ENABLE_FLOATING_POINT_LIBRARY_CALLS__DefaultValue",
                "Type": "Boolean",
            },
            "CLANG_ENABLE_CPP_STATIC_DESTRUCTORS": {
                "Category": "LanguageCXX",
                "CommandLineArgs": {
                    "NO": ["-fno-c++-static-destructors"],
                    "YES": [],
                },
                "DefaultValue": "com_apple_compilers_llvm_clang_1_0__CLANG_ENABLE_CPP_STATIC_DESTRUCTORS__DefaultValue",
                "FileTypes": [
                    "sourcecode.cpp.cpp",
                    "sourcecode.cpp.objcpp",
                ],
                "Type": "Boolean",
            },
            "GCC_PREFIX_HEADER": {
                "Category": "Language",
                "ConditionFlavors": [],
                "DefaultValue": "com_apple_compilers_llvm_clang_1_0__GCC_PREFIX_HEADER__DefaultValue",
                "Type": "String",
            },
            "GCC_PRECOMPILE_PREFIX_HEADER": {
                "Category": "Language",
                "ConditionFlavors": [],
                "DefaultValue": "com_apple_compilers_llvm_clang_1_0__GCC_PRECOMPILE_PREFIX_HEADER__DefaultValue",
                "Type": "Boolean",
            },
            "GCC_INCREASE_PRECOMPILED_HEADER_SHARING": {
                "Category": "Language",
                "ConditionFlavors": [],
                "DefaultValue": "com_apple_compilers_llvm_clang_1_0__GCC_INCREASE_PRECOMPILED_HEADER_SHARING__DefaultValue",
                "Type": "Boolean",
            },
            "OTHER_CFLAGS": {
                "Category": "CustomFlags",
                "FileTypes": ["sourcecode.c.c", "sourcecode.c.objc"],
                "Type": "StringList",
            },
            "OTHER_CPLUSPLUSFLAGS": {
                "Category": "CustomFlags",
                "FileTypes": ["sourcecode.cpp.cpp", "sourcecode.cpp.objcpp"],
                "Type": "StringList",
            },
            "GCC_GENERATE_DEBUGGING_SYMBOLS": {
                "Category": "CodeGeneration",
                "DefaultValue": "com_apple_compilers_llvm_clang_1_0__GCC_GENERATE_DEBUGGING_SYMBOLS__DefaultValue",
                "Type": "Boolean",
            },
            "GCC_OPTIMIZATION_LEVEL": {
                "Category": "CodeGeneration",
                "CommandLineArgs": ["-O$(value)"],
                "DefaultValue": "com_apple_compilers_llvm_clang_1_0__GCC_OPTIMIZATION_LEVEL__DefaultValue",
                "Type": "Enumeration",
                "Values": ["0", "1", "2", "3", "s", "fast", "z"],
            },
            "LLVM_OPTIMIZATION_LEVEL_VAL_0": {
                "DefaultValue": "com_apple_compilers_llvm_clang_1_0__LLVM_OPTIMIZATION_LEVEL_VAL_0__DefaultValue",
                "Type": "Boolean",
            },
            "LLVM_OPTIMIZATION_LEVEL_VAL_1": {
                "DefaultValue": "com_apple_compilers_llvm_clang_1_0__LLVM_OPTIMIZATION_LEVEL_VAL_1__DefaultValue",
                "Type": "Boolean",
            },
            "LLVM_OPTIMIZATION_LEVEL_VAL_2": {
                "DefaultValue": "com_apple_compilers_llvm_clang_1_0__LLVM_OPTIMIZATION_LEVEL_VAL_2__DefaultValue",
                "Type": "Boolean",
            },
            "LLVM_OPTIMIZATION_LEVEL_VAL_3": {
                "DefaultValue": "com_apple_compilers_llvm_clang_1_0__LLVM_OPTIMIZATION_LEVEL_VAL_3__DefaultValue",
                "Type": "Boolean",
            },
            "LLVM_OPTIMIZATION_LEVEL_VAL_s": {
                "DefaultValue": "com_apple_compilers_llvm_clang_1_0__LLVM_OPTIMIZATION_LEVEL_VAL_s__DefaultValue",
                "Type": "Boolean",
            },
            "LLVM_OPTIMIZATION_LEVEL_VAL_fast": {
                "DefaultValue": "com_apple_compilers_llvm_clang_1_0__LLVM_OPTIMIZATION_LEVEL_VAL_fast__DefaultValue",
                "Type": "Boolean",
            },
            "LLVM_OPTIMIZATION_LEVEL_VAL_z": {
                "DefaultValue": "com_apple_compilers_llvm_clang_1_0__LLVM_OPTIMIZATION_LEVEL_VAL_z__DefaultValue",
                "Type": "Boolean",
            },
            "LLVM_IMPLICIT_AGGRESSIVE_OPTIMIZATIONS": {
                "DefaultValue": "com_apple_compilers_llvm_clang_1_0__LLVM_IMPLICIT_AGGRESSIVE_OPTIMIZATIONS__DefaultValue",
                "Type": "Boolean",
            },
            "LLVM_LTO": {
                "AdditionalLinkerArgs": {
                    "NO": [],
                    "YES_THIN": [
                        "-flto=thin",
                        "-Xlinker",
                        "-cache_path_lto",
                        "-Xlinker",
                        "$(OBJROOT)/LTOCache",
                    ],
                },
                "Category": "CodeGeneration",
                "CommandLineArgs": {"NO": [], "YES": ["-flto"], "YES_THIN": ["-flto=thin"]},
                "DefaultValue": "com_apple_compilers_llvm_clang_1_0__LLVM_LTO__DefaultValue",
                "Type": "Enumeration",
                "Values": ["YES", "YES_THIN", "NO"],
            },
            "GCC_NO_COMMON_BLOCKS": {
                "Category": "CodeGeneration",
                "CommandLineArgs": {"NO": [], "YES": ["-fno-common"]},
                "DefaultValue": "com_apple_compilers_llvm_clang_1_0__GCC_NO_COMMON_BLOCKS__DefaultValue",
                "Type": "Boolean",
            },
            "GCC_REUSE_STRINGS": {
                "Category": "CodeGeneration",
                "CommandLineArgs": {"NO": ["-fwritable-strings"], "YES": []},
                "DefaultValue": "com_apple_compilers_llvm_clang_1_0__GCC_REUSE_STRINGS__DefaultValue",
                "Type": "Boolean",
            },
            "GCC_DYNAMIC_NO_PIC": {
                "Category": "CodeGeneration",
                "CommandLineArgs": {"NO": [], "YES": ["-mdynamic-no-pic"]},
                "DefaultValue": "com_apple_compilers_llvm_clang_1_0__GCC_DYNAMIC_NO_PIC__DefaultValue",
                "Type": "Boolean",
            },
            "GCC_ENABLE_KERNEL_DEVELOPMENT": {
                "Category": "CodeGeneration",
                "CommandLineArgs": {"NO": [], "YES": ["-mkernel"]},
                "DefaultValue": "com_apple_compilers_llvm_clang_1_0__GCC_ENABLE_KERNEL_DEVELOPMENT__DefaultValue",
                "Type": "Boolean",
            },
            "GCC_TREAT_WARNINGS_AS_ERRORS": {
                "Category": "WarningsPolicy",
                "CommandLineArgs": {"NO": [], "YES": ["-Werror"]},
                "DefaultValue": "com_apple_compilers_llvm_clang_1_0__GCC_TREAT_WARNINGS_AS_ERRORS__DefaultValue",
                "Type": "Boolean",
            },
            "GCC_TREAT_IMPLICIT_FUNCTION_DECLARATIONS_AS_ERRORS": {
                "AppearsAfter": "GCC_TREAT_WARNINGS_AS_ERRORS",
                "Category": "Warnings",
                "CommandLineArgs": {
                    "NO": [],
                    "YES": ["-Werror=implicit-function-declaration"],
                },
                "DefaultValue": "com_apple_compilers_llvm_clang_1_0__GCC_TREAT_IMPLICIT_FUNCTION_DECLARATIONS_AS_ERRORS__DefaultValue",
                "FileTypes": [
                    "sourcecode.c.c",
                    "sourcecode.c.objc",
                ],
                "Type": "Boolean",
            },
            "GCC_TREAT_INCOMPATIBLE_POINTER_TYPE_WARNINGS_AS_ERRORS": {
                "AppearsAfter": "GCC_TREAT_WARNINGS_AS_ERRORS",
                "Category": "Warnings",
                "CommandLineArgs": {
                    "NO": [],
                    "YES": ["-Werror=incompatible-pointer-types"],
                },
                "DefaultValue": "com_apple_compilers_llvm_clang_1_0__GCC_TREAT_INCOMPATIBLE_POINTER_TYPE_WARNINGS_AS_ERRORS__DefaultValue",
                "Type": "Boolean",
            },
            "GCC_WARN_ABOUT_MISSING_FIELD_INITIALIZERS": {
                "Category": "Warnings",
                "CommandLineArgs": {
                    "NO": ["-Wno-missing-field-initializers"],
                    "YES": ["-Wmissing-field-initializers"],
                },
                "DefaultValue": "com_apple_compilers_llvm_clang_1_0__GCC_WARN_ABOUT_MISSING_FIELD_INITIALIZERS__DefaultValue",
                "Type": "Boolean",
            },
            "GCC_WARN_ABOUT_MISSING_PROTOTYPES": {
                "Category": "Warnings",
                "CommandLineArgs": {
                    "NO": ["-Wno-missing-prototypes"],
                    "YES": ["-Wmissing-prototypes"],
                },
                "DefaultValue": "com_apple_compilers_llvm_clang_1_0__GCC_WARN_ABOUT_MISSING_PROTOTYPES__DefaultValue",
                "Type": "Boolean",
            },
            "GCC_WARN_ABOUT_RETURN_TYPE": {
                "Category": "Warnings",
                "CommandLineArgs": {
                    "NO": ["-Wno-return-type"],
                    "YES": [],
                    "YES_ERROR": ["-Werror=return-type"],
                },
                "DefaultValue": "com_apple_compilers_llvm_clang_1_0__GCC_WARN_ABOUT_RETURN_TYPE__DefaultValue",
                "Type": "Enumeration",
                "Values": ["YES", "NO", "YES_ERROR"],
            },
            "CLANG_WARN_DOCUMENTATION_COMMENTS": {
                "Category": "Warnings",
                "CommandLineArgs": {"NO": [], "YES": ["-Wdocumentation"]},
                "DefaultValue": "com_apple_compilers_llvm_clang_1_0__CLANG_WARN_DOCUMENTATION_COMMENTS__DefaultValue",
                "Type": "Boolean",
            },
            "CLANG_WARN_UNREACHABLE_CODE": {
                "Category": "Warnings",
                "CommandLineArgs": {
                    "NO": [],
                    "YES": ["-Wunreachable-code"],
                    "YES_AGGRESSIVE": ["-Wunreachable-code-aggressive"],
                },
                "DefaultValue": "com_apple_compilers_llvm_clang_1_0__CLANG_WARN_UNREACHABLE_CODE__DefaultValue",
                "Type": "Enumeration",
                "Values": ["YES", "YES_AGGRESSIVE", "NO"],
            },
            "CLANG_WARN_QUOTED_INCLUDE_IN_FRAMEWORK_HEADER": {
                "Category": "Warnings",
                "CommandLineArgs": {
                    "NO": [],
                    "YES": ["-Wquoted-include-in-framework-header"],
                    "YES_ERROR": [
                        "-Wquoted-include-in-framework-header",
                        "-Werror=quoted-include-in-framework-header",
                    ],
                },
                "DefaultValue": "com_apple_compilers_llvm_clang_1_0__CLANG_WARN_QUOTED_INCLUDE_IN_FRAMEWORK_HEADER__DefaultValue",
                "Type": "Enumeration",
                "Values": ["YES", "YES_ERROR", "NO"],
            },
            "CLANG_WARN_FRAMEWORK_INCLUDE_PRIVATE_FROM_PUBLIC": {
                "Category": "Warnings",
                "CommandLineArgs": {
                    "NO": [],
                    "YES": ["-Wframework-include-private-from-public"],
                },
                "DefaultValue": "com_apple_compilers_llvm_clang_1_0__CLANG_WARN_FRAMEWORK_INCLUDE_PRIVATE_FROM_PUBLIC__DefaultValue",
                "Type": "Enumeration",
                "Values": ["YES", "NO"],
            },
            "CLANG_WARN_NULLABLE_TO_NONNULL_CONVERSION": {
                "CommandLineArgs": {
                    "NO": [],
                    "YES": ["-Wnullable-to-nonnull-conversion"],
                },
                "DefaultValue": "com_apple_compilers_llvm_clang_1_0__CLANG_WARN_NULLABLE_TO_NONNULL_CONVERSION__DefaultValue",
                "Type": "Boolean",
            },
            "CLANG_WARN_OBJC_IMPLICIT_ATOMIC_PROPERTIES": {
                "Category": "WarningsObjC",
                "CommandLineArgs": {
                    "NO": ["-Wno-implicit-atomic-properties"],
                    "YES": ["-Wimplicit-atomic-properties"],
                },
                "DefaultValue": "com_apple_compilers_llvm_clang_1_0__CLANG_WARN_OBJC_IMPLICIT_ATOMIC_PROPERTIES__DefaultValue",
                "FileTypes": [
                    "sourcecode.c.objc",
                    "sourcecode.cpp.objcpp",
                ],
                "Type": "Boolean",
            },
            "CLANG_WARN_DIRECT_OBJC_ISA_USAGE": {
                "Category": "WarningsObjC",
                "CommandLineArgs": {
                    "NO": ["-Wno-deprecated-objc-isa-usage"],
                    "YES": [],
                    "YES_ERROR": ["-Werror=deprecated-objc-isa-usage"],
                },
                "DefaultValue": "com_apple_compilers_llvm_clang_1_0__CLANG_WARN_DIRECT_OBJC_ISA_USAGE__DefaultValue",
                "Type": "Enumeration",
                "Values": ["YES", "NO", "YES_ERROR"],
            },
            "CLANG_WARN_OBJC_INTERFACE_IVARS": {
                "Category": "WarningsObjC",
                "CommandLineArgs": {
                    "NO": ["-Wno-objc-interface-ivars"],
                    "YES": ["-Wobjc-interface-ivars"],
                    "YES_ERROR": ["-Werror=objc-interface-ivars"],
                },
                "DefaultValue": "com_apple_compilers_llvm_clang_1_0__CLANG_WARN_OBJC_INTERFACE_IVARS__DefaultValue",
                "FileTypes": ["sourcecode.c.objc", "sourcecode.cpp.objcpp"],
                "Type": "Enumeration",
                "Values": ["NO", "YES", "YES_ERROR"],
            },
            "CLANG_WARN_OBJC_MISSING_PROPERTY_SYNTHESIS": {
                "Category": "WarningsObjC",
                "CommandLineArgs": {
                    "NO": [],
                    "YES": ["-Wobjc-missing-property-synthesis"],
                },
                "DefaultValue": "com_apple_compilers_llvm_clang_1_0__CLANG_WARN_OBJC_MISSING_PROPERTY_SYNTHESIS__DefaultValue",
                "FileTypes": [
                    "sourcecode.c.objc",
                    "sourcecode.cpp.objcpp",
                ],
                "Type": "Boolean",
            },
            "CLANG_WARN_OBJC_ROOT_CLASS": {
                "Category": "WarningsObjC",
                "CommandLineArgs": {
                    "NO": ["-Wno-objc-root-class"],
                    "YES": [],
                    "YES_ERROR": ["-Werror=objc-root-class"],
                },
                "DefaultValue": "com_apple_compilers_llvm_clang_1_0__CLANG_WARN_OBJC_ROOT_CLASS__DefaultValue",
                "Type": "Enumeration",
                "Values": ["YES", "NO", "YES_ERROR"],
            },
            "CLANG_WARN_OBJC_REPEATED_USE_OF_WEAK": {
                "Category": "WarningsObjCARC",
                "CommandLineArgs": {
                    "NO": ["-Wno-arc-repeated-use-of-weak"],
                    "YES": [
                        "-Warc-repeated-use-of-weak",
                        "-Wno-arc-maybe-repeated-use-of-weak",
                    ],
                    "YES_AGGRESSIVE": [
                        "-Warc-repeated-use-of-weak",
                        "-Warc-maybe-repeated-use-of-weak",
                    ],
                },
                "DefaultValue": "com_apple_compilers_llvm_clang_1_0__CLANG_WARN_OBJC_REPEATED_USE_OF_WEAK__DefaultValue",
                "FileTypes": [
                    "sourcecode.c.objc",
                    "sourcecode.cpp.objcpp",
                ],
                "Type": "Enumeration",
                "Values": ["YES", "NO", "YES_AGGRESSIVE"],
            },
            "CLANG_WARN_OBJC_EXPLICIT_OWNERSHIP_TYPE": {
                "Category": "WarningsObjCARC",
                "CommandLineArgs": {
                    "NO": [],
                    "YES": ["-Wexplicit-ownership-type"],
                },
                "DefaultValue": "com_apple_compilers_llvm_clang_1_0__CLANG_WARN_OBJC_EXPLICIT_OWNERSHIP_TYPE__DefaultValue",
                "FileTypes": [
                    "sourcecode.c.objc",
                    "sourcecode.cpp.objcpp",
                ],
                "Type": "Boolean",
            },
            "CLANG_WARN_OBJC_IMPLICIT_RETAIN_SELF": {
                "Category": "WarningsObjCARC",
                "CommandLineArgs": {
                    "NO": [],
                    "YES": ["-Wimplicit-retain-self"],
                },
                "DefaultValue": "com_apple_compilers_llvm_clang_1_0__CLANG_WARN_OBJC_IMPLICIT_RETAIN_SELF__DefaultValue",
                "FileTypes": [
                    "sourcecode.c.objc",
                    "sourcecode.cpp.objcpp",
                ],
                "Type": "Boolean",
            },
            "GCC_WARN_NON_VIRTUAL_DESTRUCTOR": {
                "Category": "WarningsCXX",
                "CommandLineArgs": {
                    "NO": ["-Wno-non-virtual-dtor"],
                    "YES": ["-Wnon-virtual-dtor"],
                },
                "DefaultValue": "com_apple_compilers_llvm_clang_1_0__GCC_WARN_NON_VIRTUAL_DESTRUCTOR__DefaultValue",
                "FileTypes": ["sourcecode.cpp.cpp", "sourcecode.cpp.objcpp"],
                "Type": "Boolean",
            },
            "GCC_WARN_HIDDEN_VIRTUAL_FUNCTIONS": {
                "Category": "WarningsCXX",
                "CommandLineArgs": {
                    "NO": ["-Wno-overloaded-virtual"],
                    "YES": ["-Woverloaded-virtual"],
                },
                "DefaultValue": "com_apple_compilers_llvm_clang_1_0__GCC_WARN_HIDDEN_VIRTUAL_FUNCTIONS__DefaultValue",
                "FileTypes": [
                    "sourcecode.cpp.cpp",
                    "sourcecode.cpp.objcpp",
                ],
                "Type": "Boolean",
            },
            "CLANG_WARN__EXIT_TIME_DESTRUCTORS": {
                "Category": "WarningsCXX",
                "CommandLineArgs": {
                    "NO": ["-Wno-exit-time-destructors"],
                    "YES": ["-Wexit-time-destructors"],
                },
                "DefaultValue": "com_apple_compilers_llvm_clang_1_0__CLANG_WARN__EXIT_TIME_DESTRUCTORS__DefaultValue",
                "FileTypes": [
                    "sourcecode.cpp.cpp",
                    "sourcecode.cpp.objcpp",
                ],
                "Type": "Boolean",
            },
            "CLANG_WARN__ARC_BRIDGE_CAST_NONARC": {
                "Category": "WarningsObjCARC",
                "CommandLineArgs": {
                    "NO": ["-Wno-arc-bridge-casts-disallowed-in-nonarc"],
                    "YES": [],
                },
                "DefaultValue": "com_apple_compilers_llvm_clang_1_0__CLANG_WARN__ARC_BRIDGE_CAST_NONARC__DefaultValue",
                "FileTypes": [
                    "sourcecode.c.objc",
                    "sourcecode.cpp.objcpp",
                ],
                "Type": "Boolean",
            },
            "CLANG_WARN__DUPLICATE_METHOD_MATCH": {
                "Category": "WarningsObjC",
                "CommandLineArgs": {
                    "NO": [],
                    "YES": ["-Wduplicate-method-match"],
                },
                "DefaultValue": "com_apple_compilers_llvm_clang_1_0__CLANG_WARN__DUPLICATE_METHOD_MATCH__DefaultValue",
                "FileTypes": [
                    "sourcecode.c.objc",
                    "sourcecode.cpp.objcpp",
                ],
                "Type": "Boolean",
            },
            "GCC_WARN_TYPECHECK_CALLS_TO_PRINTF": {
                "Category": "Warnings",
                "CommandLineArgs": {"NO": ["-Wno-format"], "YES": []},
                "DefaultValue": "com_apple_compilers_llvm_clang_1_0__GCC_WARN_TYPECHECK_CALLS_TO_PRINTF__DefaultValue",
                "Type": "Boolean",
            },
            "GCC_WARN_INITIALIZER_NOT_FULLY_BRACKETED": {
                "Category": "Warnings",
                "CommandLineArgs": {
                    "NO": ["-Wno-missing-braces"],
                    "YES": ["-Wmissing-braces"],
                },
                "DefaultValue": "com_apple_compilers_llvm_clang_1_0__GCC_WARN_INITIALIZER_NOT_FULLY_BRACKETED__DefaultValue",
                "Type": "Boolean",
            },
            "GCC_WARN_MISSING_PARENTHESES": {
                "Category": "Warnings",
                "CommandLineArgs": {
                    "NO": ["-Wno-parentheses"],
                    "YES": ["-Wparentheses"],
                },
                "DefaultValue": "com_apple_compilers_llvm_clang_1_0__GCC_WARN_MISSING_PARENTHESES__DefaultValue",
                "Type": "Boolean",
            },
            "GCC_WARN_CHECK_SWITCH_STATEMENTS": {
                "Category": "Warnings",
                "CommandLineArgs": {
                    "NO": ["-Wno-switch"],
                    "YES": ["-Wswitch"],
                },
                "DefaultValue": "com_apple_compilers_llvm_clang_1_0__GCC_WARN_CHECK_SWITCH_STATEMENTS__DefaultValue",
                "Type": "Boolean",
            },
            "CLANG_WARN_COMPLETION_HANDLER_MISUSE": {
                "Category": "Warnings",
                "CommandLineArgs": {
                    "NO": [],
                    "YES": ["-Wcompletion-handler"],
                },
                "DefaultValue": "com_apple_compilers_llvm_clang_1_0__CLANG_WARN_COMPLETION_HANDLER_MISUSE__DefaultValue",
                "Type": "Boolean",
            },
            "GCC_WARN_UNUSED_FUNCTION": {
                "Category": "Warnings",
                "CommandLineArgs": {
                    "NO": ["-Wno-unused-function"],
                    "YES": ["-Wunused-function"],
                },
                "DefaultValue": "com_apple_compilers_llvm_clang_1_0__GCC_WARN_UNUSED_FUNCTION__DefaultValue",
                "Type": "Boolean",
            },
            "GCC_WARN_UNUSED_LABEL": {
                "Category": "Warnings",
                "CommandLineArgs": {
                    "NO": ["-Wno-unused-label"],
                    "YES": ["-Wunused-label"],
                },
                "DefaultValue": "com_apple_compilers_llvm_clang_1_0__GCC_WARN_UNUSED_LABEL__DefaultValue",
                "Type": "Boolean",
            },
            "CLANG_WARN_EMPTY_BODY": {
                "Category": "Warnings",
                "CommandLineArgs": {"NO": ["-Wno-empty-body"], "YES": ["-Wempty-body"]},
                "DefaultValue": "com_apple_compilers_llvm_clang_1_0__CLANG_WARN_EMPTY_BODY__DefaultValue",
                "Type": "Boolean",
            },
            "GCC_WARN_UNINITIALIZED_AUTOS": {
                "Category": "Warnings",
                "CommandLineArgs": {
                    "NO": ["-Wno-uninitialized"],
                    "YES": ["-Wuninitialized"],
                    "YES_AGGRESSIVE": [
                        "-Wuninitialized",
                        "-Wconditional-uninitialized",
                    ],
                },
                "DefaultValue": "com_apple_compilers_llvm_clang_1_0__GCC_WARN_UNINITIALIZED_AUTOS__DefaultValue",
                "Type": "Enumeration",
                "Values": ["YES", "YES_AGGRESSIVE", "NO"],
            },
            "GCC_WARN_UNKNOWN_PRAGMAS": {
                "Category": "Warnings",
                "CommandLineArgs": {
                    "NO": ["-Wno-unknown-pragmas"],
                    "YES": ["-Wunknown-pragmas"],
                },
                "DefaultValue": "com_apple_compilers_llvm_clang_1_0__GCC_WARN_UNKNOWN_PRAGMAS__DefaultValue",
                "Type": "Boolean",
            },
            "GCC_WARN_INHIBIT_ALL_WARNINGS": {
                "Category": "WarningsPolicy",
                "CommandLineFlag": "-w",
                "DefaultValue": "com_apple_compilers_llvm_clang_1_0__GCC_WARN_INHIBIT_ALL_WARNINGS__DefaultValue",
                "Type": "Boolean",
            },
            "GCC_WARN_PEDANTIC": {
                "Category": "WarningsPolicy",
                "CommandLineArgs": {"NO": [], "YES": ["-pedantic"]},
                "DefaultValue": "com_apple_compilers_llvm_clang_1_0__GCC_WARN_PEDANTIC__DefaultValue",
                "Type": "Boolean",
            },
            "GCC_WARN_SHADOW": {
                "Category": "Warnings",
                "CommandLineArgs": {"NO": ["-Wno-shadow"], "YES": ["-Wshadow"]},
                "DefaultValue": "com_apple_compilers_llvm_clang_1_0__GCC_WARN_SHADOW__DefaultValue",
                "Type": "Boolean",
            },
            "GCC_WARN_FOUR_CHARACTER_CONSTANTS": {
                "Category": "Warnings",
                "CommandLineArgs": {
                    "NO": ["-Wno-four-char-constants"],
                    "YES": ["-Wfour-char-constants"],
                },
                "DefaultValue": "com_apple_compilers_llvm_clang_1_0__GCC_WARN_FOUR_CHARACTER_CONSTANTS__DefaultValue",
                "Type": "Boolean",
            },
            "CLANG_WARN_SUSPICIOUS_IMPLICIT_CONVERSION": {
                "Category": "Warnings",
                "CommandLineArgs": {
                    "NO": ["-Wno-conversion"],
                    "YES": ["-Wconversion"],
                    "YES_ERROR": ["-Werror=conversion"],
                },
                "DefaultValue": "com_apple_compilers_llvm_clang_1_0__CLANG_WARN_SUSPICIOUS_IMPLICIT_CONVERSION__DefaultValue",
                "Type": "Enumeration",
                "Values": ["YES", "YES_ERROR", "NO"],
            },
            "CLANG_WARN_CONSTANT_CONVERSION": {
                "Category": "Warnings",
                "CommandLineArgs": {
                    "NO": ["-Wno-constant-conversion"],
                    "YES": ["-Wconstant-conversion"],
                    "YES_ERROR": ["-Werror=constant-conversion"],
                },
                "DefaultValue": "com_apple_compilers_llvm_clang_1_0__CLANG_WARN_CONSTANT_CONVERSION__DefaultValue",
                "Type": "Enumeration",
                "Values": ["YES", "YES_ERROR", "NO"],
            },
            "CLANG_WARN_INT_CONVERSION": {
                "Category": "Warnings",
                "CommandLineArgs": {
                    "NO": ["-Wno-int-conversion"],
                    "YES": ["-Wint-conversion"],
                    "YES_ERROR": ["-Werror=int-conversion"],
                },
                "DefaultValue": "com_apple_compilers_llvm_clang_1_0__CLANG_WARN_INT_CONVERSION__DefaultValue",
                "Type": "Enumeration",
                "Values": ["YES", "YES_ERROR", "NO"],
            },
            "CLANG_WARN_BOOL_CONVERSION": {
                "Category": "Warnings",
                "CommandLineArgs": {
                    "NO": ["-Wno-bool-conversion"],
                    "YES": ["-Wbool-conversion"],
                    "YES_ERROR": ["-Werror=bool-conversion"],
                },
                "DefaultValue": "com_apple_compilers_llvm_clang_1_0__CLANG_WARN_BOOL_CONVERSION__DefaultValue",
                "Type": "Enumeration",
                "Values": ["YES", "YES_ERROR", "NO"],
            },
            "CLANG_WARN_ENUM_CONVERSION": {
                "Category": "Warnings",
                "CommandLineArgs": {
                    "NO": ["-Wno-enum-conversion"],
                    "YES": ["-Wenum-conversion"],
                    "YES_ERROR": ["-Werror=enum-conversion"],
                },
                "DefaultValue": "com_apple_compilers_llvm_clang_1_0__CLANG_WARN_ENUM_CONVERSION__DefaultValue",
                "Type": "Enumeration",
                "Values": ["YES", "YES_ERROR", "NO"],
            },
            "CLANG_WARN_FLOAT_CONVERSION": {
                "Category": "Warnings",
                "CommandLineArgs": {
                    "NO": ["-Wno-float-conversion"],
                    "YES": ["-Wfloat-conversion"],
                    "YES_ERROR": ["-Werror=float-conversion"],
                },
                "DefaultValue": "com_apple_compilers_llvm_clang_1_0__CLANG_WARN_FLOAT_CONVERSION__DefaultValue",
                "Type": "Enumeration",
                "Values": ["YES", "YES_ERROR", "NO"],
            },
            "CLANG_WARN_NON_LITERAL_NULL_CONVERSION": {
                "Category": "Warnings",
                "CommandLineArgs": {
                    "NO": ["-Wno-non-literal-null-conversion"],
                    "YES": ["-Wnon-literal-null-conversion"],
                    "YES_ERROR": ["-Werror=non-literal-null-conversion"],
                },
                "DefaultValue": "com_apple_compilers_llvm_clang_1_0__CLANG_WARN_NON_LITERAL_NULL_CONVERSION__DefaultValue",
                "Type": "Enumeration",
                "Values": ["YES", "YES_ERROR", "NO"],
            },
            "CLANG_WARN_OBJC_LITERAL_CONVERSION": {
                "Category": "WarningsObjC",
                "CommandLineArgs": {
                    "NO": ["-Wno-objc-literal-conversion"],
                    "YES": ["-Wobjc-literal-conversion"],
                    "YES_ERROR": ["-Werror=objc-literal-conversion"],
                },
                "DefaultValue": "com_apple_compilers_llvm_clang_1_0__CLANG_WARN_OBJC_LITERAL_CONVERSION__DefaultValue",
                "Type": "Enumeration",
                "Values": ["YES", "YES_ERROR", "NO"],
            },
            "CLANG_WARN_MISSING_NOESCAPE": {
                "Category": "WarningsObjC",
                "CommandLineArgs": {
                    "NO": ["-Wno-missing-noescape"],
                    "YES": [],
                    "YES_ERROR": ["-Werror=missing-noescape"],
                },
                "DefaultValue": "com_apple_compilers_llvm_clang_1_0__CLANG_WARN_MISSING_NOESCAPE__DefaultValue",
                "Type": "Enumeration",
                "Values": ["YES", "YES_ERROR", "NO"],
            },
            "CLANG_WARN_PRAGMA_PACK": {
                "Category": "Warnings",
                "CommandLineArgs": {
                    "NO": ["-Wno-pragma-pack"],
                    "YES": [],
                    "YES_ERROR": ["-Werror=pragma-pack"],
                },
                "DefaultValue": "com_apple_compilers_llvm_clang_1_0__CLANG_WARN_PRAGMA_PACK__DefaultValue",
                "Type": "Enumeration",
                "Values": ["YES", "YES_ERROR", "NO"],
            },
            "CLANG_WARN_PRIVATE_MODULE": {
                "Category": "Warnings",
                "CommandLineArgs": {"NO": ["-Wno-private-module"], "YES": []},
                "DefaultValue": "com_apple_compilers_llvm_clang_1_0__CLANG_WARN_PRIVATE_MODULE__DefaultValue",
                "Type": "Boolean",
            },
            "CLANG_WARN_VEXING_PARSE": {
                "Category": "WarningsCXX",
                "CommandLineArgs": {
                    "NO": ["-Wno-vexing-parse"],
                    "YES": [],
                    "YES_ERROR": ["-Werror=vexing-parse"],
                },
                "DefaultValue": "com_apple_compilers_llvm_clang_1_0__CLANG_WARN_VEXING_PARSE__DefaultValue",
                "Type": "Enumeration",
                "Values": ["YES", "YES_ERROR", "NO"],
            },
            "CLANG_WARN_DELETE_NON_VIRTUAL_DTOR": {
                "Category": "WarningsCXX",
                "CommandLineArgs": {
                    "NO": ["-Wno-delete-non-virtual-dtor"],
                    "YES": [],
                    "YES_ERROR": ["-Werror=delete-non-virtual-dtor"],
                },
                "DefaultValue": "com_apple_compilers_llvm_clang_1_0__CLANG_WARN_DELETE_NON_VIRTUAL_DTOR__DefaultValue",
                "Type": "Enumeration",
                "Values": ["YES", "YES_ERROR", "NO"],
            },
            "CLANG_WARN_ASSIGN_ENUM": {
                "Category": "Warnings",
                "CommandLineArgs": {"NO": [], "YES": ["-Wassign-enum"]},
                "DefaultValue": "com_apple_compilers_llvm_clang_1_0__CLANG_WARN_ASSIGN_ENUM__DefaultValue",
                "Type": "Boolean",
            },
            "GCC_WARN_SIGN_COMPARE": {
                "Category": "Warnings",
                "CommandLineArgs": {"NO": [], "YES": ["-Wsign-compare"]},
                "DefaultValue": "com_apple_compilers_llvm_clang_1_0__GCC_WARN_SIGN_COMPARE__DefaultValue",
                "Type": "Boolean",
            },
            "GCC_WARN_MULTIPLE_DEFINITION_TYPES_FOR_SELECTOR": {
                "CommandLineArgs": {
                    "NO": ["-Wno-selector"],
                    "YES": ["-Wselector"],
                },
                "DefaultValue": "com_apple_compilers_llvm_clang_1_0__GCC_WARN_MULTIPLE_DEFINITION_TYPES_FOR_SELECTOR__DefaultValue",
                "FileTypes": [
                    "sourcecode.c.objc",
                    "sourcecode.cpp.objcpp",
                ],
                "Type": "Boolean",
            },
            "GCC_WARN_STRICT_SELECTOR_MATCH": {
                "Category": "WarningsObjC",
                "CommandLineArgs": {
                    "NO": ["-Wno-strict-selector-match"],
                    "YES": ["-Wstrict-selector-match"],
                },
                "DefaultValue": "com_apple_compilers_llvm_clang_1_0__GCC_WARN_STRICT_SELECTOR_MATCH__DefaultValue",
                "FileTypes": ["sourcecode.c.objc", "sourcecode.cpp.objcpp"],
                "Type": "Boolean",
            },
            "GCC_WARN_UNDECLARED_SELECTOR": {
                "Category": "WarningsObjC",
                "CommandLineArgs": {
                    "NO": ["-Wno-undeclared-selector"],
                    "YES": ["-Wundeclared-selector"],
                },
                "DefaultValue": "com_apple_compilers_llvm_clang_1_0__GCC_WARN_UNDECLARED_SELECTOR__DefaultValue",
                "FileTypes": ["sourcecode.c.objc", "sourcecode.cpp.objcpp"],
                "Type": "Boolean",
            },
            "CLANG_WARN_DEPRECATED_OBJC_IMPLEMENTATIONS": {
                "Category": "WarningsObjC",
                "CommandLineArgs": {
                    "NO": ["-Wno-deprecated-implementations"],
                    "YES": ["-Wdeprecated-implementations"],
                },
                "DefaultValue": "com_apple_compilers_llvm_clang_1_0__CLANG_WARN_DEPRECATED_OBJC_IMPLEMENTATIONS__DefaultValue",
                "FileTypes": [
                    "sourcecode.c.objc",
                    "sourcecode.cpp.objcpp",
                ],
                "Type": "Boolean",
            },
            "CLANG_WARN_CXX0X_EXTENSIONS": {
                "Category": "WarningsCXX",
                "CommandLineArgs": {
                    "NO": ["-Wno-c++11-extensions"],
                    "YES": ["-Wc++11-extensions"],
                },
                "DefaultValue": "com_apple_compilers_llvm_clang_1_0__CLANG_WARN_CXX0X_EXTENSIONS__DefaultValue",
                "FileTypes": ["sourcecode.cpp.cpp", "sourcecode.cpp.objcpp"],
                "Type": "Boolean",
            },
            "CLANG_WARN_ATOMIC_IMPLICIT_SEQ_CST": {
                "Category": "WarningsCXX",
                "CommandLineArgs": {
                    "NO": [],
                    "YES": ["-Watomic-implicit-seq-cst"],
                },
                "DefaultValue": "com_apple_compilers_llvm_clang_1_0__CLANG_WARN_ATOMIC_IMPLICIT_SEQ_CST__DefaultValue",
                "FileTypes": [
                    "sourcecode.c.c",
                    "sourcecode.c.objc",
                    "sourcecode.cpp.cpp",
                    "sourcecode.cpp.objcpp",
                ],
                "Type": "Boolean",
            },
            "CLANG_WARN_IMPLICIT_FALLTHROUGH": {
                "Category": "Warnings",
                "CommandLineArgs": {
                    "NO": ["-Wno-implicit-fallthrough"],
                    "YES": ["-Wimplicit-fallthrough"],
                    "YES_ERROR": ["-Werror=implicit-fallthrough"],
                },
                "DefaultValue": "com_apple_compilers_llvm_clang_1_0__CLANG_WARN_IMPLICIT_FALLTHROUGH__DefaultValue",
                "Type": "Enumeration",
                "Values": ["YES", "NO", "YES_ERROR"],
            },
            "CLANG_TRIVIAL_AUTO_VAR_INIT": {
                "CommandLineArgs": {
                    "default": [],
                    "pattern": ["-ftrivial-auto-var-init=pattern"],
                    "uninitialized": ["-ftrivial-auto-var-init=uninitialized"],
                    "zero": ["-ftrivial-auto-var-init=zero"],
                },
                "DefaultValue": "com_apple_compilers_llvm_clang_1_0__CLANG_TRIVIAL_AUTO_VAR_INIT__DefaultValue",
                "FileTypes": [
                    "sourcecode.c.c",
                    "sourcecode.c.objc",
                    "sourcecode.cpp.cpp",
                    "sourcecode.cpp.objcpp",
                ],
                "Type": "Enumeration",
                "Values": ["default", "uninitialized", "zero", "pattern"],
            },
            "WARNING_CFLAGS": {
                "Category": "CustomFlags",
                "DefaultValue": "com_apple_compilers_llvm_clang_1_0__WARNING_CFLAGS__DefaultValue",
                "Type": "StringList",
            },
            "GCC_PREPROCESSOR_DEFINITIONS": {
                "Category": "Preprocessing",
                "CommandLineArgs": ["-D$(value)"],
                "DefaultValue": "com_apple_compilers_llvm_clang_1_0__GCC_PREPROCESSOR_DEFINITIONS__DefaultValue",
                "Type": "StringList",
            },
            "GCC_PRODUCT_TYPE_PREPROCESSOR_DEFINITIONS": {
                "CommandLineArgs": ["-D$(value)"],
                "DefaultValue": "com_apple_compilers_llvm_clang_1_0__GCC_PRODUCT_TYPE_PREPROCESSOR_DEFINITIONS__DefaultValue",
                "Type": "StringList",
            },
            "GCC_PREPROCESSOR_DEFINITIONS_NOT_USED_IN_PRECOMPS": {
                "Category": "Preprocessing",
                "DefaultValue": "com_apple_compilers_llvm_clang_1_0__GCC_PREPROCESSOR_DEFINITIONS_NOT_USED_IN_PRECOMPS__DefaultValue",
                "Type": "StringList",
            },
            "ENABLE_NS_ASSERTIONS": {
                "Category": "Preprocessing",
                "CommandLineArgs": {"NO": ["-DNS_BLOCK_ASSERTIONS=1"], "YES": []},
                "DefaultValue": "com_apple_compilers_llvm_clang_1_0__ENABLE_NS_ASSERTIONS__DefaultValue",
                "FileTypes": ["sourcecode.c.objc", "sourcecode.cpp.objcpp"],
                "Type": "Boolean",
            },
            "ENABLE_STRICT_OBJC_MSGSEND": {
                "Category": "Preprocessing",
                "CommandLineArgs": {
                    "NO": ["-DOBJC_OLD_DISPATCH_PROTOTYPES=1"],
                    "YES": ["-DOBJC_OLD_DISPATCH_PROTOTYPES=0"],
                },
                "DefaultValue": "com_apple_compilers_llvm_clang_1_0__ENABLE_STRICT_OBJC_MSGSEND__DefaultValue",
                "FileTypes": ["sourcecode.c.objc", "sourcecode.cpp.objcpp"],
                "Type": "Boolean",
            },
            "USE_HEADERMAP": {
                "DefaultValue": "com_apple_compilers_llvm_clang_1_0__USE_HEADERMAP__DefaultValue",
                "Type": "Boolean",
            },
            "HEADERMAP_FILE_FORMAT": {
                "DefaultValue": "com_apple_compilers_llvm_clang_1_0__HEADERMAP_FILE_FORMAT__DefaultValue",
                "Type": "Enumeration",
                "Values": ["traditional"],
            },
            "CPP_HEADERMAP_FILE": {
                "DefaultValue": "com_apple_compilers_llvm_clang_1_0__CPP_HEADERMAP_FILE__DefaultValue",
                "Type": "Path",
            },
            "CPP_HEADERMAP_FILE_FOR_GENERATED_FILES": {
                "DefaultValue": "com_apple_compilers_llvm_clang_1_0__CPP_HEADERMAP_FILE_FOR_GENERATED_FILES__DefaultValue",
                "Type": "Path",
            },
            "CPP_HEADERMAP_FILE_FOR_OWN_TARGET_HEADERS": {
                "DefaultValue": "com_apple_compilers_llvm_clang_1_0__CPP_HEADERMAP_FILE_FOR_OWN_TARGET_HEADERS__DefaultValue",
                "Type": "Path",
            },
            "CPP_HEADERMAP_FILE_FOR_ALL_TARGET_HEADERS": {
                "DefaultValue": "com_apple_compilers_llvm_clang_1_0__CPP_HEADERMAP_FILE_FOR_ALL_TARGET_HEADERS__DefaultValue",
                "Type": "Path",
            },
            "CPP_HEADERMAP_FILE_FOR_ALL_NON_FRAMEWORK_TARGET_HEADERS": {
                "DefaultValue": "com_apple_compilers_llvm_clang_1_0__CPP_HEADERMAP_FILE_FOR_ALL_NON_FRAMEWORK_TARGET_HEADERS__DefaultValue",
                "Type": "Path",
            },
            "CPP_HEADERMAP_FILE_FOR_PROJECT_FILES": {
                "DefaultValue": "com_apple_compilers_llvm_clang_1_0__CPP_HEADERMAP_FILE_FOR_PROJECT_FILES__DefaultValue",
                "Type": "Path",
            },
            "CPP_HEADERMAP_PRODUCT_HEADERS_VFS_FILE": {
                "DefaultValue": "com_apple_compilers_llvm_clang_1_0__CPP_HEADERMAP_PRODUCT_HEADERS_VFS_FILE__DefaultValue",
                "Type": "Path",
            },
            "USE_HEADER_SYMLINKS": {
                "DefaultValue": "com_apple_compilers_llvm_clang_1_0__USE_HEADER_SYMLINKS__DefaultValue",
                "Type": "Boolean",
            },
            "CPP_HEADER_SYMLINKS_DIR": {
                "DefaultValue": "com_apple_compilers_llvm_clang_1_0__CPP_HEADER_SYMLINKS_DIR__DefaultValue",
                "Type": "Path",
            },
            "GCC_USE_GCC3_PFE_SUPPORT": {
                "DefaultValue": "com_apple_compilers_llvm_clang_1_0__GCC_USE_GCC3_PFE_SUPPORT__DefaultValue",
                "Type": "Boolean",
            },
            "GCC_PFE_FILE_C_DIALECTS": {
                "DefaultValue": "com_apple_compilers_llvm_clang_1_0__GCC_PFE_FILE_C_DIALECTS__DefaultValue",
                "Type": "StringList",
            },
            "ENABLE_APPLE_KEXT_CODE_GENERATION": {
                "CommandLineArgs": {"NO": [], "YES": ["-fapple-kext"]},
                "DefaultValue": "com_apple_compilers_llvm_clang_1_0__ENABLE_APPLE_KEXT_CODE_GENERATION__DefaultValue",
                "FileTypes": [
                    "sourcecode.cpp.cpp",
                    "sourcecode.cpp.objcpp",
                ],
                "Type": "Boolean",
            },
            "GCC_WARN_UNUSED_PARAMETER": {
                "AppearsAfter": "GCC_WARN_UNUSED_LABEL",
                "Category": "Warnings",
                "CommandLineArgs": {
                    "NO": ["-Wno-unused-parameter"],
                    "YES": ["-Wunused-parameter"],
                },
                "DefaultValue": "com_apple_compilers_llvm_clang_1_0__GCC_WARN_UNUSED_PARAMETER__DefaultValue",
                "Type": "Boolean",
            },
            "GCC_WARN_UNUSED_VARIABLE": {
                "AppearsAfter": "GCC_WARN_UNUSED_PARAMETER",
                "Category": "Warnings",
                "CommandLineArgs": {
                    "NO": ["-Wno-unused-variable"],
                    "YES": ["-Wunused-variable"],
                },
                "DefaultValue": "com_apple_compilers_llvm_clang_1_0__GCC_WARN_UNUSED_VARIABLE__DefaultValue",
                "Type": "Boolean",
            },
            "GCC_WARN_UNUSED_VALUE": {
                "AppearsAfter": "GCC_WARN_UNUSED_VARIABLE",
                "Category": "Warnings",
                "CommandLineArgs": {
                    "NO": ["-Wno-unused-value"],
                    "YES": ["-Wunused-value"],
                },
                "DefaultValue": "com_apple_compilers_llvm_clang_1_0__GCC_WARN_UNUSED_VALUE__DefaultValue",
                "Type": "Boolean",
            },
            "CLANG_WARN_XNU_TYPED_ALLOCATORS": {
                "CommandLineArgs": {
                    "DEFAULT": [],
                    "NO": ["-Wno-xnu-typed-allocators"],
                    "YES": ["-Wxnu-typed-allocators"],
                    "YES_ERROR": ["-Werror=xnu-typed-allocators"],
                },
                "DefaultValue": "com_apple_compilers_llvm_clang_1_0__CLANG_WARN_XNU_TYPED_ALLOCATORS__DefaultValue",
                "Type": "Enumeration",
                "Values": ["DEFAULT", "YES", "YES_ERROR", "NO"],
            },
            "GCC_ENABLE_EXCEPTIONS": {
                "CommandLineFlag": "-fexceptions",
                "DefaultValue": "com_apple_compilers_llvm_clang_1_0__GCC_ENABLE_EXCEPTIONS__DefaultValue",
                "Type": "Boolean",
            },
            "GCC_ENABLE_OBJC_EXCEPTIONS": {
                "Category": "LanguageObjC",
                "CommandLineArgs": {"NO": ["-fno-objc-exceptions"], "YES": []},
                "DefaultValue": "com_apple_compilers_llvm_clang_1_0__GCC_ENABLE_OBJC_EXCEPTIONS__DefaultValue",
                "FileTypes": ["sourcecode.c.objc", "sourcecode.cpp.objcpp"],
                "Type": "Boolean",
            },
            "CLANG_ENABLE_OBJC_ARC_EXCEPTIONS": {
                "Category": "LanguageObjC",
                "CommandLineArgs": {
                    "NO": [],
                    "YES": ["-fobjc-arc-exceptions"],
                },
                "DefaultValue": "com_apple_compilers_llvm_clang_1_0__CLANG_ENABLE_OBJC_ARC_EXCEPTIONS__DefaultValue",
                "FileTypes": ["sourcecode.c.objc", "sourcecode.cpp.objcpp"],
                "Type": "Boolean",
            },
            "GCC_CW_ASM_SYNTAX": {
                "Architectures": ["i386", "x86_64"],
                "Category": "Language",
                "CommandLineArgs": {"NO": [], "YES": ["-fasm-blocks"]},
                "DefaultValue": "com_apple_compilers_llvm_clang_1_0__GCC_CW_ASM_SYNTAX__DefaultValue",
                "Type": "Boolean",
            },
            "GCC_UNROLL_LOOPS": {
                "Category": "CodeGeneration",
                "CommandLineArgs": {"NO": [], "YES": ["-funroll-loops"]},
                "DefaultValue": "com_apple_compilers_llvm_clang_1_0__GCC_UNROLL_LOOPS__DefaultValue",
                "Type": "Boolean",
            },
            "GCC_FAST_MATH": {
                "Category": "CodeGeneration",
                "CommandLineArgs": {"NO": [], "YES": ["-ffast-math"]},
                "Condition": "com_apple_compilers_llvm_clang_1_0__GCC_FAST_MATH__Condition",
                "DefaultValue": "com_apple_compilers_llvm_clang_1_0__GCC_FAST_MATH__DefaultValue",
                "Type": "Boolean",
            },
            "GCC_STRICT_ALIASING": {
                "Category": "CodeGeneration",
                "CommandLineArgs": {
                    "NO": ["-fno-strict-aliasing"],
                    "YES": ["-fstrict-aliasing"],
                },
                "DefaultValue": "com_apple_compilers_llvm_clang_1_0__GCC_STRICT_ALIASING__DefaultValue",
                "Type": "Boolean",
            },
            "GCC_INSTRUMENT_PROGRAM_FLOW_ARCS": {
                "AdditionalLinkerArgs": {
                    "NO": [],
                    "YES": ["-fprofile-arcs"],
                },
                "Category": "CodeGeneration",
                "CommandLineArgs": {"NO": [], "YES": ["-fprofile-arcs"]},
                "DefaultValue": "com_apple_compilers_llvm_clang_1_0__GCC_INSTRUMENT_PROGRAM_FLOW_ARCS__DefaultValue",
                "Type": "Boolean",
            },
            "GCC_GENERATE_TEST_COVERAGE_FILES": {
                "AdditionalLinkerArgs": {
                    "NO": [],
                    "YES": ["-ftest-coverage"],
                },
                "Category": "CodeGeneration",
                "CommandLineArgs": {"NO": [], "YES": ["-ftest-coverage"]},
                "DefaultValue": "com_apple_compilers_llvm_clang_1_0__GCC_GENERATE_TEST_COVERAGE_FILES__DefaultValue",
                "Type": "Boolean",
            },
            "GCC_WARN_ALLOW_INCOMPLETE_PROTOCOL": {
                "Category": "WarningsObjC",
                "CommandLineArgs": {
                    "NO": ["-Wno-protocol"],
                    "YES": ["-Wprotocol"],
                },
                "DefaultValue": "com_apple_compilers_llvm_clang_1_0__GCC_WARN_ALLOW_INCOMPLETE_PROTOCOL__DefaultValue",
                "FileTypes": [
                    "sourcecode.c.objc",
                    "sourcecode.cpp.objcpp",
                ],
                "Type": "Boolean",
            },
            "GCC_WARN_ABOUT_DEPRECATED_FUNCTIONS": {
                "Category": "Warnings",
                "CommandLineArgs": {
                    "NO": ["-Wno-deprecated-declarations"],
                    "YES": ["-Wdeprecated-declarations"],
                },
                "DefaultValue": "com_apple_compilers_llvm_clang_1_0__GCC_WARN_ABOUT_DEPRECATED_FUNCTIONS__DefaultValue",
                "Type": "Boolean",
            },
            "GCC_WARN_ABOUT_INVALID_OFFSETOF_MACRO": {
                "Category": "WarningsCXX",
                "CommandLineArgs": {
                    "NO": ["-Wno-invalid-offsetof"],
                    "YES": ["-Winvalid-offsetof"],
                },
                "DefaultValue": "com_apple_compilers_llvm_clang_1_0__GCC_WARN_ABOUT_INVALID_OFFSETOF_MACRO__DefaultValue",
                "FileTypes": [
                    "sourcecode.cpp.cpp",
                    "sourcecode.cpp.objcpp",
                ],
                "Type": "Boolean",
            },
            "GCC_DEBUG_INFORMATION_FORMAT": {
                "CommandLineArgs": {
                    "<<otherwise>>": [],
                    "dwarf": ["-g"],
                    "dwarf-with-dsym": ["-g"],
                },
                "Condition": "com_apple_compilers_llvm_clang_1_0__GCC_DEBUG_INFORMATION_FORMAT__Condition",
                "DefaultValue": "com_apple_compilers_llvm_clang_1_0__GCC_DEBUG_INFORMATION_FORMAT__DefaultValue",
                "Type": "Enumeration",
                "Values": ["dwarf", "dwarf-with-dsym"],
            },
            "CLANG_DEBUG_INFORMATION_LEVEL": {
                "Category": "CodeGeneration",
                "CommandLineArgs": {
                    "default": [],
                    "line-tables-only": ["-gline-tables-only"],
                },
                "Condition": "com_apple_compilers_llvm_clang_1_0__CLANG_DEBUG_INFORMATION_LEVEL__Condition",
                "DefaultValue": "com_apple_compilers_llvm_clang_1_0__CLANG_DEBUG_INFORMATION_LEVEL__DefaultValue",
                "Type": "Enumeration",
                "Values": ["default", "line-tables-only"],
            },
            "GCC_ENABLE_SSE3_EXTENSIONS": {
                "Architectures": ["i386", "x86_64"],
                "CommandLineArgs": {"NO": [], "YES": []},
                "DefaultValue": "com_apple_compilers_llvm_clang_1_0__GCC_ENABLE_SSE3_EXTENSIONS__DefaultValue",
                "Description": "Specifies whether the binary uses the builtin " +
                               "functions that provide access to the SSE3 " +
                               "extensions to the IA-32 architecture.",
                "DisplayName": "Enable SSE3 Extensions",
                "Type": "Boolean",
            },
            "GCC_ENABLE_SUPPLEMENTAL_SSE3_INSTRUCTIONS": {
                "Architectures": ["i386", "x86_64"],
                "CommandLineArgs": {"NO": [], "YES": []},
                "DefaultValue": "com_apple_compilers_llvm_clang_1_0__GCC_ENABLE_SUPPLEMENTAL_SSE3_INSTRUCTIONS__DefaultValue",
                "Type": "Boolean",
            },
            "GCC_ENABLE_SSE41_EXTENSIONS": {
                "Architectures": ["i386", "x86_64"],
                "CommandLineArgs": {"NO": [], "YES": []},
                "DefaultValue": "com_apple_compilers_llvm_clang_1_0__GCC_ENABLE_SSE41_EXTENSIONS__DefaultValue",
                "Description": "Specifies whether the binary uses the builtin " +
                               "functions that provide access to the SSE4.1 " +
                               "extensions to the IA-32 architecture.",
                "DisplayName": "Enable SSE4.1 Extensions",
                "Type": "Boolean",
            },
            "GCC_ENABLE_SSE42_EXTENSIONS": {
                "Architectures": ["i386", "x86_64"],
                "CommandLineArgs": {"NO": [], "YES": []},
                "DefaultValue": "com_apple_compilers_llvm_clang_1_0__GCC_ENABLE_SSE42_EXTENSIONS__DefaultValue",
                "Description": "Specifies whether the binary uses the builtin " +
                               "functions that provide access to the SSE4.2 " +
                               "extensions to the IA-32 architecture.",
                "DisplayName": "Enable SSE4.2 Extensions",
                "Type": "Boolean",
            },
            "DEFAULT_SSE_LEVEL_3_YES": {
                "DefaultValue": "com_apple_compilers_llvm_clang_1_0__DEFAULT_SSE_LEVEL_3_YES__DefaultValue",
                "Type": "String",
            },
            "DEFAULT_SSE_LEVEL_3_NO": {
                "DefaultValue": "com_apple_compilers_llvm_clang_1_0__DEFAULT_SSE_LEVEL_3_NO__DefaultValue",
                "Type": "String",
            },
            "DEFAULT_SSE_LEVEL_3_SUPPLEMENTAL_YES": {
                "DefaultValue": "com_apple_compilers_llvm_clang_1_0__DEFAULT_SSE_LEVEL_3_SUPPLEMENTAL_YES__DefaultValue",
                "Type": "String",
            },
            "DEFAULT_SSE_LEVEL_3_SUPPLEMENTAL_NO": {
                "DefaultValue": "com_apple_compilers_llvm_clang_1_0__DEFAULT_SSE_LEVEL_3_SUPPLEMENTAL_NO__DefaultValue",
                "Type": "String",
            },
            "DEFAULT_SSE_LEVEL_4_1_YES": {
                "DefaultValue": "com_apple_compilers_llvm_clang_1_0__DEFAULT_SSE_LEVEL_4_1_YES__DefaultValue",
                "Type": "String",
            },
            "DEFAULT_SSE_LEVEL_4_1_NO": {
                "DefaultValue": "com_apple_compilers_llvm_clang_1_0__DEFAULT_SSE_LEVEL_4_1_NO__DefaultValue",
                "Type": "String",
            },
            "DEFAULT_SSE_LEVEL_4_2_YES": {
                "DefaultValue": "com_apple_compilers_llvm_clang_1_0__DEFAULT_SSE_LEVEL_4_2_YES__DefaultValue",
                "Type": "String",
            },
            "DEFAULT_SSE_LEVEL_4_2_NO": {
                "DefaultValue": "com_apple_compilers_llvm_clang_1_0__DEFAULT_SSE_LEVEL_4_2_NO__DefaultValue",
                "Type": "String",
            },
            "CLANG_X86_VECTOR_INSTRUCTIONS": {
                "Architectures": ["i386", "x86_64"],
                "AvoidMacroDefinition": "YES",
                "Category": "CodeGeneration",
                "CommandLineArgs": {
                    "<<otherwise>>": ["-m$(value)"],
                    "avx512": ["-march=skylake-avx512"],
                    "default": [],
                },
                "DefaultValue": "com_apple_compilers_llvm_clang_1_0__CLANG_X86_VECTOR_INSTRUCTIONS__DefaultValue",
                "Description": "Enables the use of extended vector " +
                               "instructions. Only used when targeting Intel " +
                               "architectures.",
                "DisplayName": "Enable Additional Vector Extensions",
                "Type": "Enumeration",
                "Values": [
                    "default",
                    "sse3",
                    "ssse3",
                    "sse4.1",
                    "sse4.2",
                    "avx",
                    "avx2",
                    "avx512",
                ],
            },
            "GCC_SYMBOLS_PRIVATE_EXTERN": {
                "AppearsAfter": "GCC_FEEDBACK_DIRECTED_OPTIMIZATION",
                "Category": "CodeGeneration",
                "CommandLineArgs": {"NO": [], "YES": ["-fvisibility=hidden"]},
                "DefaultValue": "com_apple_compilers_llvm_clang_1_0__GCC_SYMBOLS_PRIVATE_EXTERN__DefaultValue",
                "Type": "Boolean",
            },
            "GCC_INLINES_ARE_PRIVATE_EXTERN": {
                "AppearsAfter": "GCC_SYMBOLS_PRIVATE_EXTERN",
                "Category": "CodeGeneration",
                "CommandLineArgs": {
                    "NO": [],
                    "YES": ["-fvisibility-inlines-hidden"],
                },
                "DefaultValue": "com_apple_compilers_llvm_clang_1_0__GCC_INLINES_ARE_PRIVATE_EXTERN__DefaultValue",
                "Description": "When enabled, out-of-line copies of inline " +
                               "methods are declared `private extern`.",
                "DisplayName": "Inline Methods Hidden",
                "FileTypes": ["sourcecode.cpp.cpp", "sourcecode.cpp.objcpp"],
                "Type": "Boolean",
            },
            "GCC_THREADSAFE_STATICS": {
                "AppearsAfter": "GCC_INLINES_ARE_PRIVATE_EXTERN",
                "Category": "CodeGeneration",
                "CommandLineArgs": {"NO": ["-fno-threadsafe-statics"], "YES": []},
                "DefaultValue": "com_apple_compilers_llvm_clang_1_0__GCC_THREADSAFE_STATICS__DefaultValue",
                "Description": "Emits extra code to use the routines specified in the " +
                               "C++ ABI for thread-safe initialization of local " +
                               "statics. You can disable this option to reduce code " +
                               "size slightly in code that doesn't need to be " +
                               "thread-safe.",
                "DisplayName": "Statics are Thread-Safe",
                "FileTypes": ["sourcecode.cpp.cpp", "sourcecode.cpp.objcpp"],
                "Type": "Boolean",
            },
            "GCC_WARN_ABOUT_POINTER_SIGNEDNESS": {
                "AppearsAfter": "GCC_WARN_SIGN_COMPARE",
                "Category": "Warnings",
                "CommandLineArgs": {
                    "NO": ["-Wno-pointer-sign"],
                    "YES": ["-Wpointer-sign"],
                },
                "DefaultValue": "com_apple_compilers_llvm_clang_1_0__GCC_WARN_ABOUT_POINTER_SIGNEDNESS__DefaultValue",
                "Description": "Warn when pointers passed via arguments or " +
                               "assigned to a variable differ in sign.",
                "DisplayName": "Pointer Sign Comparison",
                "FileTypes": ["sourcecode.c.c", "sourcecode.c.objc"],
                "Type": "Boolean",
            },
            "GCC_WARN_ABOUT_MISSING_NEWLINE": {
                "AppearsAfter": "GCC_WARN_ABOUT_POINTER_SIGNEDNESS",
                "Category": "Warnings",
                "CommandLineArgs": {
                    "NO": ["-Wno-newline-eof"],
                    "YES": ["-Wnewline-eof"],
                },
                "DefaultValue": "com_apple_compilers_llvm_clang_1_0__GCC_WARN_ABOUT_MISSING_NEWLINE__DefaultValue",
                "Description": "Warn when a source file does not end with a " +
                               "newline.",
                "DisplayName": "Missing Newline At End Of File",
                "Type": "Boolean",
            },
            "CLANG_WARN_IMPLICIT_SIGN_CONVERSION": {
                "Category": "Warnings",
                "CommandLineArgs": {
                    "NO": ["-Wno-sign-conversion"],
                    "YES": ["-Wsign-conversion"],
                    "YES_ERROR": ["-Werror=sign-conversion"],
                },
                "DefaultValue": "com_apple_compilers_llvm_clang_1_0__CLANG_WARN_IMPLICIT_SIGN_CONVERSION__DefaultValue",
                "Type": "Enumeration",
                "Values": ["YES", "YES_ERROR", "NO"],
            },
            "GCC_WARN_64_TO_32_BIT_CONVERSION": {
                "AppearsAfter": "GCC_WARN_SIGN_COMPARE",
                "Category": "Warnings",
                "CommandLineArgs": {
                    "NO": ["-Wno-shorten-64-to-32"],
                    "YES": ["-Wshorten-64-to-32"],
                    "YES_ERROR": ["-Werror=shorten-64-to-32"],
                },
                "DefaultValue": "com_apple_compilers_llvm_clang_1_0__GCC_WARN_64_TO_32_BIT_CONVERSION__DefaultValue",
                "DisplayName": "Implicit Conversion to 32 Bit Type",
                "Type": "Enumeration",
                "Values": ["YES", "YES_ERROR", "NO"],
            },
            "CLANG_WARN_INFINITE_RECURSION": {
                "Category": "Warnings",
                "CommandLineArgs": {
                    "NO": ["-Wno-infinite-recursion"],
                    "YES": ["-Winfinite-recursion"],
                },
                "DefaultValue": "com_apple_compilers_llvm_clang_1_0__CLANG_WARN_INFINITE_RECURSION__DefaultValue",
                "Type": "Boolean",
            },
            "CLANG_WARN_SUSPICIOUS_MOVE": {
                "Category": "WarningsCXX",
                "CommandLineArgs": {"NO": ["-Wno-move"], "YES": ["-Wmove"]},
                "DefaultValue": "com_apple_compilers_llvm_clang_1_0__CLANG_WARN_SUSPICIOUS_MOVE__DefaultValue",
                "FileTypes": ["sourcecode.cpp.cpp", "sourcecode.cpp.objcpp"],
                "Type": "Boolean",
            },
            "CLANG_WARN_COMMA": {
                "Category": "Warnings",
                "CommandLineArgs": {
                    "NO": ["-Wno-comma"],
                    "YES": ["-Wcomma"],
                    "YES_ERROR": ["-Werror=comma"],
                },
                "DefaultValue": "com_apple_compilers_llvm_clang_1_0__CLANG_WARN_COMMA__DefaultValue",
                "SupportedVersionRanges": ["900.0.0"],
                "Type": "Enumeration",
                "Values": ["YES", "NO", "YES_ERROR"],
            },
            "CLANG_WARN_BLOCK_CAPTURE_AUTORELEASING": {
                "Category": "Warnings",
                "CommandLineArgs": {
                    "NO": ["-Wno-block-capture-autoreleasing"],
                    "YES": ["-Wblock-capture-autoreleasing"],
                    "YES_ERROR": ["-Werror=block-capture-autoreleasing"],
                },
                "DefaultValue": "com_apple_compilers_llvm_clang_1_0__CLANG_WARN_BLOCK_CAPTURE_AUTORELEASING__DefaultValue",
                "SupportedVersionRanges": ["900.0.0"],
                "Type": "Enumeration",
                "Values": ["YES", "NO", "YES_ERROR"],
            },
            "CLANG_WARN_STRICT_PROTOTYPES": {
                "Category": "Warnings",
                "CommandLineArgs": {
                    "NO": ["-Wno-strict-prototypes"],
                    "YES": ["-Wstrict-prototypes"],
                    "YES_ERROR": ["-Werror=strict-prototypes"],
                },
                "DefaultValue": "com_apple_compilers_llvm_clang_1_0__CLANG_WARN_STRICT_PROTOTYPES__DefaultValue",
                "SupportedVersionRanges": ["900.0.0"],
                "Type": "Enumeration",
                "Values": ["YES", "NO", "YES_ERROR"],
            },
            "CLANG_WARN_RANGE_LOOP_ANALYSIS": {
                "Category": "WarningsCXX",
                "CommandLineArgs": {
                    "NO": ["-Wno-range-loop-analysis"],
                    "YES": ["-Wrange-loop-analysis"],
                },
                "DefaultValue": "com_apple_compilers_llvm_clang_1_0__CLANG_WARN_RANGE_LOOP_ANALYSIS__DefaultValue",
                "FileTypes": ["sourcecode.cpp.cpp", "sourcecode.cpp.objcpp"],
                "Type": "Boolean",
            },
            "CLANG_WARN_SEMICOLON_BEFORE_METHOD_BODY": {
                "Category": "Warnings",
                "CommandLineArgs": {
                    "NO": ["-Wno-semicolon-before-method-body"],
                    "YES": ["-Wsemicolon-before-method-body"],
                },
                "DefaultValue": "com_apple_compilers_llvm_clang_1_0__CLANG_WARN_SEMICOLON_BEFORE_METHOD_BODY__DefaultValue",
                "Type": "Boolean",
            },
            "CLANG_WARN_UNGUARDED_AVAILABILITY": {
                "Category": "Warnings",
                "CommandLineArgs": {
                    "NO": ["-Wno-unguarded-availability"],
                    "YES": [],
                    "YES_AGGRESSIVE": ["-Wunguarded-availability"],
                },
                "DefaultValue": "com_apple_compilers_llvm_clang_1_0__CLANG_WARN_UNGUARDED_AVAILABILITY__DefaultValue",
                "SupportedVersionRanges": ["900.0.0"],
                "Type": "Enumeration",
                "Values": ["YES", "YES_AGGRESSIVE", "NO"],
            },
            "GCC_OBJC_ABI_VERSION": {
                "CommandLineArgs": {
                    "": [],
                    "<<otherwise>>": ["-fobjc-abi-version=$(value)"],
                },
                "DefaultValue": "com_apple_compilers_llvm_clang_1_0__GCC_OBJC_ABI_VERSION__DefaultValue",
                "FileTypes": ["sourcecode.c.objc", "sourcecode.cpp.objcpp"],
                "Type": "Enumeration",
                "Values": ["1", "2"],
            },
            "GCC_OBJC_LEGACY_DISPATCH": {
                "CommandLineArgs": {"NO": [], "YES": ["-fobjc-legacy-dispatch"]},
                "DefaultValue": "com_apple_compilers_llvm_clang_1_0__GCC_OBJC_LEGACY_DISPATCH__DefaultValue",
                "FileTypes": ["sourcecode.c.objc", "sourcecode.cpp.objcpp"],
                "Type": "Boolean",
            },
            "CLANG_INSTRUMENT_FOR_OPTIMIZATION_PROFILING": {
                "AdditionalLinkerArgs": {
                    "NO": [],
                    "YES": ["-fprofile-instr-generate"],
                },
                "CommandLineArgs": {
                    "NO": [],
                    "YES": ["-fprofile-instr-generate"],
                },
                "DefaultValue": "com_apple_compilers_llvm_clang_1_0__CLANG_INSTRUMENT_FOR_OPTIMIZATION_PROFILING__DefaultValue",
                "Type": "Boolean",
            },
            "CLANG_OPTIMIZATION_PROFILE_FILE": {
                "Category": "CodeGeneration",
                "DefaultValue": "com_apple_compilers_llvm_clang_1_0__CLANG_OPTIMIZATION_PROFILE_FILE__DefaultValue",
                "Type": "Path",
            },
            "CLANG_USE_OPTIMIZATION_PROFILE": {
                "Category": "CodeGeneration",
                "CommandLineArgs": {
                    "NO": [],
                    "YES": ["-fprofile-instr-use=$(CLANG_OPTIMIZATION_PROFILE_FILE)"],
                },
                "Condition": "com_apple_compilers_llvm_clang_1_0__CLANG_USE_OPTIMIZATION_PROFILE__Condition",
                "DefaultValue": "com_apple_compilers_llvm_clang_1_0__CLANG_USE_OPTIMIZATION_PROFILE__DefaultValue",
                "Type": "Boolean",
            },
            "CLANG_ENABLE_CODE_COVERAGE": {
                "DefaultValue": "com_apple_compilers_llvm_clang_1_0__CLANG_ENABLE_CODE_COVERAGE__DefaultValue",
                "Type": "Boolean",
            },
            "CLANG_COVERAGE_MAPPING": {
                "CommandLineArgs": {
                    "NO": [],
                    "YES": [
                        "-fprofile-instr-generate",
                        "-fcoverage-mapping",
                    ],
                },
                "Condition": "com_apple_compilers_llvm_clang_1_0__CLANG_COVERAGE_MAPPING__Condition",
                "DefaultValue": "com_apple_compilers_llvm_clang_1_0__CLANG_COVERAGE_MAPPING__DefaultValue",
                "Type": "Boolean",
            },
            "CLANG_COVERAGE_MAPPING_LINKER_ARGS": {
                "AdditionalLinkerArgs": {
                    "NO": [],
                    "YES": ["-fprofile-instr-generate"],
                },
                "DefaultValue": "com_apple_compilers_llvm_clang_1_0__CLANG_COVERAGE_MAPPING_LINKER_ARGS__DefaultValue",
                "Type": "Boolean",
            },
            "CLANG_BITCODE_GENERATION_MODE": {
                "Architectures": [
                    "arm64",
                    "arm64e",
                    "armv7",
                    "armv7s",
                    "armv7k",
                    "arm64_32",
                ],
                "CommandLineArgs": {
                    "bitcode": ["-fembed-bitcode"],
                    "marker": ["-fembed-bitcode-marker"],
                },
                "Condition": "com_apple_compilers_llvm_clang_1_0__CLANG_BITCODE_GENERATION_MODE__Condition",
                "DefaultValue": "com_apple_compilers_llvm_clang_1_0__CLANG_BITCODE_GENERATION_MODE__DefaultValue",
                "Type": "Enumeration",
                "Values": ["none", "marker", "bitcode"],
            },
            "CLANG_ADDRESS_SANITIZER": {
                "AdditionalLinkerArgs": {"NO": [], "YES": ["-fsanitize=address"]},
                "CommandLineArgs": {"NO": [], "YES": ["-fsanitize=address"]},
                "DefaultValue": "com_apple_compilers_llvm_clang_1_0__CLANG_ADDRESS_SANITIZER__DefaultValue",
                "Type": "Boolean",
            },
            "CLANG_ADDRESS_SANITIZER_CONTAINER_OVERFLOW": {
                "Category": "ASANPolicy",
                "CommandLineArgs": {
                    "NO": ["-D_LIBCPP_HAS_NO_ASAN"],
                    "YES": [],
                },
                "Condition": "com_apple_compilers_llvm_clang_1_0__CLANG_ADDRESS_SANITIZER_CONTAINER_OVERFLOW__Condition",
                "DefaultValue": "com_apple_compilers_llvm_clang_1_0__CLANG_ADDRESS_SANITIZER_CONTAINER_OVERFLOW__DefaultValue",
                "Type": "Boolean",
            },
            "CLANG_ADDRESS_SANITIZER_USE_AFTER_SCOPE": {
                "CommandLineArgs": {
                    "NO": [],
                    "YES": ["-fsanitize-address-use-after-scope"],
                },
                "Condition": "com_apple_compilers_llvm_clang_1_0__CLANG_ADDRESS_SANITIZER_USE_AFTER_SCOPE__Condition",
                "DefaultValue": "com_apple_compilers_llvm_clang_1_0__CLANG_ADDRESS_SANITIZER_USE_AFTER_SCOPE__DefaultValue",
                "Type": "Boolean",
            },
            "CLANG_ADDRESS_SANITIZER_ALLOW_ERROR_RECOVERY": {
                "CommandLineArgs": {
                    "NO": [],
                    "YES": ["-fsanitize-recover=address"],
                },
                "Condition": "com_apple_compilers_llvm_clang_1_0__CLANG_ADDRESS_SANITIZER_ALLOW_ERROR_RECOVERY__Condition",
                "DefaultValue": "com_apple_compilers_llvm_clang_1_0__CLANG_ADDRESS_SANITIZER_ALLOW_ERROR_RECOVERY__DefaultValue",
                "Type": "Boolean",
            },
            "CLANG_LIBFUZZER": {
                "AdditionalLinkerArgs": {
                    "NO": [],
                    "YES": [
                        "-fsanitize=fuzzer",
                        "-fno-sanitize-coverage=pc-table",
                    ],
                },
                "CommandLineArgs": {
                    "NO": [],
                    "YES": [
                        "-fsanitize=fuzzer",
                        "-fno-sanitize-coverage=pc-table",
                    ],
                },
                "DefaultValue": "com_apple_compilers_llvm_clang_1_0__CLANG_LIBFUZZER__DefaultValue",
                "Type": "Boolean",
            },
            "CLANG_SANITIZER_COVERAGE": {
                "AdditionalLinkerArgs": {
                    "NO": [],
                    "YES": [
                        "-fsanitize=fuzzer-no-link",
                        "-fno-sanitize-coverage=pc-table",
                    ],
                },
                "CommandLineArgs": {
                    "NO": [],
                    "YES": [
                        "-fsanitize=fuzzer-no-link",
                        "-fno-sanitize-coverage=pc-table",
                    ],
                },
                "Condition": "com_apple_compilers_llvm_clang_1_0__CLANG_SANITIZER_COVERAGE__Condition",
                "DefaultValue": "com_apple_compilers_llvm_clang_1_0__CLANG_SANITIZER_COVERAGE__DefaultValue",
                "Type": "Boolean",
            },
            "CLANG_UNDEFINED_BEHAVIOR_SANITIZER": {
                "AdditionalLinkerArgs": {
                    "NO": [],
                    "YES": ["-fsanitize=undefined"],
                },
                "CommandLineArgs": {
                    "NO": [],
                    "YES": [
                        "-fsanitize=undefined",
                        "-fno-sanitize=enum,return,float-divide-by-zero,function,vptr",
                    ],
                },
                "DefaultValue": "com_apple_compilers_llvm_clang_1_0__CLANG_UNDEFINED_BEHAVIOR_SANITIZER__DefaultValue",
                "Type": "Boolean",
            },
            "CLANG_UNDEFINED_BEHAVIOR_SANITIZER_INTEGER": {
                "Category": "UBSANPolicy",
                "CommandLineArgs": {
                    "NO": [],
                    "YES": ["-fsanitize=integer"],
                },
                "Condition": "com_apple_compilers_llvm_clang_1_0__CLANG_UNDEFINED_BEHAVIOR_SANITIZER_INTEGER__Condition",
                "DefaultValue": "com_apple_compilers_llvm_clang_1_0__CLANG_UNDEFINED_BEHAVIOR_SANITIZER_INTEGER__DefaultValue",
                "Type": "Boolean",
            },
            "CLANG_UNDEFINED_BEHAVIOR_SANITIZER_NULLABILITY": {
                "Category": "UBSANPolicy",
                "CommandLineArgs": {
                    "NO": [],
                    "YES": ["-fsanitize=nullability"],
                },
                "Condition": "com_apple_compilers_llvm_clang_1_0__CLANG_UNDEFINED_BEHAVIOR_SANITIZER_NULLABILITY__Condition",
                "DefaultValue": "com_apple_compilers_llvm_clang_1_0__CLANG_UNDEFINED_BEHAVIOR_SANITIZER_NULLABILITY__DefaultValue",
                "Type": "Boolean",
            },
            "CLANG_UNDEFINED_BEHAVIOR_SANITIZER_TRAP_ON_SECURITY_ISSUES": {
                "CommandLineArgs": {
                    "NO": [],
                    "YES": [
                        "-fsanitize=signed-integer-overflow,unsigned-integer-overflow,implicit-conversion,bounds,pointer-overflow",
                        "-fsanitize-trap=signed-integer-overflow,unsigned-integer-overflow,implicit-conversion,bounds,pointer-overflow",
                    ],
                },
                "DefaultValue": "com_apple_compilers_llvm_clang_1_0__CLANG_UNDEFINED_BEHAVIOR_SANITIZER_TRAP_ON_SECURITY_ISSUES__DefaultValue",
                "Type": "Boolean",
            },
            "CLANG_UNDEFINED_BEHAVIOR_SANITIZER_TRAP_ON_SECURITY_ISSUES_OPT": {
                "CommandLineArgs": {
                    "NO": [],
                    "YES": [
                        "-fsanitize=object-size",
                        "-fsanitize-trap=object-size",
                    ],
                },
                "Condition": "com_apple_compilers_llvm_clang_1_0__CLANG_UNDEFINED_BEHAVIOR_SANITIZER_TRAP_ON_SECURITY_ISSUES_OPT__Condition",
                "DefaultValue": "com_apple_compilers_llvm_clang_1_0__CLANG_UNDEFINED_BEHAVIOR_SANITIZER_TRAP_ON_SECURITY_ISSUES_OPT__DefaultValue",
                "Type": "Boolean",
            },
            "CLANG_INDEX_STORE_PATH": {
                "DefaultValue": "com_apple_compilers_llvm_clang_1_0__CLANG_INDEX_STORE_PATH__DefaultValue",
                "Type": "Path",
            },
            "CLANG_INDEX_STORE_ENABLE": {
                "CommandLineArgs": {
                    "NO": [],
                    "YES": [
                        "-index-store-path",
                        "$(CLANG_INDEX_STORE_PATH)",
                    ],
                },
                "Condition": "com_apple_compilers_llvm_clang_1_0__CLANG_INDEX_STORE_ENABLE__Condition",
                "DefaultValue": "com_apple_compilers_llvm_clang_1_0__CLANG_INDEX_STORE_ENABLE__DefaultValue",
                "Type": "Boolean",
            },
            "CLANG_THREAD_SANITIZER": {
                "Architectures": ["x86_64", "x86_64h", "arm64", "arm64e"],
                "CommandLineArgs": {"NO": [], "YES": ["-fsanitize=thread"]},
                "DefaultValue": "com_apple_compilers_llvm_clang_1_0__CLANG_THREAD_SANITIZER__DefaultValue",
                "Type": "Boolean",
            },
            "CLANG_ARC_MIGRATE_PRECHECK": {
                "CommandLineArgs": {
                    "donothing": [],
                    "precheck": ["-ccc-arcmt-check"],
                },
                "DefaultValue": "com_apple_compilers_llvm_clang_1_0__CLANG_ARC_MIGRATE_PRECHECK__DefaultValue",
                "Type": "Enumeration",
                "Values": ["donothing", "precheck"],
            },
            "CLANG_ARC_MIGRATE_DIR": {"CommandLineFlag": "-ccc-arcmt-migrate", "Type": "Path"},
            "CLANG_OBJC_MIGRATE_DIR": {"CommandLineFlag": "-ccc-objcmt-migrate", "Type": "Path"},
            "CLANG_ARC_MIGRATE_EMIT_ERROR": {
                "CommandLineArgs": {
                    "NO": [],
                    "YES": ["-arcmt-migrate-emit-errors"],
                },
                "DefaultValue": "com_apple_compilers_llvm_clang_1_0__CLANG_ARC_MIGRATE_EMIT_ERROR__DefaultValue",
                "Type": "Boolean",
            },
            "CLANG_ARC_MIGRATE_REPORT_OUTPUT": {
                "CommandLineFlag": "-arcmt-migrate-report-output",
                "Type": "Path",
            },
            "CLANG_ENABLE_PREFIX_MAPPING": {
                "CommandLineArgs": {
                    "NO": [],
                    "YES": [
                        "-fdepscan-prefix-map-sdk=/^sdk",
                        "-fdepscan-prefix-map-toolchain=/^toolchain",
                        "-fdepscan-prefix-map=$(DEVELOPER_DIR)=/^xcode",
                    ],
                },
                "Condition": "com_apple_compilers_llvm_clang_1_0__CLANG_ENABLE_PREFIX_MAPPING__Condition",
                "Type": "Boolean",
            },
            "CLANG_OTHER_PREFIX_MAPPINGS": {
                "CommandLineArgs": ["-fdepscan-prefix-map=$(value)"],
                "Condition": "com_apple_compilers_llvm_clang_1_0__CLANG_OTHER_PREFIX_MAPPINGS__Condition",
                "DefaultValue": "com_apple_compilers_llvm_clang_1_0__CLANG_OTHER_PREFIX_MAPPINGS__DefaultValue",
                "Type": "StringList",
            },
        },
        "PatternsOfFlagsNotAffectingPrecomps": [
            "-v",
            "-###",
            "-H",
            "-time",
            "-save-temps",
            "-W*",
            "-w",
            "-fdiagnostics-show-note-include-stack",
            "-fmacro-backtrace-limit*",
            "-fmessage-length*",
            "-fcolor-diagnostics",
            "-fno-color-diagnostics",
            "-fvectorize",
            "-flto",
            "-fstrict-aliasing",
            "-fno-strict-aliasing",
            "-fmodules-autolink",
            "-fmodules-prune-interval*",
            "-fmodules-prune-after*",
            "-fbuild-session-timestamp*",
            "-fmodules-validate-once-per-build-session",
        ],
        "ProgressDescription": "Compiling $(CommandProgressByType) source files",
        "ProgressDescriptionForPrecompile": "Precompiling $(CommandProgressByType) prefix headers",
        "ShowInCompilerSelectionPopup": "YES",
        "SupportsHeadermaps": "Yes",
        "SupportsIsysroot": "Yes",
        "SupportsMacOSXDeploymentTarget": "Yes",
        "SupportsMacOSXMinVersionFlag": "Yes",
        "SupportsPredictiveCompilation": "No",
        "SupportsSeparateUserHeaderPaths": "Yes",
        "Type": "Compiler",
        "Vendor": "Apple",
        "Version": "9.0",
    },
    "com.apple.compilers.model.coredata": {
        "Class": "XCCompilerSpecificationDataModel",
        "CommandLine": "momc [options] $(InputFile) $(ProductResourcesDir)/",
        "CommandOutputParser": [
            ["^([^:]*):([^:]*): warning: (.*)$", "emit-warning"],
            ["^([^:]*):([^:]*): error: (.*)$", "emit-error"],
        ],
        "DeeplyStatInputDirectories": "Yes",
        "Description": "MOMC: compiler of data model .xcdatamodeld/.xcdatamodel into .momd/.mom",
        "ExecDescription": "Compile data model $(InputFileName)",
        "Identifier": "com.apple.compilers.model.coredata",
        "InputFileTypes": ["wrapper.xcdatamodeld", "wrapper.xcdatamodel"],
        "IsArchitectureNeutral": "Yes",
        "MessageCategoryInfoOptions": ["--print-diagnostic-categories", "destination", "source"],
        "Name": "Data Model Compiler (MOMC)",
        "Options": {
            "MOMC_OUTPUT_SUFFIX": {
                "DefaultValue": "com_apple_compilers_model_coredata__MOMC_OUTPUT_SUFFIX__DefaultValue",
                "Type": "String",
            },
            "MOMC_OUTPUT_SUFFIX__xcdatamodeld": {
                "DefaultValue": "com_apple_compilers_model_coredata__MOMC_OUTPUT_SUFFIX__xcdatamodeld__DefaultValue",
                "Type": "String",
            },
            "MOMC_OUTPUT_SUFFIX__xcdatamodel": {
                "DefaultValue": "com_apple_compilers_model_coredata__MOMC_OUTPUT_SUFFIX__xcdatamodel__DefaultValue",
                "Type": "String",
            },
            "DEPLOYMENT_TARGET": {
                "CommandLineFlag": "--$(PLATFORM_NAME)-deployment-target",
                "DefaultValue": "com_apple_compilers_model_coredata__DEPLOYMENT_TARGET__DefaultValue",
                "Type": "String",
            },
            "MOMC_NO_WARNINGS": {
                "Category": "Warnings",
                "CommandLineFlag": "--no-warnings",
                "DefaultValue": "com_apple_compilers_model_coredata__MOMC_NO_WARNINGS__DefaultValue",
                "Type": "Boolean",
            },
            "MOMC_NO_INVERSE_RELATIONSHIP_WARNINGS": {
                "Category": "Warnings",
                "CommandLineFlag": "--no-inverse-relationship-warnings",
                "DefaultValue": "com_apple_compilers_model_coredata__MOMC_NO_INVERSE_RELATIONSHIP_WARNINGS__DefaultValue",
                "Type": "Boolean",
            },
            "MOMC_NO_MAX_PROPERTY_COUNT_WARNINGS": {
                "Category": "Warnings",
                "CommandLineFlag": "--no-max-property-count-warnings",
                "DefaultValue": "com_apple_compilers_model_coredata__MOMC_NO_MAX_PROPERTY_COUNT_WARNINGS__DefaultValue",
                "Type": "Boolean",
            },
            "MOMC_NO_DELETE_RULE_WARNINGS": {
                "Category": "Warnings",
                "CommandLineFlag": "--no-delete-rule-warnings",
                "DefaultValue": "com_apple_compilers_model_coredata__MOMC_NO_DELETE_RULE_WARNINGS__DefaultValue",
                "Type": "Boolean",
            },
            "MOMC_SUPPRESS_INVERSE_TRANSIENT_ERROR": {
                "Category": "Warnings",
                "CommandLineFlag": "--suppress-inverse-transient-error",
                "DefaultValue": "com_apple_compilers_model_coredata__MOMC_SUPPRESS_INVERSE_TRANSIENT_ERROR__DefaultValue",
                "Type": "Boolean",
            },
            "MOMC_MODULE": {
                "CommandLineFlag": "--module",
                "DefaultValue": "com_apple_compilers_model_coredata__MOMC_MODULE__DefaultValue",
                "Type": "String",
            },
            "build_file_compiler_flags": {
                "CommandLinePrefixFlag": "",
                "DefaultValue": "com_apple_compilers_model_coredata__build_file_compiler_flags__DefaultValue",
                "Type": "StringList",
            },
        },
        "Outputs": ["$(ProductResourcesDir)/$(InputFileBase)$(MOMC_OUTPUT_SUFFIX)"],
        "ProgressDescription": "Compiling $(CommandProgressByType) data models",
        "RuleName": "DataModelCompile $(ProductResourcesDir)/ $(InputFile)",
        "SynthesizeBuildRule": "Yes",
        "Type": "Compiler",
    },
    "com.apple.compilers.model.coredatamapping": {
        "CommandLine": "mapc [options] $(InputFile) $(ProductResourcesDir)/$(InputFileBase).cdm",
        "CommandOutputParser": [
            ["^([^:]*):([^:]*)warning: (.*)$", "emit-warning"],
            ["^([^:]*):([^:]*)error: (.*)$", "emit-error"],
        ],
        "DeeplyStatInputDirectories": "Yes",
        "Description": "MAPC: compiler of mapping model files .xcmappingmodel into .cdm",
        "ExecDescription": "Compile mapping model $(InputFileName)",
        "Identifier": "com.apple.compilers.model.coredatamapping",
        "InputFileTypes": ["wrapper.xcmappingmodel"],
        "IsArchitectureNeutral": "Yes",
        "MessageCategoryInfoOptions": ["--print-diagnostic-categories", "source", "destination"],
        "Name": "Core Data Mapping Model Compiler (MAPC)",
        "Options": {
            "MAPC_NO_WARNINGS": {
                "Category": "Warnings",
                "CommandLineFlag": "--mapc-no-warnings",
                "DefaultValue": "com_apple_compilers_model_coredatamapping__MAPC_NO_WARNINGS__DefaultValue",
                "Type": "Boolean",
            },
            "DEPLOYMENT_TARGET": {
                "CommandLineFlag": "--$(PLATFORM_NAME)-deployment-target",
                "DefaultValue": "com_apple_compilers_model_coredatamapping__DEPLOYMENT_TARGET__DefaultValue",
                "Type": "String",
            },
            "build_file_compiler_flags": {
                "CommandLinePrefixFlag": "",
                "DefaultValue": "com_apple_compilers_model_coredatamapping__build_file_compiler_flags__DefaultValue",
                "Type": "StringList",
            },
            "MAPC_MODULE": {
                "CommandLineFlag": "--module",
                "DefaultValue": "com_apple_compilers_model_coredatamapping__MAPC_MODULE__DefaultValue",
                "Type": "String",
            },
        },
        "Outputs": ["$(ProductResourcesDir)/$(InputFileBase).cdm"],
        "ProgressDescription": "Compiling $(CommandProgressByType) mapping models",
        "RuleName": "MappingModelCompile $(ProductResourcesDir)/$(InputFileBase).cdm $(InputFile)",
        "SynthesizeBuildRule": "Yes",
        "Type": "Compiler",
    },
    "com.apple.pbx.linkers.ld": {
        "BinaryFormats": ["mach-o"],
        "Class": "PBXLinkerSpecificationLd",
        "CommandIdentifier": "create:$(OutputPath)",
        "CommandLine": "[exec-path] [options] [special-args] -o $(OutputPath)",
        "CommandOutputParser": "XCGccCommandOutputParser",
        "Description": "Link executable using Apple Mach-O Linker (ld)",
        "ExecDescription": "Link $(OutputFile:file)",
        "Identifier": "com.apple.pbx.linkers.ld",
        "InputFileTypes": [
            "compiled.mach-o.objfile",
            "compiled.mach-o.dylib",
            "sourcecode.text-based-dylib-definition",
            "wrapper.framework",
            "archive.ar",
        ],
        "IsAbstract": "Yes",
        "Name": "Ld",
        "Options": {
            "LD_DETERMINISTIC_MODE": {
                "CommandLineArgs": {"NO": [], "YES": ["-Xlinker", "-reproducible"]},
                "DefaultValue": "com_apple_pbx_linkers_ld__LD_DETERMINISTIC_MODE__DefaultValue",
                "SupportedVersionRanges": ["804"],
                "Type": "Boolean",
            },
            "LD_TARGET_TRIPLE_ARCHS": {
                "CommandLineArgs": [
                    "-target",
                    "$(value)-$(LLVM_TARGET_TRIPLE_VENDOR)-$(LLVM_TARGET_TRIPLE_OS_VERSION)$(LLVM_TARGET_TRIPLE_SUFFIX)",
                ],
                "DefaultValue": "com_apple_pbx_linkers_ld__LD_TARGET_TRIPLE_ARCHS__DefaultValue",
                "Type": "StringList",
            },
            "LD_TARGET_TRIPLE_VARIANTS": {
                "CommandLineFlag": "-target-variant",
                "ConditionFlavors": ["arch"],
                "Type": "StringList",
            },
            "LD_ADDITIONAL_DEPLOYMENT_TARGET_FLAGS": {
                "CommandLineArgs": "$(value)",
                "ConditionFlavors": ["arch"],
                "Type": "StringList",
            },
            "MACH_O_TYPE": {
                "Type": "Enumeration",
                "Values": [
                    {"CommandLineFlag": "", "Value": "mh_execute"},
                    {"CommandLineFlag": "-dynamiclib", "Value": "mh_dylib"},
                    {"CommandLineFlag": "-bundle", "Value": "mh_bundle"},
                    {"CommandLineFlag": "-r", "Value": "mh_object"},
                ],
            },
            "LD_OPTIMIZATION_LEVEL": {
                "CommandLinePrefixFlag": "-O",
                "DefaultValue": "com_apple_pbx_linkers_ld__LD_OPTIMIZATION_LEVEL__DefaultValue",
                "Type": "String",
            },
            "LD_SUPPRESS_WARNINGS": {
                "CommandLineFlag": "-w",
                "DefaultValue": "com_apple_pbx_linkers_ld__LD_SUPPRESS_WARNINGS__DefaultValue",
                "Type": "Boolean",
            },
            "LIBRARY_SEARCH_PATHS": {
                "CommandLinePrefixFlag": "-L",
                "FlattenRecursiveSearchPathsInValue": "Yes",
                "Type": "PathList",
            },
            "FRAMEWORK_SEARCH_PATHS": {
                "CommandLinePrefixFlag": "-F",
                "FlattenRecursiveSearchPathsInValue": "Yes",
                "Type": "PathList",
            },
            "SYSTEM_FRAMEWORK_SEARCH_PATHS": {
                "CommandLineFlag": "-iframework",
                "FlattenRecursiveSearchPathsInValue": "Yes",
                "Type": "PathList",
            },
            "PRODUCT_TYPE_LIBRARY_SEARCH_PATHS": {
                "CommandLinePrefixFlag": "-L",
                "FlattenRecursiveSearchPathsInValue": "Yes",
                "Type": "PathList",
            },
            "PRODUCT_TYPE_FRAMEWORK_SEARCH_PATHS": {
                "CommandLinePrefixFlag": "-F",
                "FlattenRecursiveSearchPathsInValue": "Yes",
                "Type": "PathList",
            },
            "__INPUT_FILE_LIST_PATH__": {
                "CommandLineFlag": "-filelist",
                "DefaultValue": "com_apple_pbx_linkers_ld____INPUT_FILE_LIST_PATH____DefaultValue",
                "IsInputDependency": "Yes",
                "Type": "Path",
            },
            "LINKER_DISPLAYS_MANGLED_NAMES": {
                "CommandLineArgs": {"NO": [], "YES": ["-Xlinker", "--no-demangle"]},
                "DefaultValue": "com_apple_pbx_linkers_ld__LINKER_DISPLAYS_MANGLED_NAMES__DefaultValue",
                "Type": "Boolean",
            },
            "INIT_ROUTINE": {"CommandLineFlag": "-init", "Type": "String"},
            "LD_EXPORT_SYMBOLS": {
                "CommandLineArgs": {"NO": ["-Xlinker", "-no_exported_symbols"], "YES": []},
                "DefaultValue": "com_apple_pbx_linkers_ld__LD_EXPORT_SYMBOLS__DefaultValue",
                "Type": "Boolean",
            },
            "EXPORTED_SYMBOLS_FILE": {
                "CommandLineFlag": "-exported_symbols_list",
                "Condition": "com_apple_pbx_linkers_ld__EXPORTED_SYMBOLS_FILE__Condition",
                "IsInputDependency": "Yes",
                "Type": "Path",
            },
            "UNEXPORTED_SYMBOLS_FILE": {
                "CommandLineFlag": "-unexported_symbols_list",
                "Condition": "com_apple_pbx_linkers_ld__UNEXPORTED_SYMBOLS_FILE__Condition",
                "IsInputDependency": "Yes",
                "Type": "Path",
            },
            "REEXPORTED_LIBRARY_NAMES": {"CommandLineArgs": ["-Xlinker", "-reexport-l$(value)"], "Type": "StringList"},
            "REEXPORTED_LIBRARY_PATHS": {
                "CommandLineArgs": ["-Xlinker", "-reexport_library", "-Xlinker", "$(value)"],
                "Type": "PathList",
            },
            "REEXPORTED_FRAMEWORK_NAMES": {
                "CommandLineArgs": [
                    "-Xlinker",
                    "-reexport_framework",
                    "-Xlinker",
                    "$(value)",
                ],
                "Type": "StringList",
            },
            "GENERATE_PROFILING_CODE": {
                "CommandLineFlag": "-pg",
                "Condition": "com_apple_pbx_linkers_ld__GENERATE_PROFILING_CODE__Condition",
                "Type": "Boolean",
            },
            "LD_NO_PIE": {
                "CommandLineArgs": {"NO": [], "YES": ["-Xlinker", "-no_pie"]},
                "DefaultValue": "com_apple_pbx_linkers_ld__LD_NO_PIE__DefaultValue",
                "Type": "Boolean",
            },
            "LD_DYLIB_INSTALL_NAME": {
                "CommandLineFlag": "-install_name",
                "Condition": "com_apple_pbx_linkers_ld__LD_DYLIB_INSTALL_NAME__Condition",
                "DefaultValue": "com_apple_pbx_linkers_ld__LD_DYLIB_INSTALL_NAME__DefaultValue",
                "Type": "Path",
            },
            "LD_RUNPATH_SEARCH_PATHS": {
                "CommandLineArgs": ["-Xlinker", "-rpath", "-Xlinker", "$(value)"],
                "DefaultValue": "com_apple_pbx_linkers_ld__LD_RUNPATH_SEARCH_PATHS__DefaultValue",
                "Type": "PathList",
            },
            "LD_GENERATE_MAP_FILE": {
                "CommandLineArgs": {
                    "NO": [],
                    "YES": [
                        "-Xlinker",
                        "-map",
                        "-Xlinker",
                        "$(LD_MAP_FILE_PATH)",
                    ],
                },
                "DefaultValue": "com_apple_pbx_linkers_ld__LD_GENERATE_MAP_FILE__DefaultValue",
                "Type": "Boolean",
            },
            "LD_MAP_FILE_PATH": {
                "DefaultValue": "com_apple_pbx_linkers_ld__LD_MAP_FILE_PATH__DefaultValue",
                "Type": "Path",
            },
            "LINK_WITH_STANDARD_LIBRARIES": {
                "CommandLineArgs": {"NO": ["-nostdlib"]},
                "DefaultValue": "com_apple_pbx_linkers_ld__LINK_WITH_STANDARD_LIBRARIES__DefaultValue",
                "Type": "Boolean",
            },
            "KEEP_PRIVATE_EXTERNS": {
                "CommandLineFlag": "-keep_private_externs",
                "DefaultValue": "com_apple_pbx_linkers_ld__KEEP_PRIVATE_EXTERNS__DefaultValue",
                "Type": "Boolean",
            },
            "DEAD_CODE_STRIPPING": {
                "CommandLineFlag": "-dead_strip",
                "Condition": "com_apple_pbx_linkers_ld__DEAD_CODE_STRIPPING__Condition",
                "DefaultValue": "com_apple_pbx_linkers_ld__DEAD_CODE_STRIPPING__DefaultValue",
                "Type": "Boolean",
            },
            "PRESERVE_DEAD_CODE_INITS_AND_TERMS": {
                "CommandLineFlag": "-no_dead_strip_inits_and_terms",
                "DefaultValue": "com_apple_pbx_linkers_ld__PRESERVE_DEAD_CODE_INITS_AND_TERMS__DefaultValue",
                "Type": "Boolean",
            },
            "BUNDLE_LOADER": {
                "CommandLineFlag": "-bundle_loader",
                "DefaultValue": "com_apple_pbx_linkers_ld__BUNDLE_LOADER__DefaultValue",
                "Type": "Path",
            },
            "ORDER_FILE": {
                "CommandLineArgs": {
                    "": [],
                    "<<otherwise>>": ["-Xlinker", "-order_file", "-Xlinker", "$(value)"],
                },
                "DefaultValue": "com_apple_pbx_linkers_ld__ORDER_FILE__DefaultValue",
                "Type": "Path",
            },
            "LD_LTO_OBJECT_FILE": {
                "CommandLineArgs": {
                    "": [],
                    "<<otherwise>>": [
                        "-Xlinker",
                        "-object_path_lto",
                        "-Xlinker",
                        "$(value)",
                    ],
                },
                "Condition": "com_apple_pbx_linkers_ld__LD_LTO_OBJECT_FILE__Condition",
                "DefaultValue": "com_apple_pbx_linkers_ld__LD_LTO_OBJECT_FILE__DefaultValue",
                "Type": "Path",
            },
            "LD_EXPORT_GLOBAL_SYMBOLS": {
                "CommandLineArgs": {"NO": [], "YES": ["-Xlinker", "-export_dynamic"]},
                "DefaultValue": "com_apple_pbx_linkers_ld__LD_EXPORT_GLOBAL_SYMBOLS__DefaultValue",
                "Type": "Boolean",
            },
            "LD_DONT_RUN_DEDUPLICATION": {
                "CommandLineArgs": {"NO": [], "YES": ["-Xlinker", "-no_deduplicate"]},
                "Condition": "com_apple_pbx_linkers_ld__LD_DONT_RUN_DEDUPLICATION__Condition",
                "DefaultValue": "com_apple_pbx_linkers_ld__LD_DONT_RUN_DEDUPLICATION__DefaultValue",
                "Type": "Boolean",
            },
            "LD_OBJC_ABI_VERSION": {
                "CommandLineArgs": {
                    "": [],
                    "<<otherwise>>": [
                        "-Xlinker",
                        "-objc_abi_version",
                        "-Xlinker",
                        "$(value)",
                    ],
                },
                "DefaultValue": "com_apple_pbx_linkers_ld__LD_OBJC_ABI_VERSION__DefaultValue",
                "Type": "Enumeration",
                "Values": ["1", "2"],
            },
            "LD_QUOTE_LINKER_ARGUMENTS_FOR_COMPILER_DRIVER": {
                "DefaultValue": "com_apple_pbx_linkers_ld__LD_QUOTE_LINKER_ARGUMENTS_FOR_COMPILER_DRIVER__DefaultValue",
                "Type": "Boolean",
            },
            "LD_BITCODE_GENERATION_MODE": {
                "Architectures": [
                    "arm64e",
                    "arm64",
                    "arm64_32",
                    "armv7",
                    "armv7s",
                    "armv7k",
                ],
                "CommandLineArgs": {
                    "bitcode": ["-fembed-bitcode"],
                    "marker": ["-fembed-bitcode-marker"],
                },
                "Condition": "com_apple_pbx_linkers_ld__LD_BITCODE_GENERATION_MODE__Condition",
                "DefaultValue": "com_apple_pbx_linkers_ld__LD_BITCODE_GENERATION_MODE__DefaultValue",
                "Type": "Enumeration",
                "Values": ["marker", "bitcode"],
            },
            "LD_VERIFY_BITCODE": {
                "Architectures": ["arm64e", "arm64", "arm64_32", "armv7", "armv7s", "armv7k"],
                "CommandLineArgs": {"NO": [], "YES": ["-Xlinker", "-bitcode_verify"]},
                "Condition": "com_apple_pbx_linkers_ld__LD_VERIFY_BITCODE__Condition",
                "DefaultValue": "com_apple_pbx_linkers_ld__LD_VERIFY_BITCODE__DefaultValue",
                "Type": "Boolean",
            },
            "LD_HIDE_BITCODE_SYMBOLS": {
                "Architectures": ["arm64", "arm64e", "arm64_32", "armv7", "armv7s", "armv7k"],
                "CommandLineArgs": {"NO": [], "YES": ["-Xlinker", "-bitcode_hide_symbols"]},
                "Condition": "com_apple_pbx_linkers_ld__LD_HIDE_BITCODE_SYMBOLS__Condition",
                "DefaultValue": "com_apple_pbx_linkers_ld__LD_HIDE_BITCODE_SYMBOLS__DefaultValue",
                "Type": "Boolean",
            },
            "LD_GENERATE_BITCODE_SYMBOL_MAP": {
                "Architectures": [
                    "arm64",
                    "arm64e",
                    "arm64_32",
                    "armv7",
                    "armv7s",
                    "armv7k",
                ],
                "CommandLineArgs": {
                    "NO": [],
                    "YES": [
                        "-Xlinker",
                        "-bitcode_symbol_map",
                        "-Xlinker",
                        "$(BUILT_PRODUCTS_DIR)",
                    ],
                },
                "Condition": "com_apple_pbx_linkers_ld__LD_GENERATE_BITCODE_SYMBOL_MAP__Condition",
                "DefaultValue": "com_apple_pbx_linkers_ld__LD_GENERATE_BITCODE_SYMBOL_MAP__DefaultValue",
                "Type": "Boolean",
            },
            "LD_THREAD_SANITIZER": {
                "Architectures": ["x86_64", "x86_64h", "arm64", "arm64e"],
                "CommandLineArgs": {"NO": [], "YES": ["-fsanitize=thread"]},
                "DefaultValue": "com_apple_pbx_linkers_ld__LD_THREAD_SANITIZER__DefaultValue",
                "Type": "Boolean",
            },
            "LD_DEBUG_VARIANT": {
                "CommandLineArgs": {"NO": [], "YES": ["-Xlinker", "-debug_variant"]},
                "Condition": "com_apple_pbx_linkers_ld__LD_DEBUG_VARIANT__Condition",
                "DefaultValue": "com_apple_pbx_linkers_ld__LD_DEBUG_VARIANT__DefaultValue",
                "Type": "Boolean",
            },
            "LD_FINAL_OUTPUT_FILE": {
                "CommandLineArgs": {
                    "": [],
                    "<<otherwise>>": [
                        "-Xlinker",
                        "-final_output",
                        "-Xlinker",
                        "$(value)",
                    ],
                },
                "Condition": "com_apple_pbx_linkers_ld__LD_FINAL_OUTPUT_FILE__Condition",
                "DefaultValue": "com_apple_pbx_linkers_ld__LD_FINAL_OUTPUT_FILE__DefaultValue",
                "Type": "Path",
            },
            "LD_DEPENDENCY_INFO_FILE": {
                "DefaultValue": "com_apple_pbx_linkers_ld__LD_DEPENDENCY_INFO_FILE__DefaultValue",
                "Type": "Path",
            },
            "CLANG_ARC_MIGRATE_PRECHECK": {
                "CommandLineArgs": {"donothing": [], "precheck": ["-ccc-arcmt-check"]},
                "DefaultValue": "com_apple_pbx_linkers_ld__CLANG_ARC_MIGRATE_PRECHECK__DefaultValue",
                "Type": "Enumeration",
                "Values": ["donothing", "precheck"],
            },
            "CLANG_ARC_MIGRATE_DIR": {"CommandLineFlag": "-ccc-arcmt-migrate", "Type": "Path"},
            "LD_DYLIB_ALLOWABLE_CLIENTS": {
                "CommandLineArgs": ["-Xlinker", "-allowable_client", "-Xlinker", "$(value)"],
                "DefaultValue": "com_apple_pbx_linkers_ld__LD_DYLIB_ALLOWABLE_CLIENTS__DefaultValue",
                "Type": "StringList",
            },
            "LD_MAKE_MERGEABLE": {
                "CommandLineArgs": {"NO": [], "YES": ["-Xlinker", "-make_mergeable"]},
                "DefaultValue": "com_apple_pbx_linkers_ld__LD_MAKE_MERGEABLE__DefaultValue",
                "Type": "Boolean",
            },
            "LD_ENTRY_POINT": {
                "CommandLineArgs": {"": [], "<<otherwise>>": ["-e", "$(value)"]},
                "Condition": "com_apple_pbx_linkers_ld__LD_ENTRY_POINT__Condition",
                "Type": "String",
            },
            "AdditionalCommandLineArguments": {"CommandLinePrefixFlag": "", "Type": "StringList"},
            "ALL_OTHER_LDFLAGS": {
                "CommandLinePrefixFlag": "",
                "Condition": "com_apple_pbx_linkers_ld__ALL_OTHER_LDFLAGS__Condition",
                "DefaultValue": "com_apple_pbx_linkers_ld__ALL_OTHER_LDFLAGS__DefaultValue",
                "Type": "StringList",
            },
            "OTHER_LDRFLAGS": {
                "CommandLinePrefixFlag": "",
                "Condition": "com_apple_pbx_linkers_ld__OTHER_LDRFLAGS__Condition",
                "DefaultValue": "com_apple_pbx_linkers_ld__OTHER_LDRFLAGS__DefaultValue",
                "Type": "StringList",
            },
            "ALTERNATE_LINKER": {
                "CommandLineArgs": {"": [], "<<otherwise>>": ["-fuse-ld=$(value)"]},
                "Type": "String",
            },
        },
        "Outputs": ["$(OutputPath)"],
        "ProgressDescription": "Linking",
        "RuleName": "Ld $(OutputPath) $(variant) $(arch)",
        "SupportsInputFileList": "Yes",
        "Type": "Linker",
    },
    "com.apple.xcode.tools.ibtool.compiler": {
        "Class": "XCCompilerSpecificationIbtool",
        "CommandLine": "$(IBC_EXEC) [options] [special-args] --output-format human-readable-text --compile " +
                       "$(ProductResourcesDir)/$(InputFileBase).nib $(InputFile)",
        "CommandOutputParser": [
            ["^([^:]*):([^:]*): warning: (.*)$", "emit-warning"],
            ["^([^:]*):([^:]*): error: (.*)$", "emit-error"],
            ["^([^:]*):([^:]*): note: (.*)$", "emit-notice"],
            ["^([^:]*):() error: (.*)$", "emit-error"],
            ["^([^:]*):() warning: (.*)$", "emit-warning"],
            ["^([^:]*):() note: (.*)$", "emit-notice"],
        ],
        "Description": "Compiles Interface Builder XIB files into deployable NIB files.",
        "EnvironmentVariables": {"XCODE_DEVELOPER_USR_PATH": "$(DEVELOPER_BIN_DIR)/.."},
        "ExecDescription": "Compile XIB file $(InputFileName)",
        "GeneratedInfoPlistContentFilePath": "$(XIB_COMPILER_INFOPLIST_CONTENT_FILE)",
        "GenericCommandFailedErrorString": "Command %@ failed with exit code %d. The tool may have crashed. " +
                                           "Please file a bug report at https://feedbackassistant.apple.com with " +
                                           "the above output and attach any crash logs for ibtool, ibtoold, " +
                                           "Xcode, and IBAgent created around the time of this failure. These " +
                                           "logs can be found in ~/Library/Logs/DiagnosticReports or " +
                                           "/Library/Logs/DiagnosticReports.",
        "Identifier": "com.apple.xcode.tools.ibtool.compiler",
        "InputFileGroupings": ["ib-base-region-and-strings"],
        "InputFileTypes": ["file.xib"],
        "IsArchitectureNeutral": "YES",
        "MessageCategoryInfoOptions": ["--print-diagnostic-categories"],
        "MightNotEmitAllOutputs": "YES",
        "Name": "Interface Builder XIB Compiler",
        "Options": {
            "IBC_EXEC": {
                "DefaultValue": "com_apple_xcode_tools_ibtool_compiler__IBC_EXEC__DefaultValue",
                "Type": "String",
            },
            "IBC_FLATTEN_NIBS": {
                "Category": "IBC_COMPILER_OPTIONS",
                "CommandLineArgs": {"NO": ["--flatten", "NO"], "YES": []},
                "DefaultValue": "com_apple_xcode_tools_ibtool_compiler__IBC_FLATTEN_NIBS__DefaultValue",
                "Type": "Boolean",
            },
            "IBC_ERRORS": {
                "Category": "IBC_COMPILER_OPTIONS",
                "CommandLineFlag": "--errors",
                "DefaultValue": "com_apple_xcode_tools_ibtool_compiler__IBC_ERRORS__DefaultValue",
                "Type": "Boolean",
            },
            "IBC_WARNINGS": {
                "Category": "IBC_COMPILER_OPTIONS",
                "CommandLineFlag": "--warnings",
                "DefaultValue": "com_apple_xcode_tools_ibtool_compiler__IBC_WARNINGS__DefaultValue",
                "Type": "Boolean",
            },
            "IBC_NOTICES": {
                "Category": "IBC_COMPILER_OPTIONS",
                "CommandLineFlag": "--notices",
                "DefaultValue": "com_apple_xcode_tools_ibtool_compiler__IBC_NOTICES__DefaultValue",
                "Type": "Boolean",
            },
            "IBC_OTHER_FLAGS": {
                "Category": "IBC_COMPILER_OPTIONS",
                "CommandLineFlag": "",
                "DefaultValue": "com_apple_xcode_tools_ibtool_compiler__IBC_OTHER_FLAGS__DefaultValue",
                "Type": "StringList",
            },
            "IBC_PLUGINS": {
                "CommandLineFlag": "--plugin",
                "DefaultValue": "com_apple_xcode_tools_ibtool_compiler__IBC_PLUGINS__DefaultValue",
                "Type": "StringList",
            },
            "RESOURCES_PLATFORM_NAME": {"CommandLineFlag": "--platform", "Type": "String"},
            "RESOURCES_TARGETED_DEVICE_FAMILY": {
                "CommandLineFlag": "--target-device",
                "Type": "StringList",
            },
            "IBC_REGIONS_AND_STRINGS_FILES": {
                "CommandLineFlag": "--companion-strings-file",
                "DefaultValue": "com_apple_xcode_tools_ibtool_compiler__IBC_REGIONS_AND_STRINGS_FILES__DefaultValue",
                "Type": "StringList",
            },
            "IBC_PLUGIN_SEARCH_PATHS": {
                "CommandLineFlag": "--plugin-dir",
                "DefaultValue": "com_apple_xcode_tools_ibtool_compiler__IBC_PLUGIN_SEARCH_PATHS__DefaultValue",
                "FlattenRecursiveSearchPathsInValue": "YES",
                "Type": "PathList",
            },
            "IBC_MODULE": {
                "Category": "IBC_COMPILER_OPTIONS",
                "CommandLineFlag": "--module",
                "DefaultValue": "com_apple_xcode_tools_ibtool_compiler__IBC_MODULE__DefaultValue",
                "Type": "String",
            },
            "IBC_OVERRIDING_PLUGINS_AND_FRAMEWORKS_DIR": {
                "SetValueInEnvironmentVariable": "DYLD_FRAMEWORK_PATH",
                "Type": "Path",
            },
            "build_file_compiler_flags": {
                "CommandLinePrefixFlag": "",
                "DefaultValue": "com_apple_xcode_tools_ibtool_compiler__build_file_compiler_flags__DefaultValue",
                "Type": "StringList",
            },
            "XIB_COMPILER_INFOPLIST_CONTENT_FILE": {
                "CommandLineFlag": "--output-partial-info-plist",
                "DefaultValue": "com_apple_xcode_tools_ibtool_compiler__XIB_COMPILER_INFOPLIST_CONTENT_FILE__DefaultValue",
                "Type": "Path",
            },
            "IBC_COMPILER_AUTO_ACTIVATE_CUSTOM_FONTS": {
                "Category": "IBC_COMPILER_OPTIONS",
                "CommandLineFlag": "--auto-activate-custom-fonts",
                "DefaultValue": "com_apple_xcode_tools_ibtool_compiler__IBC_COMPILER_AUTO_ACTIVATE_CUSTOM_FONTS__DefaultValue",
                "Type": "Boolean",
            },
            "IBC_COMPILER_USE_NIBKEYEDARCHIVER_FOR_MACOS": {
                "CommandLineArgs": {
                    "NO": [],
                    "YES": ["--use-nibkeyedarchiver-for-macos"],
                },
                "DefaultValue": "com_apple_xcode_tools_ibtool_compiler__IBC_COMPILER_USE_NIBKEYEDARCHIVER_FOR_MACOS__DefaultValue",
                "Type": "Boolean",
            },
            "IBC_COMPILATION_MODE_FOR_IOS": {
                "CommandLineFlag": "--compilation-mode-for-ios",
                "Type": "String",
            },
        },
        "Outputs": [
            "$(ProductResourcesDir)/$(InputFileBase).nib",
            "$(ProductResourcesDir)/$(InputFileBase)~iphone.nib",
            "$(ProductResourcesDir)/$(InputFileBase)~ipad.nib",
        ],
        "ProgressDescription": "Compiling $(CommandProgressByType) XIB files",
        "RuleName": "CompileXIB $(InputFile)",
        "SynthesizeBuildRule": "YES",
        "Type": "Compiler",
    },
    "com.apple.xcode.tools.swift.compiler": {
        "BuiltinJambaseRuleName": "ProcessSwift",
        "Class": "XCCompilerSpecificationSwift",
        "CommandOutputParser": "XCSwiftCommandOutputParser",
        "Description": "Compiles Swift source code into object files.",
        "ExecDescription": "Compile Swift source files",
        "ExecPath": "$(SWIFT_EXEC)",
        "Identifier": "com.apple.xcode.tools.swift.compiler",
        "InputFileGroupings": ["tool"],
        "InputFileTypes": ["sourcecode.swift"],
        "IsAbstract": "NO",
        "LanguageVersionDisplayNames": {
            "3.0": "Swift 3 (unsupported)",
            "4.0": "Swift 4",
            "4.2": "Swift 4.2",
            "5.0": "Swift 5",
        },
        "Name": "Swift Compiler",
        "OptionConditionFlavors": ["arch", "sdk"],
        "Options": {
            "SWIFT_EXEC": {
                "DefaultValue": "com_apple_xcode_tools_swift_compiler__SWIFT_EXEC__DefaultValue",
                "Type": "Path",
            },
            "SWIFT_LIBRARIES_ONLY": {
                "CommandLineArgs": {"NO": [], "YES": ["-parse-as-library"]},
                "DefaultValue": "com_apple_xcode_tools_swift_compiler__SWIFT_LIBRARIES_ONLY__DefaultValue",
                "Type": "Boolean",
            },
            "SWIFT_ENABLE_INCREMENTAL_COMPILATION": {
                "DefaultValue": "com_apple_xcode_tools_swift_compiler__SWIFT_ENABLE_INCREMENTAL_COMPILATION__DefaultValue",
                "Type": "Boolean",
            },
            "SWIFT_CROSS_MODULE_OPTIMIZATION": {
                "CommandLineArgs": {
                    "NO": [],
                    "YES": ["-cross-module-optimization"],
                },
                "DefaultValue": "com_apple_xcode_tools_swift_compiler__SWIFT_CROSS_MODULE_OPTIMIZATION__DefaultValue",
                "Type": "Boolean",
            },
            "SWIFT_PRECOMPILE_BRIDGING_HEADER": {
                "Category": "General",
                "CommandLineArgs": {
                    "NO": ["-disable-bridging-pch"],
                    "YES": [],
                },
                "DefaultValue": "com_apple_xcode_tools_swift_compiler__SWIFT_PRECOMPILE_BRIDGING_HEADER__DefaultValue",
                "Description": "Generate a precompiled header for the " +
                               "Objective-C bridging header, if used, in " +
                               "order to reduce overall build times.",
                "DisplayName": "Precompile Bridging Header",
                "Type": "Boolean",
            },
            "SWIFT_USE_PARALLEL_WHOLE_MODULE_OPTIMIZATION": {
                "DefaultValue": "com_apple_xcode_tools_swift_compiler__SWIFT_USE_PARALLEL_WHOLE_MODULE_OPTIMIZATION__DefaultValue",
                "Type": "Boolean",
            },
            "SWIFT_USE_PARALLEL_WMO_TARGETS": {
                "DefaultValue": "com_apple_xcode_tools_swift_compiler__SWIFT_USE_PARALLEL_WMO_TARGETS__DefaultValue",
                "Type": "Boolean",
            },
            "SWIFT_WHOLE_MODULE_OPTIMIZATION": {
                "CommandLineArgs": {
                    "NO": [],
                    "YES": "-whole-module-optimization",
                },
                "DefaultValue": "com_apple_xcode_tools_swift_compiler__SWIFT_WHOLE_MODULE_OPTIMIZATION__DefaultValue",
                "Type": "Boolean",
            },
            "SWIFT_LIBRARY_PATH": {
                "DefaultValue": "com_apple_xcode_tools_swift_compiler__SWIFT_LIBRARY_PATH__DefaultValue",
                "Type": "Path",
            },
            "SWIFT_RESOURCE_DIR": {"CommandLineFlag": "-resource-dir", "Type": "Path"},
            "SWIFT_MODULE_NAME": {
                "CommandLineArgs": ["-module-name", "$(value)"],
                "DefaultValue": "com_apple_xcode_tools_swift_compiler__SWIFT_MODULE_NAME__DefaultValue",
                "Type": "String",
            },
            "SWIFT_MODULE_ALIASES": {
                "CommandLineFlag": "-module-alias",
                "DefaultValue": "com_apple_xcode_tools_swift_compiler__SWIFT_MODULE_ALIASES__DefaultValue",
                "Type": "StringList",
            },
            "SWIFT_OBJC_BRIDGING_HEADER": {
                "Category": "General",
                "DefaultValue": "com_apple_xcode_tools_swift_compiler__SWIFT_OBJC_BRIDGING_HEADER__DefaultValue",
                "Description": "Path to the header defining the Objective-C " +
                               "interfaces to be exposed in Swift.",
                "DisplayName": "Objective-C Bridging Header",
                "Type": "String",
            },
            "SWIFT_OBJC_INTERFACE_HEADER_NAME": {
                "Category": "General",
                "DefaultValue": "com_apple_xcode_tools_swift_compiler__SWIFT_OBJC_INTERFACE_HEADER_NAME__DefaultValue",
                "Description": "Name to use for the header that is " +
                               "generated by the Swift compiler for use " +
                               "in `#import` statements in Objective-C or " +
                               "C++.",
                "DisplayName": "Generated Header Name",
                "Type": "String",
            },
            "SWIFT_INSTALL_OBJC_HEADER": {
                "Category": "General",
                "DefaultValue": "com_apple_xcode_tools_swift_compiler__SWIFT_INSTALL_OBJC_HEADER__DefaultValue",
                "Description": "For frameworks, install the C++/Objective-C " +
                               "generated header describing bridged Swift types " +
                               "into the `PUBLIC_HEADERS_FOLDER_PATH` so they " +
                               "may be accessed from Objective-C or C++ code " +
                               "using the framework. Defaults to `YES`.",
                "DisplayName": "Install Generated Header",
                "Type": "Boolean",
            },
            "SWIFT_INSTALL_MODULE": {
                "Category": "General",
                "DefaultValue": "com_apple_xcode_tools_swift_compiler__SWIFT_INSTALL_MODULE__DefaultValue",
                "Description": "For frameworks, install the Swift module so it can be " +
                               "accessed from Swift code using the framework.",
                "DisplayName": "Install Swift Module",
                "Type": "Boolean",
            },
            "SWIFT_OPTIMIZATION_LEVEL": {
                "Category": "Code Generation",
                "CommandLineArgs": {
                    "-Owholemodule": [
                        "-O",
                        "-whole-module-optimization",
                    ],
                    "<<otherwise>>": "$(value)",
                },
                "DefaultValue": "com_apple_xcode_tools_swift_compiler__SWIFT_OPTIMIZATION_LEVEL__DefaultValue",
                "DisplayName": "Optimization Level",
                "Type": "Enumeration",
                "Values": ["-Onone", "-O", "-Osize"],
            },
            "SWIFT_COMPILATION_MODE": {
                "Category": "Code Generation",
                "CommandLineArgs": {
                    "<<otherwise>>": [],
                    "wholemodule": "-whole-module-optimization",
                },
                "Condition": "com_apple_xcode_tools_swift_compiler__SWIFT_COMPILATION_MODE__Condition",
                "DefaultValue": "com_apple_xcode_tools_swift_compiler__SWIFT_COMPILATION_MODE__DefaultValue",
                "DisplayName": "Compilation Mode",
                "Type": "Enumeration",
                "Values": ["singlefile", "wholemodule"],
            },
            "SWIFT_ENABLE_BATCH_MODE": {
                "DefaultValue": "com_apple_xcode_tools_swift_compiler__SWIFT_ENABLE_BATCH_MODE__DefaultValue",
                "Type": "Boolean",
            },
            "SWIFT_DISABLE_SAFETY_CHECKS": {
                "Category": "Code Generation",
                "CommandLineFlag": "-remove-runtime-asserts",
                "DefaultValue": "com_apple_xcode_tools_swift_compiler__SWIFT_DISABLE_SAFETY_CHECKS__DefaultValue",
                "Description": "Disable runtime safety checks when optimizing.",
                "DisplayName": "Disable Safety Checks",
                "Type": "Boolean",
            },
            "SWIFT_ENFORCE_EXCLUSIVE_ACCESS": {
                "Category": "Code Generation",
                "CommandLineArgs": {
                    "<<otherwise>>": "-enforce-exclusivity=$(value)",
                    "compile-time": "-enforce-exclusivity=unchecked",
                    "debug-only": [],
                    "full": [],
                    "none": "-enforce-exclusivity=none",
                    "off": "-enforce-exclusivity=unchecked",
                    "on": "-enforce-exclusivity=checked",
                },
                "DefaultValue": "com_apple_xcode_tools_swift_compiler__SWIFT_ENFORCE_EXCLUSIVE_ACCESS__DefaultValue",
                "Description": "Enforce exclusive access at run-time.",
                "DisplayName": "Exclusive Access to Memory",
                "Type": "Enumeration",
                "Values": ["on", "debug-only", "off"],
            },
            "__SWIFT_ENFORCE_EXCLUSIVE_ACCESS_DEBUG_ENFORCEMENT_RELEASE": {
                "CommandLineArgs": {
                    "NO": [],
                    "YES": ["-enforce-exclusivity=unchecked"],
                },
                "Condition": "com_apple_xcode_tools_swift_compiler____SWIFT_ENFORCE_EXCLUSIVE_ACCESS_DEBUG_ENFORCEMENT_RELEASE__Condition",
                "DefaultValue": "com_apple_xcode_tools_swift_compiler____SWIFT_ENFORCE_EXCLUSIVE_ACCESS_DEBUG_ENFORCEMENT_RELEASE__DefaultValue",
                "Type": "Boolean",
            },
            "__SWIFT_ENFORCE_EXCLUSIVE_ACCESS_DEBUG_ENFORCEMENT_DEBUG": {
                "CommandLineArgs": {
                    "NO": [],
                    "YES": ["-enforce-exclusivity=checked"],
                },
                "Condition": "com_apple_xcode_tools_swift_compiler____SWIFT_ENFORCE_EXCLUSIVE_ACCESS_DEBUG_ENFORCEMENT_DEBUG__Condition",
                "DefaultValue": "com_apple_xcode_tools_swift_compiler____SWIFT_ENFORCE_EXCLUSIVE_ACCESS_DEBUG_ENFORCEMENT_DEBUG__DefaultValue",
                "Type": "Boolean",
            },
            "SWIFT_STDLIB": {
                "DefaultValue": "com_apple_xcode_tools_swift_compiler__SWIFT_STDLIB__DefaultValue",
                "Type": "String",
            },
            "SWIFT_INCLUDE_PATHS": {
                "Category": "Search Paths",
                "Description": "A list of paths to be searched by the Swift compiler " +
                               "for additional Swift modules.",
                "DisplayName": "Import Paths",
                "FlattenRecursiveSearchPathsInValue": "Yes",
                "Type": "PathList",
            },
            "FRAMEWORK_SEARCH_PATHS": {"FlattenRecursiveSearchPathsInValue": "Yes", "Type": "PathList"},
            "SWIFT_PACKAGE_NAME": {
                "Category": "General",
                "Condition": "com_apple_xcode_tools_swift_compiler__SWIFT_PACKAGE_NAME__Condition",
                "Description": "An identifier that allows grouping of modules with " +
                               "access to symbols with a package access modifier.",
                "DisplayName": "Package Access Identifier",
                "Type": "String",
            },
            "SWIFT_RESPONSE_FILE_PATH": {
                "CommandLineArgs": {"": [], "<<otherwise>>": "@$(value)"},
                "DefaultValue": "com_apple_xcode_tools_swift_compiler__SWIFT_RESPONSE_FILE_PATH__DefaultValue",
                "IsInputDependency": "Yes",
                "Type": "Path",
            },
            "SWIFT_ACTIVE_COMPILATION_CONDITIONS": {
                "Category": "Custom Flags",
                "CommandLineArgs": ["-D$(value)"],
                "DefaultValue": "com_apple_xcode_tools_swift_compiler__SWIFT_ACTIVE_COMPILATION_CONDITIONS__DefaultValue",
                "Description": "A list of compilation conditions to " +
                               "enable for conditional compilation " +
                               "expressions.",
                "DisplayName": "Active Compilation Conditions",
                "Type": "StringList",
            },
            "SWIFT_TOOLCHAIN_FLAGS": {"CommandLineArgs": ["$(value)"], "Type": "StringList"},
            "OTHER_SWIFT_FLAGS": {
                "Category": "Custom Flags",
                "CommandLineArgs": ["$(value)"],
                "Description": "A list of additional flags to pass to the Swift " +
                               "compiler.",
                "DisplayName": "Other Swift Flags",
                "Type": "StringList",
            },
            "SWIFT_DEPLOYMENT_TARGET": {
                "DefaultValue": "com_apple_xcode_tools_swift_compiler__SWIFT_DEPLOYMENT_TARGET__DefaultValue",
                "Type": "String",
            },
            "SWIFT_TARGET_TRIPLE": {
                "CommandLineFlag": "-target",
                "DefaultValue": "com_apple_xcode_tools_swift_compiler__SWIFT_TARGET_TRIPLE__DefaultValue",
                "Type": "String",
            },
            "SWIFT_TARGET_TRIPLE_VARIANTS": {
                "CommandLineFlag": "-target-variant",
                "ConditionFlavors": ["arch"],
                "Type": "StringList",
            },
            "SWIFT_VERSION": {
                "Basic": "YES",
                "Category": "Language",
                "DefaultValue": "com_apple_xcode_tools_swift_compiler__SWIFT_VERSION__DefaultValue",
                "Description": "The language version used to compile the target's Swift " +
                               "code.",
                "DisplayName": "Swift Language Version",
                "Type": "String",
                "UIType": "swiftversion",
            },
            "SWIFT_ENABLE_BARE_SLASH_REGEX": {
                "Category": "Language",
                "CommandLineArgs": {
                    "NO": [],
                    "YES": ["-enable-bare-slash-regex"],
                },
                "DefaultValue": "com_apple_xcode_tools_swift_compiler__SWIFT_ENABLE_BARE_SLASH_REGEX__DefaultValue",
                "Description": "Enable the use of forward slash " +
                               "regular-expression literal syntax " +
                               "(-enable-bare-slash-regex)",
                "DisplayName": "Enable Bare Slash Regex Literals",
                "Type": "Boolean",
            },
            "SWIFT_ENABLE_EMIT_CONST_VALUES": {
                "Category": "Language",
                "DefaultValue": "com_apple_xcode_tools_swift_compiler__SWIFT_ENABLE_EMIT_CONST_VALUES__DefaultValue",
                "Description": "Emit the extracted compile-time known " +
                               "values from the Swift compiler " +
                               "(-emit-const-values)",
                "DisplayName": "Emit Swift const values",
                "Type": "Boolean",
            },
            "SWIFT_EMIT_CONST_VALUE_PROTOCOLS": {
                "DefaultValue": "com_apple_xcode_tools_swift_compiler__SWIFT_EMIT_CONST_VALUE_PROTOCOLS__DefaultValue",
                "Description": "A list of protocol names whose " +
                               "conformances the Swift compiler is to " +
                               "emit compile-time-known values for.",
                "DisplayName": "Const value emission protocol list",
                "Type": "StringList",
            },
            "SWIFT_STRICT_CONCURRENCY": {
                "Category": "Language",
                "CommandLineArgs": {
                    "<<otherwise>>": ["-strict-concurrency=$(value)"],
                    "minimal": [],
                },
                "DefaultValue": "com_apple_xcode_tools_swift_compiler__SWIFT_STRICT_CONCURRENCY__DefaultValue",
                "DisplayName": "Strict Concurrency Checking",
                "Type": "Enumeration",
                "Values": ["minimal", "targeted", "complete"],
            },
            "SWIFT_OBJC_INTEROP_MODE": {
                "Category": "Language",
                "CommandLineArgs": {
                    "objc": "",
                    "objcxx": "-cxx-interoperability-mode=default",
                },
                "DefaultValue": "com_apple_xcode_tools_swift_compiler__SWIFT_OBJC_INTEROP_MODE__DefaultValue",
                "Description": "Determines whether Swift can interoperate with C++ " +
                               "in addition to Objective-C.",
                "DisplayName": "C++ and Objective-C Interoperability",
                "Type": "Enumeration",
                "Values": ["objcxx", "objc"],
            },
            "GCC_GENERATE_DEBUGGING_SYMBOLS": {
                "CommandLineArgs": {"NO": [], "YES": ["-g"]},
                "Type": "Boolean",
            },
            "CLANG_MODULE_CACHE_PATH": {"CommandLineFlag": "-module-cache-path", "Type": "Path"},
            "SWIFT_VALIDATE_CLANG_MODULES_ONCE_PER_BUILD_SESSION": {
                "DefaultValue": "com_apple_xcode_tools_swift_compiler__SWIFT_VALIDATE_CLANG_MODULES_ONCE_PER_BUILD_SESSION__DefaultValue",
                "Type": "Boolean",
            },
            "SWIFT_SERIALIZE_DEBUGGING_OPTIONS": {
                "CommandLineArgs": {
                    "NO": [
                        "-Xfrontend",
                        "-no-serialize-debugging-options",
                    ],
                    "YES": [
                        "-Xfrontend",
                        "-serialize-debugging-options",
                    ],
                },
                "DefaultValue": "com_apple_xcode_tools_swift_compiler__SWIFT_SERIALIZE_DEBUGGING_OPTIONS__DefaultValue",
                "Type": "Boolean",
            },
            "SWIFT_ENABLE_APP_EXTENSION": {
                "AdditionalLinkerArgs": {
                    "NO": [],
                    "YES": ["-fapplication-extension"],
                },
                "CommandLineArgs": {"NO": [], "YES": ["-application-extension"]},
                "DefaultValue": "com_apple_xcode_tools_swift_compiler__SWIFT_ENABLE_APP_EXTENSION__DefaultValue",
                "Type": "Boolean",
            },
            "SWIFT_LINK_OBJC_RUNTIME": {
                "AdditionalLinkerArgs": {"NO": [], "YES": ["-fobjc-link-runtime"]},
                "CommandLineArgs": {"NO": [], "YES": []},
                "DefaultValue": "com_apple_xcode_tools_swift_compiler__SWIFT_LINK_OBJC_RUNTIME__DefaultValue",
                "Type": "Boolean",
            },
            "SWIFT_MIGRATE_CODE": {
                "CommandLineArgs": {"NO": [], "YES": ["-update-code"]},
                "Type": "Boolean",
            },
            "CLANG_COVERAGE_MAPPING": {
                "CommandLineArgs": {
                    "NO": [],
                    "YES": [
                        "-profile-coverage-mapping",
                        "-profile-generate",
                    ],
                },
                "Condition": "com_apple_xcode_tools_swift_compiler__CLANG_COVERAGE_MAPPING__Condition",
                "DefaultValue": "com_apple_xcode_tools_swift_compiler__CLANG_COVERAGE_MAPPING__DefaultValue",
                "Type": "Boolean",
            },
            "CLANG_COVERAGE_MAPPING_LINKER_ARGS": {
                "AdditionalLinkerArgs": {
                    "NO": [],
                    "YES": ["-fprofile-instr-generate"],
                },
                "DefaultValue": "com_apple_xcode_tools_swift_compiler__CLANG_COVERAGE_MAPPING_LINKER_ARGS__DefaultValue",
                "Type": "Boolean",
            },
            "SWIFT_REFLECTION_METADATA_LEVEL": {
                "Category": "General",
                "CommandLineArgs": {
                    "all": [],
                    "none": [
                        "-Xfrontend",
                        "-disable-reflection-metadata",
                    ],
                    "without-names": [
                        "-Xfrontend",
                        "-disable-reflection-names",
                    ],
                },
                "DefaultValue": "com_apple_xcode_tools_swift_compiler__SWIFT_REFLECTION_METADATA_LEVEL__DefaultValue",
                "DisplayName": "Reflection Metadata Level",
                "Type": "Enumeration",
                "Values": ["all", "without-names", "none"],
            },
            "SWIFT_BITCODE_GENERATION_MODE": {
                "Architectures": [
                    "arm64",
                    "arm64e",
                    "armv7",
                    "armv7s",
                    "armv7k",
                    "arm64_32",
                ],
                "CommandLineArgs": {
                    "bitcode": ["-embed-bitcode"],
                    "marker": ["-embed-bitcode-marker"],
                },
                "Condition": "com_apple_xcode_tools_swift_compiler__SWIFT_BITCODE_GENERATION_MODE__Condition",
                "DefaultValue": "com_apple_xcode_tools_swift_compiler__SWIFT_BITCODE_GENERATION_MODE__DefaultValue",
                "Type": "Enumeration",
                "Values": ["marker", "bitcode"],
            },
            "SWIFT_ADDRESS_SANITIZER": {
                "AdditionalLinkerArgs": {"NO": [], "YES": ["-fsanitize=address"]},
                "CommandLineArgs": {"NO": [], "YES": ["-sanitize=address"]},
                "DefaultValue": "com_apple_xcode_tools_swift_compiler__SWIFT_ADDRESS_SANITIZER__DefaultValue",
                "Type": "Boolean",
            },
            "SWIFT_ADDRESS_SANITIZER_ALLOW_ERROR_RECOVERY": {
                "CommandLineArgs": {
                    "NO": [],
                    "YES": ["-sanitize-recover=address"],
                },
                "Condition": "com_apple_xcode_tools_swift_compiler__SWIFT_ADDRESS_SANITIZER_ALLOW_ERROR_RECOVERY__Condition",
                "DefaultValue": "com_apple_xcode_tools_swift_compiler__SWIFT_ADDRESS_SANITIZER_ALLOW_ERROR_RECOVERY__DefaultValue",
                "Type": "Boolean",
            },
            "SWIFT_THREAD_SANITIZER": {
                "Architectures": ["x86_64", "x86_64h", "arm64", "arm64e"],
                "CommandLineArgs": {"NO": [], "YES": ["-sanitize=thread"]},
                "DefaultValue": "com_apple_xcode_tools_swift_compiler__SWIFT_THREAD_SANITIZER__DefaultValue",
                "Type": "Boolean",
            },
            "SWIFT_ENABLE_TESTABILITY": {
                "CommandLineArgs": {"NO": [], "YES": ["-enable-testing"]},
                "DefaultValue": "com_apple_xcode_tools_swift_compiler__SWIFT_ENABLE_TESTABILITY__DefaultValue",
                "Type": "Boolean",
            },
            "SWIFT_SUPPRESS_WARNINGS": {
                "Category": "Warnings Policies",
                "CommandLineFlag": "-suppress-warnings",
                "DefaultValue": "com_apple_xcode_tools_swift_compiler__SWIFT_SUPPRESS_WARNINGS__DefaultValue",
                "Description": "Don't emit any warnings.",
                "DisplayName": "Suppress Warnings",
                "Type": "Boolean",
            },
            "SWIFT_TREAT_WARNINGS_AS_ERRORS": {
                "Category": "Warnings Policies",
                "CommandLineArgs": {
                    "NO": [],
                    "YES": ["-warnings-as-errors"],
                },
                "DefaultValue": "com_apple_xcode_tools_swift_compiler__SWIFT_TREAT_WARNINGS_AS_ERRORS__DefaultValue",
                "Description": "Treat all warnings as errors.",
                "DisplayName": "Treat Warnings as Errors",
                "Type": "Boolean",
            },
            "SWIFT_INDEX_STORE_PATH": {
                "DefaultValue": "com_apple_xcode_tools_swift_compiler__SWIFT_INDEX_STORE_PATH__DefaultValue",
                "Type": "Path",
            },
            "SWIFT_INDEX_STORE_ENABLE": {
                "CommandLineArgs": {
                    "NO": [],
                    "YES": [
                        "-index-store-path",
                        "$(SWIFT_INDEX_STORE_PATH)",
                    ],
                },
                "Condition": "com_apple_xcode_tools_swift_compiler__SWIFT_INDEX_STORE_ENABLE__Condition",
                "DefaultValue": "com_apple_xcode_tools_swift_compiler__SWIFT_INDEX_STORE_ENABLE__DefaultValue",
                "Type": "Boolean",
            },
            "SWIFT_EMIT_MODULE_INTERFACE": {
                "DefaultValue": "com_apple_xcode_tools_swift_compiler__SWIFT_EMIT_MODULE_INTERFACE__DefaultValue",
                "Type": "Boolean",
            },
            "SWIFT_ENABLE_LIBRARY_EVOLUTION": {
                "CommandLineArgs": {
                    "NO": [],
                    "YES": ["-enable-library-evolution"],
                },
                "DefaultValue": "com_apple_xcode_tools_swift_compiler__SWIFT_ENABLE_LIBRARY_EVOLUTION__DefaultValue",
                "Type": "Boolean",
            },
            "SWIFT_ENABLE_OPAQUE_TYPE_ERASURE": {
                "CommandLineArgs": {
                    "NO": [],
                    "YES": [
                        "-Xfrontend",
                        "-enable-experimental-opaque-type-erasure",
                    ],
                },
                "Condition": "com_apple_xcode_tools_swift_compiler__SWIFT_ENABLE_OPAQUE_TYPE_ERASURE__Condition",
                "DefaultValue": "com_apple_xcode_tools_swift_compiler__SWIFT_ENABLE_OPAQUE_TYPE_ERASURE__DefaultValue",
                "Type": "Boolean",
            },
            "SWIFT_CLANG_CXX_LANGUAGE_STANDARD": {
                "CommandLineArgs": {
                    "<<otherwise>>": [],
                    "objcxx-c++17": [
                        "-Xcc",
                        "-std=$(CLANG_CXX_LANGUAGE_STANDARD)",
                    ],
                    "objcxx-c++20": [
                        "-Xcc",
                        "-std=$(CLANG_CXX_LANGUAGE_STANDARD)",
                    ],
                    "objcxx-c++23": [
                        "-Xcc",
                        "-std=c++2b",
                    ],
                    "objcxx-gnu++17": [
                        "-Xcc",
                        "-std=$(CLANG_CXX_LANGUAGE_STANDARD)",
                    ],
                    "objcxx-gnu++20": [
                        "-Xcc",
                        "-std=$(CLANG_CXX_LANGUAGE_STANDARD)",
                    ],
                    "objcxx-gnu++23": [
                        "-Xcc",
                        "-std=gnu++2b",
                    ],
                },
                "DefaultValue": "com_apple_xcode_tools_swift_compiler__SWIFT_CLANG_CXX_LANGUAGE_STANDARD__DefaultValue",
                "Type": "String",
            },
        },
        "ProgressDescription": "Compiling Swift source files",
        "ShowInCompilerSelectionPopup": "NO",
        "SupportedLanguageVersions": ["4.0", "4.2", "5.0"],
        "SupportsGenerateAssemblyFile": "YES",
        "SupportsGeneratePreprocessedFile": "NO",
        "SynthesizeBuildRule": "YES",
        "Type": "Compiler",
        "Vendor": "Apple",
        "Version": "4.0",
    },
}
