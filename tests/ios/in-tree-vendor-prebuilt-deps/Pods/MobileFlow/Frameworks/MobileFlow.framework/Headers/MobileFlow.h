//
//  MobileFlow.h
//  MobileFlow
//
//  Created by Jeremy Jessup on 6/27/16.
//  Copyright © 2016 Mitek Systems. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 *  The Mobile Flow framework provides a convenient interface to the Mitek
 *  Core Vision library by abstracting the internal structures and methods
 *  required for computer vision and image detection for mobile platforms.
 *
 */
@interface MobileFlow : NSObject
/**
 *  Returns the version of the MobileFlow framework
 *
 *  @return An NSString containing the major.minor version number
 */
+ (NSString *)sdkVersion;

/**
 *  Returns the name of the MobileFlow framework
 *
 *  @return An NSString containing the name of the Mobile Flow framework
 */
+ (NSString *)sdkName;

/**
 *  Return the version of the Core Vision library that is linked into the framework.
 *
 *  @return An NSString containing the version of the Core Vision library
 */
+ (NSString *)coreVisionVersion;

/**
 *  Returns the name of the Core Vision library that is linked into the framework.
 *
 *  @return An NSString containing the name of the Core Vision library
 */
+ (NSString *)coreVisionName;

@end
