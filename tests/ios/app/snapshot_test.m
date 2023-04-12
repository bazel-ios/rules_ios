@import XCTest;
#import <BazelRunfileBundleBridge/BazelRunfileBundleBridge.h>

@interface EmptyTests : XCTestCase

@end

@implementation EmptyTests

- (void)testFailureEndToEnd
{
    XCTAssertNil([[NSBundle mainBundle] bazelRunfilePathForResource:@"ReferenceImages"]);
}

@end
