@import XCTest;
@import a;

@interface EmptyTests : XCTestCase
@end

@implementation EmptyTests

- (void)test_infoplist_values {
    NSLog(@"%@", [AClass class]);
}


@end
