@import XCTest;
#import <BazelRunfileBundleBridge/BazelRunfileBundleBridge.h>

@interface EmptyTests : XCTestCase

@end

@implementation EmptyTests

- (void)testFailureEndToEnd
{
    // TODO: update for snapshots trees
    // For now, we load the actual test bundle
    XCTAssertNonNil([[NSBundle mainBundle] bazelRunfilePathForResource:@"build_bazel_rules_ios/tests/ios/app/TestSnapshots"]);
}

@end
