//
//  MiSnapSDKScienceResults.h
//  MiSnapSDKScience
//
//  Created by Greg Fisch on 7/23/14.
//  Copyright (c) 2014 mitek. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "MiSnapSDKScienceMrzResult.h"

/*!
 @class MiSnapSDKScienceResults
 @abstract
 MiSnapSDKScienceResults is a class that defines the IQA results from analyzing a video frame
 */
@interface MiSnapSDKScienceResults : NSObject <NSCopying>

/*!
 @abstract The IQA value detected for brightness.
 Range: [0, 1000] (1000 represents the highest possible)
 */
@property (nonatomic, assign) int brightness;

/*!
 @abstract The IQA value detected for sharpness.
 Range: [0, 1000] (1000 represents the highest possible)
 */
@property (nonatomic, assign) int sharpness;

/*!
 @abstract The IQA value detected for cornerConfidence.
 Range: [0, 1000] (1000 represents the highest possible)
 */
@property (nonatomic, assign) int cornerConfidence;

/*!
 @abstract The IQA value detected for skewAngle.
 Range: [0, 900] measured in tenths of a percent (i.e. 150 == 15%) (900 represents the highest possible)
 */
@property (nonatomic, assign) int skewAngle;

/*!
 @abstract The IQA value detected for rotationAngle.
 Range: [0, 900] measured in tenths of a percent (i.e. 150 == 15%) (900 represents the highest possible)
 */
@property (nonatomic, assign) int rotationAngle;

/*!
 @abstract The IQA value detected for areaRatio (bounding box width / bounding box height) * 100; // e.g. 2.6:1 = 260
 */
@property (nonatomic, assign) int areaRatio;

/*!
 @abstract The IQA value detected for widthRatio, the percentage of the sceen filled by the document across the widest side.
 Range: [0, 1000] measured in tenths of a percent (i.e. 650 == 65%)
 */
@property (nonatomic, assign) int widthRatio;

/*!
 @abstract The IQA value detected for minPadding, the minimum number of pixels between the screen edge and any corner of the document.
 Range: [0, 1000] (0 represents the least possible)
 */
@property (nonatomic, assign) int minPadding;

/*!
 @abstract The IQA value detected for glareConfidence.
 Range: [0, 1000] (1000 represents the highest possible confidence that there is no glare. 0 = all glare, 700 = glare covers 30% of frame, 1000 = no glare)
 */
@property (nonatomic, assign) int glareConfidence;

/*!
 @abstract The IQA value detected for MICRConfidence.
 Range: [0, 1000] (1000 represents the highest possible. 0 = no MICR, 500 = partial MICR, 1000 = MICR present)
 */
@property (nonatomic, assign) int MICRConfidence;

/*!
 @abstract The IQA value detected for MICRConfidence.
 Range: [0, 1000] (1000 represents the highest possible. 0 = no MRZ, 500 = partial MRZ, 1000 = MRZ present)
 */
@property (nonatomic, assign) int MRZConfidence;

/*!
 @abstract The IQA value detected for backgroundConfidence.
 Range: [0, 1000] (1000 represents the highest possible. 0 = very busy background, 600 = somewhat busy, 1000 = not busy)
 */
@property (nonatomic, assign) int backgroundConfidence;

/*!
 @abstract The IQA value detected for contrastConfidence.
 Range: [0, 1000] (1000 represents the highest possible. 0 = low or no contrast, 600 = some contrast, 1000 = excellent contrast)
 */
@property (nonatomic, assign) int contrastConfidence;

/*!
 @abstract The aspect ratio of an ID document
 */
@property (nonatomic, assign) int aspectRatio;

/*!
 @abstract A placeholder image that clients of this interface can set for convenience.
 */
@property (nonatomic, strong) UIImage *image;

/*!
 @abstract The size of the image analyzed.
 */
@property (nonatomic, assign) CGSize imageSize;

/*!
 @abstract The bounding box that surrounds the corners of a document.
 */
@property (nonatomic, assign) CGRect boundingBox;

/*!
 @abstract The bounding box around the largest glare spot detected.
 */
@property (nonatomic, assign) CGRect glareBoundingBox;

/*!
 @abstract The corner points of the document
 */
@property (nonatomic, strong) NSArray* cornerPoints;

/*!
 @abstract A placeholder result code that clients of this interface can set for convenience.
 */
@property (nonatomic, strong) NSString* resultCode;

/*!
@abstract MRZ result
@return the MRZ result when MobileVerifyNFC SDK is integrated; otherwise nil
*/
- (MiSnapSDKScienceMrzResult *)mrzResult;

/*!
 @abstract The corner points with the given CGPoint parameters
 @param p0 the upper left corner point
 @param p1 the upper right corner point
 @param p2 the lower right corner point
 @param p3 the lower left corner point
 */
- (void)setCornerP0:(CGPoint)p0 withP1:(CGPoint)p1 withP2:(CGPoint)p2 withP3:(CGPoint)p3;

/*!
 @abstract gets point 0 which is upper left corner
 @return the CGPoint for point 0
 */
- (CGPoint)getCornerPoint0;

/*!
 @abstract gets point 1 which is upper right corner
 @return the CGPoint for point 1
 */
- (CGPoint)getCornerPoint1;

/*!
 @abstract gets point 2 which is lower right corner
 @return the CGPoint for point 2
 */
- (CGPoint)getCornerPoint2;

/*!
 @abstract gets point 3 which is lower left corner
 @return the CGPoint for point 3
 */
- (CGPoint)getCornerPoint3;

@end




