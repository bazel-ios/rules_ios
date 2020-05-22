@import XCTest;

@interface EmptyTests : XCTestCase

@end

@implementation EmptyTests

- (void)test_infoplist_values {
    NSDictionary *expected = @{
      @"NSPhotoLibraryAddUsageDescription": @"This app requires access to the photo library.",
      @"NSPhotoLibraryUsageDescription": @"This app requires access to the photo library.",
      @"UISupportedExternalAccessoryProtocols": @[
        @"com.example.eap",
      ],
      @"Int": @1,
      @"Dict": @{
          @"A": @"a",
          @"B": @"b",
      },
    };

    NSDictionary *actual = NSBundle.mainBundle.infoDictionary;

    [expected enumerateKeysAndObjectsUsingBlock:^(NSString *key, id object, BOOL *stop){
        XCTAssertEqualObjects(object, [actual objectForKey:key], @"Expected value for %@ to be the same", key);
    }];
}

@end
