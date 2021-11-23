//
//  MiSnapSDKAnalyzeResults.h
//  MiSnapSDKScience
//
//  Created by Steve Blake on 10/30/17.
//  Copyright © 2017 Mitek Systems. All rights reserved.
//

#import <Foundation/Foundation.h>

/*!
 MiSnapSDK IQAFailures
 */
typedef NS_ENUM(NSInteger, IQAFailures)
{
    IQAFailureGlare = 0,
    IQAFailureNotFound,
    IQAFailureContrast,
    IQAFailureBackground,
    IQAFailureRotation,
    IQAFailureSkew,
    IQAFailureFill,
    IQAFailurePadding,
    IQAFailureBrightness,
    IQAFailureMaxBrightness,
    IQAFailureSharpness,
    IQAFailureAspectRatio,
    IQAFailureNotCheckFront,
    IQAFailureNotCheckBack
};

/*!
 @class MiSnapSDKAnalyzeResults
 @abstract
 MiSnapSDKAnalyzeResults is a class that defines an interface for the results of analyzing MiSnapSDKScienceResults
 using the minimum and maximum values of the properties of the MiSnapSDKScienceParameters.
 */
@interface MiSnapSDKAnalyzeResults : NSObject

/*!
 @abstract Indicates the success of the analyer result.
 When TRUE, the result is acceptable. When FASLE, the result is not acceptable and had at least one IQAFailure
 */
@property (nonatomic) BOOL isAcceptable;

/*!
 @abstract The priority ordered NSArray the IQAFailures determined by the analyzer. The NSArray is empty when isAcceptable is TRUE.
 */
@property (nonatomic) NSArray *orderedFailures;

@end
