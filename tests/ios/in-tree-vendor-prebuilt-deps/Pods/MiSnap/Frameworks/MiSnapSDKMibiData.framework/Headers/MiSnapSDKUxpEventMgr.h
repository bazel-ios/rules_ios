//
//  MiSnapSDKUxpEventMgr.h
//  MiSnapSDKMibiData
//
//  Created by Mitek Engineering on 3/1/13.
//  Copyright (c) 2013 Mitek Systems, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

#define UXP_ANGLE_FAILURE                       @"AF"
#define UXP_ROTATION_ANGLE_FAILURE              @"RF"
#define UXP_ANGLE_HELP                          @"AH" // Not Used
#define UXP_BRIGHTNESS_FAILURE                  @"BF"
#define UXP_MAX_BRIGHTNESS_FAILURE              @"LF"
#define UXP_BACKGROUND_FAILURE                  @"ZF"
#define UXP_CONTRAST_FAILURE                    @"XF" // change to YF
#define UXP_BRIGHTNESS_HELP                     @"BH" // Not Used
#define UXP_CANCEL                              @"C"
#define UXP_CAPTURE_TIME                        @"MT"
#define UXP_CAPTURE_MANUAL                      @"ST"
#define UXP_CAPTURE_UNSTEADY                    @"UF"
#define UXP_TOO_FAR_FAILURE                     @"TF"
#define UXP_CHECK_FRONT_FAILURE                 @"FE"
#define UXP_CHECK_BACK_FAILURE                  @"BE"
#define UXP_TOO_FAR_HELP                        @"TH" // Not Used
#define UXP_ASPECT_RATIO_FAILURE                @"ARF"
#define UXP_TOO_CLOSE_FAILURE                   @"CF"
#define UXP_TOO_CLOSE_HELP                      @"CH" // Not Used
#define UXP_GLARE_FAILURE                       @"GF"
#define UXP_CONSECUTIVE_FRAME_COUNT             @"CC"
#define UXP_FRAME_PROCESSING_CANDIDATE_STILL    @"PS"
#define UXP_FRAME_PROCESSING_CANDIDATE_VIDEO    @"PV"
#define UXP_GHOST_IMAGE_BEGINS                  @"IB"
#define UXP_GHOST_IMAGE_ENDS                    @"IE"
#define UXP_HELP_BUTTON                         @"HB"
#define UXP_CAPTURED_BRIGHTNESS                 @"BC"
#define UXP_CAPTURED_SHARPNESS                  @"SC"
#define UXP_MEASURED_ANGLE                      @"MA"
#define UXP_MEASURED_ROTATION_ANGLE             @"ML"
#define UXP_MEASURED_BRIGHTNESS                 @"MB"
#define UXP_MEASURED_GLARE                      @"MG"
#define UXP_MEASURED_CORNER_POINTS              @"MFC"
#define UXP_MEASURED_CONFIDENCE                 @"MC"
#define UXP_MEASURED_MICR_CONFIDENCE            @"MI"
#define UXP_MEASURED_BACKGROUND                 @"MZ"
#define UXP_MEASURED_CONTRAST                   @"MX" // change to MY
#define UXP_MEASURED_FAILOVER                   @"MF"
#define UXP_MEASURED_HEIGHT                     @"MH"
#define UXP_MEASURED_RECTANGLE_SIZE             @"MR"
#define UXP_MEASURED_SHARPNESS                  @"MS"
#define UXP_MEASURED_VIDEOFRAME                 @"MV"
#define UXP_MEASURED_WIDTH                      @"MW"
#define UXP_NOT_FOUND                           @"NF"
#define UXP_FLASH_AUTO_ON                       @"FO"
#define UXP_FLASH_ON                            @"FT"
#define UXP_FLASH_OFF                           @"FF"
#define UXP_SHARPNESS_FAILURE                   @"SF"
#define UXP_SHARPNESS_HELP                      @"SH" // Not Used
#define UXP_START_STILL_CAMERA                  @"SS"
#define UXP_START_VIDEO_CAMERA                  @"SA"
#define UXP_TIMEOUT_HELP_BEGIN                  @"TB"
#define UXP_TIMEOUT_HELP_END                    @"TE"
#define UXP_TOUCH_SCREEN                        @"TS"
#define UXP_CREDIT_CARD_SCAN                    @"CS"
#define UXP_ROTATED_LANDSPACE_RIGHT             @"RR"
#define UXP_ROTATED_LANDSPACE_LEFT              @"RL"
#define UXP_ROTATED_PORTRAIT                    @"RP"
#define UXP_DEVICE_LANDSPACE_RIGHT              @"DR"
#define UXP_DEVICE_LANDSPACE_LEFT               @"DL"
#define UXP_DEVICE_PORTRAIT                     @"DP"
#define UXP_DETECTED_BARCODE                    @"DB"

/*!
 @class MiSnapSDKUxpEventMgr
 @abstract
 MiSnapSDKUxpEventMgr is a class that defines methods to manage UXP Events during a capture session.
 UXP events are added and accessible via the getEvents method. As events are added the time elapsed since
 the session start is added.
 */
@interface MiSnapSDKUxpEventMgr : NSObject

/**
 *  Singleton instance
 *
 *  @return The MiSnapSDKUxpEventMgr instance.
 */
+ (instancetype)sharedInstance;

/**
 *  Destroys the singleton; useful as it resets the time
 */
+ (void)destroySharedInstance;

/*!
 @abstract Starts a new session by clearing the list and starting a timer
 */
- (void)start;

/*!
 @abstract Adds the given event with its timestamp
 @param uxpCode the UXP event to add
 @param valueStr a value to add to the event
 */
- (void)addEvent:(NSString *)uxpCode withString:(NSString *)valueStr;

/*!
 @abstract Adds the given event with its timestamp
 @param uxpCode the UXP event to add
 */
- (void)addEvent:(NSString *)uxpCode;

/*!
 @abstract Gets the events added to the session
 @return the NSArray of the added events
 */
- (NSArray *)getEvents;

@end
