//
//  IAFullscreenUnitController.h
//  IASDKCore
//
//  Created by Digital Turbine on 14/03/2017.
//  Copyright © 2022 Digital Turbine. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#import <IASDKCore/IAInterfaceBuilder.h>
#import <IASDKCore/IAUnitController.h>
#import <IASDKCore/IAUnitDelegate.h>

@protocol IAFullscreenUnitControllerBuilder <IAUnitControllerBuilderProtocol>

@required
@property (nonatomic, weak, nullable) id<IAUnitDelegate> unitDelegate;

@end

@interface IAFullscreenUnitController : IAUnitController <IAInterfaceBuilder, IAFullscreenUnitControllerBuilder>

+ (instancetype _Nullable)build:(void(^ _Nonnull)(id<IAFullscreenUnitControllerBuilder> _Nonnull builder))buildBlock;

/**
 *  @brief Presents fullscreen ad.
 *
 *  @discussion The delegate method '- (UIViewController * _Nonnull)IAParentViewControllerForAdController:(IAUnitController * _Nullable)unitController'
 * must be implemented.
 */
- (void)showAdAnimated:(BOOL)flag completion:(void (^ _Nullable)(void))completion;

/**
 *  @brief Tells whether a creative is presented.
 */
- (BOOL)isPresented;

- (void)removeAd;

@end
