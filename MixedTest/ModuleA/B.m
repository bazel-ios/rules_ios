//
//
//  Created by FEDERICO VENTRE on 12/02/2020.
//
#import <Foundation/Foundation.h>
#import "B.h"
#import "MixedTest/ModuleC-umbrella.h"

@implementation B

- (void) methodB
{
    [[[A alloc] init] doValidate];
    [[[C alloc] init] doValidate];
}

@end
