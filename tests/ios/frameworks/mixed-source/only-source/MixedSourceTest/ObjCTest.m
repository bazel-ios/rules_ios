@import MixedSourceFramework;
@import XCTest;

@interface ObjCTest : XCTestCase
@end

@implementation ObjCTest

- (void)test_protocolConformance;
{
    XCTAssertTrue([SwiftLogger conformsToProtocol:@protocol(LoggerProtocol)]);
}

@end
