//
//  objcHeader.h
//  mixed-test
//
//  Created by Oscar Bonilla on 7/23/18.
//  Copyright © 2018 Oscar Bonilla. All rights reserved.
//

#ifndef objcHeader_h
#define objcHeader_h

#import <Foundation/Foundation.h>

@interface ObjcObject : NSObject

@property (strong, nonatomic) id someProperty;

- (void) someMethod;

@end

#endif /* objcHeader_h */
