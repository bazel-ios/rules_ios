#import <XCTest/XCTest.h>
#import <BazelRunfileBridge/BazelRunfileBridge.h>

@interface EmptyTests : XCTestCase

@end

@implementation EmptyTests

- (void)testFailureEndToEnd
{
    XCTAssertNotNil(BazelRunfilePathForResource(@"build_bazel_rules_ios/tests/ios/app/TestSnapshots"));
}

@end
