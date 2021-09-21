@import ObjCppMixedLib;
@import ObjCLib;
@import XCTest;

@interface ObjCppMixedLibTests : XCTestCase
@end

@implementation ObjCppMixedLibTests

- (void)test_objcMixedLib
{
    A *a = [A new];
    XCTAssertNotNil(a);
    C *c = [C new];
    XCTAssertNotNil(c);
}

@end
