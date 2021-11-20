//
//  MiSnapSDKCaptureUtils.h
//  MiSnap
//
//  Created by Steve Blake on 12/9/15.
//  Copyright © 2015 mitek. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MiSnapSDKScience/MiSnapSDKScience.h>
#import "MiSnapSDKParameters.h"
#import <MiSnapSDKMibiData/MiSnapSDKMibiData.h>

@interface MiSnapSDKCaptureUtils : NSObject

- (NSString*)base64Encoding:(NSData*)input;

- (NSDictionary*)convertResultsToDictionary:(MiSnapSDKScienceResults*)scienceResults analyzeResults:(MiSnapSDKAnalyzeResults *)analyzeResults withParams:(MiSnapSDKParameters*)docCaptureParams andTorchState:(BOOL)isTorchON withOrientation:(UIInterfaceOrientation)orientation withMibiString:(NSString *)mibiString;

- (NSDictionary*)convertAnalyzeResultsToDictionary:(MiSnapSDKScienceResults*)scienceResults;

- (NSArray *)orderedWarningsStringArrayFrom:(NSArray *)orderedFailures;

- (NSString *)getPlatformString;

- (NSString *)getCornerPointsStringFrom:(MiSnapSDKScienceResults*)scienceResults;

@end
