//
//  IAVideoContentController.h
//  IASDKCore
//
//  Created by Digital Turbine on 15/03/2017.
//  Copyright © 2022 Digital Turbine. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <IASDKCore/IAInterfaceBuilder.h>
#import <IASDKCore/IAContentController.h>

@class IAAdModel;
@protocol IAVideoContentDelegate;

@protocol IAVideoContentControllerBuilder <NSObject>

@required
@property (nonatomic, weak, nullable) id<IAVideoContentDelegate> videoContentDelegate;

@end

@interface IAVideoContentController : IAContentController <IAInterfaceBuilder, IAVideoContentControllerBuilder>

+ (instancetype _Nullable)build:(void(^ _Nonnull)(id<IAVideoContentControllerBuilder> _Nonnull builder))buildBlock;

@property (nonatomic, readwrite, getter=isMuted) BOOL muted;

/**
 *  @brief Manual play.
 *  @discussion Use this API only if manual control is needed, since this API disables auto play/pause.
 */
- (void)play;

/**
 *  @brief Manual pause.
 *  @discussion Use this API only if manual control is needed, since this API disables auto play/pause.
 */
- (void)pause;

@end
