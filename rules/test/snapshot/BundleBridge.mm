#import "BundleBridge.h"

@implementation NSBundle (BazelBundleBridge)

- (NSString *)bazelRunfilePathForResource:(NSString *)resource
{
    // TODO Determine:
    // Does the existing C++ code solving our problem, if so that is awesome and
    // potentially  more robust than a simple implementation that we do for
    // rules_ios which achieves the same result
    return nil;
}

@end
