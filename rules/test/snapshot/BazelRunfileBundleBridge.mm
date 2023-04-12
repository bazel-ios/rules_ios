#import "BazelRunfileBundleBridge.h"

@implementation NSBundle (BazelRunfileBundleBridge)

- (NSString *)bazelRunfilePathForResource:(NSString *)resource
{
    // TODO: confirm if Bazel runfile support will work E2E 👍
    // https://github.com/bazelbuild/bazel/blob/master/tools/cpp/runfiles/runfiles_src.h#L28
    // e.g.
    // Does the existing C++ code load it correctly, otherwise what should we
    // do?
    return nil;
}

@end
