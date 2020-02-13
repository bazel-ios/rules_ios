@import XCTest;

#import <TestImports-App/Header2.h>
#import <TestImports-App/Header.h>

#import <TestImports-App/TestImports_App-Swift.h>

@interface Tests : XCTestCase

@end

@implementation Tests

- (void)testPasses {
    XCTAssertNotNil([[EmptyClass alloc] init]);
}

@end
