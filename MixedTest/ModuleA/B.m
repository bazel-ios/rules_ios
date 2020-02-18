//
//
//  Created by FEDERICO VENTRE on 12/02/2020.
//
#import <Foundation/Foundation.h>
#import "B.h"
#import "MixedTest/ModuleA_swift-Swift.h"
#import "ModuleC/C.h"
#import <MixedTest/ModuleD_swift-Swift.h>

@implementation B

- (void) methodB
{
    [[[A alloc] init] doValidate];
    [[[D alloc] init] doValidate];

}

@end
