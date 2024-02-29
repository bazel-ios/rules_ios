//
//  MiSnapAnalyzer.h
//  MiSnap
//
//  Created by Stas Tsuprenko on 10/14/2020.
//  Copyright © 2020 Mitek Systems Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import <MiSnap/MiSnapParameters.h>
#import <MiSnap/MiSnapResult.h>
#import <MiSnapCore/MiSnapCore.h>

/**
 Defines an interface for delegates of `MiSnapAnalyzer` to receive frame result
 */
@protocol MiSnapAnalyzerDelegate <NSObject>

@required
/**
 Delegates receive this callback only when license status is anything but valid
 */
- (void)miSnapAnalyzerLicenseStatus:(MiSnapLicenseStatus)status;
/**
 Delegates receive this callback in one of the following cases:
 - a frame passes Image Quality Analysis (IQA) check in `MiSnapModeAuto`
 - a user manually triggers image acqusition
 */
- (void)miSnapAnalyzerSuccess:(MiSnapResult *)result;
/**
 Delegates receive this callback in `MiSnapModeAuto` when a frame analysis is completed
 and it was determined that a given frame didn't pass IQA checks
 */
- (void)miSnapAnalyzerFrameResult:(MiSnapResult *)result;
/**
 Delegates receive this callback whenever a user cancels a session
 */
- (void)miSnapAnalyzerCancelled:(MiSnapResult *)result;
/**
 Delegates receive this callback whenever an exception is occured while perfroming an image analysis
 */
- (void)miSnapAnalyzerException:(NSException *)exception;

@end

/**
 Performs image analysis
 */
@interface MiSnapAnalyzer : NSObject

/**
 An object conforming to the `MiSnapAnalyzerDelegate` protocol that will receive `MiSnapResult` when it's available
 */
@property (nonatomic, weak) id <MiSnapAnalyzerDelegate> delegate;

/**
 Initializes an analyzer with parameters, delegate that will accept analysis results and interface orientation
 @return Initialized instance
 */
- (instancetype)initWithParameters:(MiSnapParameters *)parameters delegate:(id <MiSnapAnalyzerDelegate>)delegate orientation:(UIInterfaceOrientation)orientation;

/**
 Updates `MiSnapMode`
 
 In default UX called after timeout occurs in `MiSnapModeAuto` and users chooses an option to acquire an image in `MiSnapModeManual`
 */
- (void)updateMode:(MiSnapMode)mode;

/**
 Starts frame analysis or resumes it if it was suspended by calling `pause` or `pauseFor:` methods
 */
- (void)resume;

/**
 Shuts analyzer down. To continue use, the analyzer must be initialized again.
 */
- (void)shutdown;

/**
 Pauses analyzer
 
 Frames are being skipped
 
 To resume frame analysis call `resume`
 */
- (void)pause;

/**
 Pauses analyzer for a specific `MiSnapTutorialMode`
 
 Frames are being skipped
 
 To resume frame analysis call `resume`
 */
- (void)pauseFor:(MiSnapTutorialMode)tutorialMode;

/**
 Notifies the analyzer that a session is cancelled
 
 @note Should only be called when a user explicitly cancels a session.
 Call `shutdown` for a seccessful session completion.
 */
- (void)cancel;

/**
 Notifies the analyzer that a currently analyzed frame with its result should be returned
 regardless whether it passed Image Quality Analysis check or not
 */
- (void)selectCurrentFrame;

/**
 Notifies the analyzer for logging purposes that a torch was turned on
 */
- (void)turnTorchOn;

/**
 Notifies the analyzer for logging purposes that a torch was turned off
 */
- (void)turnTorchOff;

/**
 Passes sample buffer for analysis
 
 @param sampleBuffer with `kCVPixelFormatType_32BGRA` pixel format type
 */
- (void)didReceiveSampleBuffer:(CMSampleBufferRef)sampleBuffer;

/**
 Passes decoded barcode string
 
 @param decodedBarcodeString returned by `MiSnapCamera`
 */
- (void)didReceiveDecodedBarcode:(NSString *)decodedBarcodeString;

/**
 Updates analyzer's orientation for accurate frame analysis
 */
- (void)updateOrientation:(UIInterfaceOrientation)orientation;

/**
 Messages for a specific `MiSnapTutorialMode`
 
 @return An array of messages for a specific tutorial mode
 */
- (NSArray *)messagesForTutorialMode:(MiSnapTutorialMode)tutorialMode;
/**
 Logs module with its name and version in MIBI
 */
- (void)logModuleWithName:(NSString *)name version:(NSString *)version;

@end
