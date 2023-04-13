#import "BazelRunfileBridge.h"
#include "tools/cpp/runfiles/runfiles.h"
#include <string>

using namespace bazel::tools::cpp::runfiles;

NSString *BazelRunfilePathForResource(NSString *resource)
{
    // TODO: confirm if Bazel runfile support will work E2E 👍
    // Does the existing C++ code load it for us correctly, otherwise what
    // should we do?
    // TODO: add this error as a return value
    std::string error;
    auto runfiles = Runfiles::CreateForTest(&error);
    if (runfiles) {
        std::string path = runfiles->Rlocation(resource.UTF8String);
        NSString *res = [NSString stringWithUTF8String:path.c_str()];
        delete runfiles;
        return res;
    } else {
        return nil;
    }
}
