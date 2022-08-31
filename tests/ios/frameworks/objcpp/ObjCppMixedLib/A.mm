#import "A.h"
#import "B.hpp"

using namespace dummy;

@implementation A

- (instancetype)init
{
    self = [super init];
    if (self) {
        dummy::bar();
    }
    return self;
}

- (void)foo
{
}

@end
