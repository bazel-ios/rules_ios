//
//  MiSnapImageUtilities.h
//  MiSnap
//
//  Created by Stas Tsuprenko on 10/14/2020.
//  Copyright © 2020 Mitek Systems Inc. All rights reserved.
//

#ifndef MiSnapImageUtilities_h
#define MiSnapImageUtilities_h

#import <AVFoundation/AVFoundation.h>
#import <CoreGraphics/CoreGraphics.h>
#import <UIKit/UIKit.h>

/**
 Image utilities
 */
@interface MiSnapImageUtilities : NSObject
/**
 Rotates a CGImageRef by a specified number of radians.

 @param image   Source image to rotate
 
 @param radians Rotation amount must be 0, PI/2, PI, -PI/2
 
 @return A new CGImageRef that contains the rotated image
 */
+ (CGImageRef)rotateCGImage:(CGImageRef)image byRadians:(double)radians;
/**
 Rotates a UIImage by a specified number of radians.

 @param image   Source image to rotate
 @param radians Rotation amount must be 0, PI/2, PI, -PI/2

 @return A new UIImage that contains the rotated image
 */
+ (UIImage *)rotateUIImage:(UIImage *)image byRadians:(double)radians;
/**
 Returns the sampleBuffer of an image.

 @param image Source image in 32-bit ARGB format.

 @return A CMSampleBufferRef containing the image data.
 */
+ (CMSampleBufferRef)sampleBufferFromCGImage:(CGImageRef)image;
/**
 Returns a UIImage from sampleBuffer data

 @param sampleBuffer Source data of an image
 @param deviceOrientation The UIDeviceOrientation of sampleBuffer

 @return A UIImage representing the image data
 */
+ (UIImage *)imageFromSampleBuffer:(CMSampleBufferRef)sampleBuffer withDeviceOrientation:(UIDeviceOrientation)deviceOrientation;
/**
 Returns a rotated UIImage from UIImage

 @param image Original image
 @param orientation The UIInterfaceOrientation of application

 @return A UIImage representing the image data
 */
+ (UIImage *)imageFromUIImage:(UIImage *)image withOrientation:(UIInterfaceOrientation)orientation;
/**
 Returns a UIImage from sampleBuffer data adjusted for orientation

 @param sampleBuffer Source data of an image

 @return UIImage representing the image data
 */
+ (UIImage *)imageFromSampleBuffer:(CMSampleBufferRef)sampleBuffer adjustedForOrientation:(UIInterfaceOrientation)orientation;
/**
 Returns the raw pixel buffer of an image.

 @param image Source image in 32-bit ARGB format.

 @return A CVImageBufferRef (aka CVPixelBufferRef) containing the image data.
 */
+ (CVImageBufferRef)pixelBufferFromCGImage:(CGImageRef)image;
/**
 Returns a deep copy of a pixel buffer of an image.

 @param pixelBuffer Source image in 32-bit ARGB format.

 @return A CVImageBufferRef (aka CVPixelBufferRef) containing a deep copy of a pixel buffer of an image.
 */
+ (CVPixelBufferRef)copyPixelBuffer:(CVPixelBufferRef)pixelBuffer;
/**
 Returns a deep copy of a sample buffer of an image.

 @param sampleBuffer a sample buffer to copy.

 @return A CMSampleBufferRef containing a deep copy of a sample buffer of an image.
 */
+ (CMSampleBufferRef)copySampleBuffer:(CMSampleBufferRef)sampleBuffer;

@end

#endif /* MiSnapImageUtilities */
