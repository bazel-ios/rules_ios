//
//  IAVideoContentDelegate.h
//  IASDKCore
//
//  Created by Digital Turbine on 14/03/2017.
//  Copyright © 2022 Digital Turbine. All rights reserved.
//

#ifndef IAVideoContentDelegate_h
#define IAVideoContentDelegate_h

#import <Foundation/Foundation.h>

@class IAVideoContentController;

@protocol IAVideoContentDelegate <NSObject>

@optional

- (void)IAVideoCompleted:(IAVideoContentController * _Nullable)contentController;

- (void)IAVideoContentController:(IAVideoContentController * _Nullable)contentController videoInterruptedWithError:(NSError * _Nonnull)error;

/**
 *  @brief Use to get video duration in seconds. Is valid only if the ad is video ad.
 *
 *  @discussion This method will be invoked after a new received video will become ready to play.
 */
- (void)IAVideoContentController:(IAVideoContentController * _Nullable)contentController videoDurationUpdated:(NSTimeInterval)videoDuration;

/**
 *  @brief Video progress observer. Use to observe current video progress. Is valid only if the ad is video ad and the video is being played.
 *
 *  @discussion The callback is invoked on the main thread.
 *
 *  @param currentTime Current playback time in seconds.
 *  @param totalTime   Total video duration in seconds.
 */
- (void)IAVideoContentController:(IAVideoContentController * _Nullable)contentController videoProgressUpdatedWithCurrentTime:(NSTimeInterval)currentTime totalTime:(NSTimeInterval)totalTime;

@end

#endif /* IAVideoContentDelegate_h */
