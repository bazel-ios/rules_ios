@import XCTest;

@interface EmptyTests : XCTestCase
@end

@implementation EmptyTests

- (void)test_empty {
    NSLog(@"empty");
    XCTFail("WTF");
    NSLog(@"empty");
}

@end
