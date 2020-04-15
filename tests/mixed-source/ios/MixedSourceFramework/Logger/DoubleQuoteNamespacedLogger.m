#import "DoubleQuoteNamespacedLogger.h"
#import "MixedSourceFramework/MixedSourceFramework-Swift.h" // The `MixedSourceFramework-Swift.h` header allows
                                                            // Objective-C files from within a mixed-source framework
                                                            // to consume Swift files declared in the same framework.
                                                            //
                                                            // Here, we prefix our `-Swift.h` import with the namespace
                                                            // of the framework itself.
@implementation DoubleQuoteNamespacedLogger

- (void)logWithMessage:(NSString *)message {
    SwiftLogger *swiftLogger = [[SwiftLogger alloc] init];
    [swiftLogger swiftLog:message];
}

@end
