//
//  IAUnitController.h
//  IASDKCore
//
//  Created by Digital Turbine on 19/03/2017.
//  Copyright © 2022 Digital Turbine. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <IASDKCore/IAInterfaceUnitController.h>

/**
 *  @brief Abstract class, for service purpose. Should not be used explicitly.
 */
@interface IAUnitController : NSObject <IAInterfaceUnitController>

- (BOOL)isReady;

@end
