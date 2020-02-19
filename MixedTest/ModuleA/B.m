//
//
//  Created by FEDERICO VENTRE on 12/02/2020.
//
#import <Foundation/Foundation.h>
#import "B.h"
#import "MixedTest/ModuleA_swift-Swift.h"
@import ModuleC;

@implementation B

- (void) methodB
{
    [[[A alloc] init] doValidate];
    [[[C alloc] init] methodC];
}

@end
