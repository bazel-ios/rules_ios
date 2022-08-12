#import <Foundation/Foundation.h>

// the code made by intentbuilderc generates duplicate methods (see https://developer.apple.com/forums/thread/686448)
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wduplicate-method-match"

// this mixed language target will generate Swift intent code so import the -Swift header to access it
#import "MixedIntentConsumer-Swift.h"

#pragma clang diagnostic pop

@interface ObjcLib: NSObject
@end

@implementation ObjcLib

- (void)test:(SampleIntentIntent *)intent {
    NSLog(@"%@", intent);
}

@end