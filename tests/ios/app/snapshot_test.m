@import XCTest;
#import <BundleBridge/BundleBridge.h>

@interface EmptyTests : XCTestCase

@end

@implementation EmptyTests

- (void)testFailureEndToEnd
{
    XCTAssertNotNil([[NSBundle mainBundle] bazelRunfilePathForResource:@"ReferenceImages"]);
}

@end
