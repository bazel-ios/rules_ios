//
//  IAVideoLayout.h
//  IASDKCore
//
//  Created by Digital Turbine on 05/03/2017.
//  Copyright © 2022 Digital Turbine. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

/**
 *  @typedef IAVideoLayoutControlType
 *  @brief IAVideoLayoutControlType
 */
typedef NS_ENUM(NSUInteger, IAVideoLayoutControlType) {
    IAVideoLayoutControlTypeClose = 1,
    IAVideoLayoutControlTypeAction,
    IAVideoLayoutControlTypeMute,
    IAVideoLayoutControlTypeTimer,
};

/**
 *  @typedef IAVideoClickActionType
 *  @brief IAVideoClickActionType
 */
typedef NS_ENUM(NSUInteger, IAVideoClickActionType) {
    IAVideoClickActionTypeFullscreen = 0,
    IAVideoClickActionTypeLandingPage,
	IAVideoClickActionTypeNone
};

@interface IAVideoLayout : NSObject

/**
 *  @brief Defines whether the action button (aka: CTA / "Visit Us" / VAST clickthrough) is visible in feed (native and non-fullscreen mode).
 *
 *  @discussion This is not OpenRTB Native 1.0 CTA, but VAST protocol CTA. There is also OpenRTB CTA asset in native ad unit (in case a response includes it).
 *
 * Default: <b>enabled</b>.
 *
 * If disabled, <b>will not be visible</b> in feed.
 */
@property (nonatomic, getter=isActionButtonVisibleInFeed) BOOL actionButtonIsVisibleInFeed;

/**
 *  @brief Defines whether progress bar is visible in feed (non-fullscreen mode).
 */
@property (nonatomic, getter=isProgressBarVisibleInFeed) BOOL progressBarIsVisibleInFeed;

/**
 *  @brief Progress bar progress track fill color.
 */
@property (nonatomic, strong, nonnull) UIColor *progressBarFillColor;

/**
 *  @brief Progress bar track color.
 */
@property (nonatomic, strong, nonnull) UIColor *progressBarBackColor;

/**
 *  @brief Defines click (inside video area) action, while a video has not finished playing.
 *
 *  @discussion The default action is to open fullscreen.
 */
@property (nonatomic) IAVideoClickActionType videoClickActionType;

/**
 *  @brief Defines color theme.
 *
 *  @discussion Tints text color of text based controls.
 * Tints image colour of image based controls.
 *
 * The default is nil.
 */
@property (nonatomic, strong, nullable) UIColor *themeColor;

/**
 *  @brief Defines background color theme.
 *
 *  @discussion Tints background color of text based controls.
 *
 * The default is nil.
 */
@property (nonatomic, strong, nullable) UIColor *backgroundThemeColor;

/**
 *  @brief Defines stroke color for all video controls. 
 *
 * The default is light-light gray with some alpha.
 */
@property (nonatomic, strong, nullable) UIColor *controlStrokeColor;

/**
 *  @brief Defines fill color for all video controls.
 *
 * The default is gray with some alpha.
 */
@property (nonatomic, strong, nullable) UIColor *controlFillColor;

/**
 *  @brief Defines controls placement.
 *
 *  @param topLeftControlType     Control to place in the top left corner.
 *  @param topRightControlType    Control to place in the top right corner.
 *  @param bottomLeftControlType  Control to place in the bottom left corner.
 *  @param bottomRightControlType Control to place in the bottom right corner.
 *
 *  @discussion Calling this method, all the four parameters should be passed, and all four should be distinct. Use IAVideoLayoutControlType enum to define a control.
 */
- (void)setTopLeftControlType:(IAVideoLayoutControlType)topLeftControlType
          topRightControlType:(IAVideoLayoutControlType)topRightControlType
        bottomLeftControlType:(IAVideoLayoutControlType)bottomLeftControlType
       bottomRightControlType:(IAVideoLayoutControlType)bottomRightControlType;

/**
 *  @brief Use to get UI control by control type.
 *
 *  @discussion This method should be invoked only after 'InneractiveAdLoaded:' event has been received.
 * This method should be used in order to customise font, text color, etc.
 *
 *  @param type Control type.
 *
 *  @return (UIButton *) OR (UILabel *) OR other UIView subclass instance.
 */
- (UIView * _Nullable)controlByType:(IAVideoLayoutControlType)type;

/**
 *  @brief Use to get 'skip in ...' label of interstitial ad type.
 *
 *  @discussion This method should be invoked only after 'InneractiveAdLoaded:' event has been received.
 * This method should be used in order to customise font, text color, etc.
 *
 *  @return Skip label as (UILabel *).
 */
- (UILabel * _Nullable)interstitialSkipLabel;

@end
