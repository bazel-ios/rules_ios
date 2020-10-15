@import ObjcFramework;
@import XCTest;

@interface ObjcFrameworkTest : XCTestCase
@end

@implementation ObjcFrameworkTest

- (void)test_objcFramework;
{
    XCTAssertTrue([[[FooFramework alloc] init] alwaysReturnOne]);
}

@end
