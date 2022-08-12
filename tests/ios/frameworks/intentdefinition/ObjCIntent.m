#import <Foundation/Foundation.h>
#import "Intents.h" // matches the name of the intent definition file

@interface ObjcLib: NSObject
@end

@implementation ObjcLib

- (void)test:(SampleIntentIntent *)intent {
    NSLog(@"%@", intent);
}

@end