@import ObjcFramework;
@import XCTest;

void asm_sym2();

@interface ObjcFrameworkTest : XCTestCase
@end

@implementation ObjcFrameworkTest

- (void)test_objcFramework;
{
    XCTAssertTrue([[[FooFramework alloc] init] alwaysReturnOne]);
    asm_sym2();
}

@end
