//
//  IAMRAIDContentDelegate.h
//  IASDKCore
//
//  Created by Digital Turbine on 20/03/2017.
//  Copyright © 2022 Digital Turbine. All rights reserved.
//

#ifndef IAMRAIDContentDelegate_h
#define IAMRAIDContentDelegate_h

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@class IAMRAIDContentController;

@protocol IAMRAIDContentDelegate <NSObject>

@optional

/**
 *  @brief MRAID resize.
 *  @discussion Is not relevant to Interstitial.
 */
- (void)IAMRAIDContentController:(IAMRAIDContentController * _Nullable)contentController MRAIDAdWillResizeToFrame:(CGRect)frame;

/**
 *  @brief MRAID resize.
 *  @discussion Is not relevant to Interstitial.
 */
- (void)IAMRAIDContentController:(IAMRAIDContentController * _Nullable)contentController MRAIDAdDidResizeToFrame:(CGRect)frame;

/**
 *  @brief MRAID expand.
 *  @discussion Is not relevant to Interstitial.
 */
- (void)IAMRAIDContentController:(IAMRAIDContentController * _Nullable)contentController MRAIDAdWillExpandToFrame:(CGRect)frame;

/**
 *  @brief MRAID expand.
 *  @discussion Is not relevant to Interstitial.
 */
- (void)IAMRAIDContentController:(IAMRAIDContentController * _Nullable)contentController MRAIDAdDidExpandToFrame:(CGRect)frame;

/**
 *  @brief MRAID close command;
 *  @discussion If banner, it will collaps, if interstitial, it will dismiss.
 */
- (void)IAMRAIDContentControllerMRAIDAdWillCollapse:(IAMRAIDContentController * _Nullable)contentController;
- (void)IAMRAIDContentControllerMRAIDAdDidCollapse:(IAMRAIDContentController * _Nullable)contentController;

/**
 *  @brief invoked when MRAID video failed to start playing within specified timeout;
 */
- (void)IAMRAIDContentController:(IAMRAIDContentController * _Nullable)contentController videoInterruptedWithError:(NSError * _Nonnull)error;

@end

#endif /* IAMRAIDContentDelegate_h */
