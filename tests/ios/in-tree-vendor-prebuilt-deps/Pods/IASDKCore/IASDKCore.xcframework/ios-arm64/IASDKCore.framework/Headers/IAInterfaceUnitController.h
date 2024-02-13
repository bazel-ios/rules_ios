//
//  IAInterfaceUnitController.h
//  IASDKCore
//
//  Created by Digital Turbine on 14/03/2017.
//  Copyright © 2022 Digital Turbine. All rights reserved.
//

#ifndef IAInterfaceUnitController_h
#define IAInterfaceUnitController_h

#import <Foundation/Foundation.h>

@protocol IAUnitDelegate;
@class IAContentController;

@protocol IAUnitControllerBuilderProtocol <NSObject>

@required
- (void)addSupportedContentController:(IAContentController * _Nonnull)supportedContentController;

@end

@protocol IAInterfaceUnitController <IAUnitControllerBuilderProtocol>

@required

@property (nonatomic, weak, nullable) id<IAUnitDelegate> unitDelegate;

/**
 *  @brief The content controller, that is relevant to the received ad unit.
 */
@property (atomic, weak, readonly, nullable) IAContentController *activeContentController;

/**
 *  @brief Clears all internal data. After use of this method, current unit controller is no more useable until a new response of same ad unit type is received.
 */
- (void)clear;

@end

#endif /* IAInterfaceUnitController_h */
