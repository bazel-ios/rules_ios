#import "TargetConditionals.h"

#define STR(X) #X
#define DEFER(M,...) M(__VA_ARGS__)
#define CONTENTS_OF(X) DEFER(STR,X)
#define CUSTOM_ERROR(X) _Pragma(STR(GCC error(__FILE__ ":" CONTENTS_OF(__LINE__) ": " CONTENTS_OF(BAZEL_TARGET_NAME) " " X)))
#define GLUE(X,Y) X ## Y


void DEFER(GLUE, printPlatform_, BAZEL_TARGET_NAME) (void) {
    NSLog(@"PLATFORM %s VERSION %s", CONTENTS_OF(TEST_PLATFORM), CONTENTS_OF(TEST_VERSION));
}

#if TARGET_OS_OSX
#  define REAL_TARGET_PLATFORM macos
#  define REAL_TARGET_PLATFORM_macos 1
#elif TARGET_OS_IOS
#  define REAL_TARGET_PLATFORM ios
#  define REAL_TARGET_PLATFORM_ios 1
#elif TARGET_OS_TV
#  define REAL_TARGET_PLATFORM tvos
#  define REAL_TARGET_PLATFORM_tvos 1
#elif TARGET_OS_WATCH
#  define REAL_TARGET_PLATFORM watchos
#  define REAL_TARGET_PLATFORM_watchos 1
#endif

#if REAL_TARGET_PLATFORM_macos == 1
#  if TEST_PLATFORM_macos != 1
CUSTOM_ERROR("Unexpectedly compiling for macos, expected " CONTENTS_OF(TEST_PLATFORMS))
#  endif
#  if __MAC_OS_X_VERSION_MIN_REQUIRED != TEST_VERSION_macos
CUSTOM_ERROR("Wrong version, given " CONTENTS_OF(__MAC_OS_X_VERSION_MIN_REQUIRED) " expected " CONTENTS_OF(TEST_VERSION))
#  endif
#elif TEST_PLATFORM_ios
#  if TARGET_OS_IOS != 1
CUSTOM_ERROR("Expected ios as platform, given " CONTENTS_OF(REAL_TARGET_PLATFORM))
#  endif
#  if __IPHONE_OS_VERSION_MIN_REQUIRED != TEST_VERSION_ios
CUSTOM_ERROR("Wrong version, given " CONTENTS_OF(__IPHONE_OS_VERSION_MIN_REQUIRED) " expected " CONTENTS_OF(TEST_VERSION))
#  endif
#elif TEST_PLATFORM_watchos
#  if TARGET_OS_WATCH != 1
CUSTOM_ERROR("Expected watchos as platform, given " CONTENTS_OF(REAL_TARGET_PLATFORM))
#  endif
#  if __WATCH_OS_VERSION_MIN_REQUIRED != TEST_VERSION_watchos
CUSTOM_ERROR("Wrong version, given " CONTENTS_OF(__WATCH_OS_VERSION_MIN_REQUIRED) " expected " CONTENTS_OF(TEST_VERSION))
#  endif
#elif TEST_PLATFORM_tvos
#  if TARGET_OS_TV != 1
CUSTOM_ERROR("Expected tvos as platform, given " CONTENTS_OF(REAL_TARGET_PLATFORM) " ")
#  endif
#  if __TV_OS_VERSION_MIN_REQUIRED != TEST_VERSION_tvos
CUSTOM_ERROR("Wrong version, given " CONTENTS_OF(__TV_OS_VERSION_MIN_REQUIRED) " expected " CONTENTS_OF(TEST_VERSION))
#  endif
#else
CUSTOM_ERROR("Unknown target platform " CONTENTS_OF(TEST_PLATFORM) " real platform " CONTENTS_OF(REAL_TARGET_PLATFORM))
#endif

#if REAL_TARGET_PLATFORM_ios
#  import <UIKit/UIKit.h>

@interface DEFER(GLUE, FooView, BAZEL_TARGET_NAME) : UIView
@end
@implementation DEFER(GLUE, FooView, BAZEL_TARGET_NAME)
@end

#endif
