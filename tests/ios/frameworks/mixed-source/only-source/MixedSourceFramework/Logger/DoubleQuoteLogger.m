#import "DoubleQuoteLogger.h"
#import "MixedSourceFramework-Swift.h" // The `MixedSourceFramework-Swift.h` header allows
                                       // Objective-C files from within a mixed-source framework
                                       // to consume Swift files declared in the same framework.
                                       //
                                       // Here, we add no prefix to our `-Swift.h` import

@implementation DoubleQuoteLogger

- (void)logWithMessage:(NSString *)message {
    SwiftLogger *swiftLogger = [[SwiftLogger alloc] init];
    [swiftLogger swiftLog:message];
}

@end
