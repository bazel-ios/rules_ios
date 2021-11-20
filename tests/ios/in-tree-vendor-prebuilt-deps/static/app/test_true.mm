@import XCTest;

@interface EmptyTestsObjCPP : XCTestCase

@end

@implementation EmptyTestsObjCPP

- (void)testTrue {
   XCTAssertTrue(YES);
}

@end
