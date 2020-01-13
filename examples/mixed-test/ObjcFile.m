//
//  objcFile.m
//  mixed-test
//
//  Created by Oscar Bonilla on 7/23/18.
//  Copyright © 2018 Oscar Bonilla. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "ObjcFile.h"
#import "mixed_test-Swift.h"

@implementation ObjcObject

- (void) someMethod {
    NSLog(@"SomeMethod Ran");
}

- (void) someOtherMethod {
    SwiftObj *myOb = [SwiftObj new];
    NSLog(@"myOb.someProperty: %@", myOb.someProperty);
    myOb.someProperty = @"Hello World";
    NSLog(@"MyOb.someProperty: %@", myOb.someProperty);
    NSString * retString = [myOb someFunctionWithSomeArg:@"Arg"];
    NSLog(@"RetString: %@", retString);
}

@end

