#import "objcswift.h"

#import <TestImports-App/TestImports-App-Swift.h>

@implementation FooFramework: NSObject

- (int)privateMethodThatReturnsTwo {
    return 2;
}

- (int)alwaysReturnOne {
    return [self returnOne];
}

@end
