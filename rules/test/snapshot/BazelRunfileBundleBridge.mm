#import "BazelRunfileBundleBridge.h"
#include "tools/cpp/runfiles/runfiles.h"
#include <string>

@implementation NSBundle (BazelRunfileBundleBridge)

using namespace bazel::tools::cpp::runfiles;


- (NSString *)bazelRunfilePathForResource:(NSString *)resource
{
    // TODO: confirm if Bazel runfile support will work E2E 👍
    // https://github.com/bazelbuild/bazel/blob/master/tools/cpp/runfiles/runfiles_src.h#L28
    // e.g.
    // Does the existing C++ code load it correctly, otherwise what should we
    // do?
    std::string error;
    auto runfiles = Runfiles::CreateForTest(&error);
    NSLog(@"Creating runfiles: %s", runfiles.c_str());
    return nil;
}

@end
