#import "objcswift.h"

#import <TestImports-App/TestImports_App-Swift.h>

@implementation FooFramework: NSObject

- (int)privateMethodThatReturnsTwo {
    return 2;
}

- (int)alwaysReturnOne {
    return [self returnOne];
}

@end
