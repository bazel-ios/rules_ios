//
//  MiSnapSDKScience.h
//  MiSnapSDKScience
//
//  Created by Stas Tsuprenko on 10/27/17.
//  Copyright © 2017 Mitek Systems. All rights reserved.
//

#import <AVFoundation/AVFoundation.h>
#import "MiSnapSDKScienceParameters.h"
#import "MiSnapSDKScienceResults.h"
#import "MiSnapSDKAnalyzeResults.h"

/*!
 @class MiSnapSDKScience
 @abstract
 MiSnapSDKScience is a class that defines an interface for analyzing a video frames and the science results.
 
 @discussion
 MiSnapSDKScience is an interface for creating and initializing an instance of the Science abstraction. The instance
 can then be used to analyze a sampleBuffer to obtain MiSnapSDKScienceResults.  The MiSnapSDKScienceResults can then be
 analyzed to obtain MiSnapSDKAnalyzeResults which indicate if the image is acceptable or what the reasons for failure were.
 */
@interface MiSnapSDKScience : NSObject

/*!
 @abstract Creates an instance of MiSnapSDKScience
 @param parameters the MiSnapSDKScienceParameters to use
 @return an instance of MiSnapSDKScience that is ready to use
 */
- (instancetype)initWithParameters:(MiSnapSDKScienceParameters *)parameters;

/*!
 @abstract analyze the sampleBuffer video image and return the results
 @param sampleBuffer the video image to analyze
 @return the MiSnapSDKScienceResults from analyzing the sampleBuffer input
 */
- (MiSnapSDKScienceResults *)analyzeFrame:(CMSampleBufferRef)sampleBuffer;

/*!
 @abstract analyze the scienceResults and return the analyzer results
 @param scienceResults the results obtained from analyzeFrame
 @return the MiSnapSDKAnalyzeResults from analyzing the scienceResults input
 */
- (MiSnapSDKAnalyzeResults *)analyzeScienceResults:(MiSnapSDKScienceResults *)scienceResults;

/*!
 @abstract Interface orientation needed for performing calculations
 */
@property (nonatomic) UIInterfaceOrientation statusbarOrientation;

/*!
 @abstract provides the version of the science
 @return the string of the science version
 */
+ (NSString *)miSnapSDKScienceVersion;

@end
