#import "BundleBridge.h"
#include "tools/cpp/runfiles/runfiles.h"
#include <string>

using namespace bazel::tools::cpp::runfiles;

@implementation NSBundle (BazelBundleBridge)

- (NSString *)bazelRunfilePathForResource:(NSString *)resource
{
    std::string error;

    auto runfiles = Runfiles::CreateForTest(&error);

    if (!runfiles) {
        NSLog(@"Error creating runfiles: %s", error.c_str());
        return nil;
    }

    std::string resource_path = runfiles->Rlocation(resource.UTF8String);
    if (resource_path.empty()) {
        NSLog(@"Resource not found: %@", resource);
        return nil;
    }

    return [NSString stringWithUTF8String:resource_path.c_str()];
}

@end
