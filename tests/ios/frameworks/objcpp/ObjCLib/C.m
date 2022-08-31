@import ObjCppMixedLib;
#import "C.h"

@implementation C

- (instancetype)init
{
    self = [super init];
    if (self) {
        A *a = [A new];
        [a foo];
    }
    return self;
}

@end
