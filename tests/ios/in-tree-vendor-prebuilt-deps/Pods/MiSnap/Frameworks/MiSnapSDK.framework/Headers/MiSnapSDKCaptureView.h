//
//  MiSnapSDKCaptureView.h
//  MiSnapSDK
//
//  Created by Stas Tsuprenko on 6/29/17.
//  Copyright © 2017 Mitek Systems. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import "MiSnapSDKParameters.h"

/*! For app developers that want to provide their own overlay, the app must adopt the MiSnapCaptureViewDelegate protocol
 and implement whatever items are required for their custom user experience.
 */

@class MiSnapSDKCaptureView;

@protocol MiSnapCaptureViewDelegate <NSObject>

@required

- (void)miSnapCaptureView:(MiSnapSDKCaptureView *)captureView
             encodedImage:(NSString *)encodedImage
            originalImage:(UIImage *)originalImage
               andResults:(NSDictionary *)results;

- (void)miSnapCaptureView:(MiSnapSDKCaptureView *)captureView
     cancelledWithResults:(NSDictionary *)results;

@optional

/*! Occurs when the camera is succesfully started and the miSnapCaptureView is receiving sampleBuffer frames
 This event allows the app developer to perform other capure device operations safely after the camera has started. e.g. turning torch on/off
 */
- (void)miSnapCaptureViewReceivingCameraOutput:(MiSnapSDKCaptureView *)captureView;

/*! Occurs when the user taps the manual capture button.
    Once the image is ready, the miSnapCaptureView:encodedImage:originaImage:andResults: will be called.
 */
- (void)miSnapCaptureViewCaptureStillImage;

/*! Occurs when the user taps the torch button and turns torch on when it's off.
 */
- (void)miSnapCaptureViewTurnTorchOn;

/*! Occurs when the user taps the torch button and torch torch off when it's on.
 */
- (void)miSnapCaptureViewTurnTorchOff;

/*! Occurs when the user taps the capture button.
 This event allows the app developer to start sounds and/or animations while the image is being prepared.
 Once the image is ready, the miSnapCaptureView:encodedImage:originaImage:andResults: will be called.
 */
- (void)miSnapCaptureViewStartedManualCapture:(MiSnapSDKCaptureView *)captureView;

/*! Occurs just as an image is selected by auto capture.
 This event allows the app developer to start sounds and/or animations while the image is being prepared.
 Once the image is ready, the miSnapCaptureView:encodedImage:originaImage:andResults: will be called.
 */
- (void)miSnapCaptureViewStartedAutoCapture:(MiSnapSDKCaptureView *)captureView withRect:(CGRect)documentRect;

/*! Sent to the view controller anytime the capture view determines a different value that indicates
 the percentage of potential capture success.  The current document rectangle is also sent so that a guide rectangle,
 or other mechanism, show the user what is currently being analyzed. */
- (void)miSnapCaptureView:(MiSnapSDKCaptureView *)captureView completionScoreUpdated:(int)completionScore withDocumentRect:(CGRect)documentRect;

/*! Sent to the view controller whenever the capture view determines that the user needs to change the
 position/orientation of the device.  For example: get closer, or hold still. */
- (void)miSnapCaptureView:(MiSnapSDKCaptureView *)captureView userHintAvailable:(NSString *)hintString;

/*! Sent to the view controller whenever the capture view determines that the user needs to change the
 position/orientation of the device based on something in bounded area of the document.
 For example: Reduce glare found in the bounded area. */
- (void)miSnapCaptureView:(MiSnapSDKCaptureView *)captureView userHintAvailable:(NSString *)hintString withBoundingRect:(CGRect)boundingRect;

/*! Occurs whenever the capture view changes the torch status */
- (void)miSnapCaptureView:(MiSnapSDKCaptureView *)captureView torchStatusDidChange:(BOOL)torchStatus;


/*!
 Sent to the view controller whenever an image is successfully captured as part of a single or multiple capture session.
 Once an image is analyzed successfully, the miSnapCaptureView:originaImage:andResults: will be called.
 See the MiSnap parameter kMiSnapMaxCaptures.
 */
- (void)miSnapCaptureView:(MiSnapSDKCaptureView *)captureView
            originalImage:(UIImage *)originalImage
               andResults:(NSDictionary *)results;

@end

@interface MiSnapSDKCaptureView : UIView

@property (weak, nonatomic) IBOutlet NSObject <MiSnapCaptureViewDelegate>* delegate;
@property (nonatomic, assign) BOOL timeoutOccurred;
@property (nonatomic, assign) BOOL showGlareTracking;
@property (nonatomic, assign) BOOL useBarcodeScannerLight;
@property (nonatomic, assign) BOOL torchInAutoMode;
@property (nonatomic, strong) UIImage *injectImage;
@property (nonatomic) float analyzeFrameDelay;

- (void)initializeObjectsWithCaptureParameters:(NSDictionary *)captureParams;
- (void)start;
- (void)shutdown;
- (void)shutdownForHelp;
- (void)shutdownForTimeout;
- (void)cancel;
- (void)captureCurrentFrame;
- (void)setCaptureParams:(NSDictionary*)params;
- (BOOL)getTorchStatus;
- (void)startTorch; // Handles the torch at the start the session
- (void)turnTorchOn:(BOOL)isOn;
- (void)turnTorchOff:(BOOL)isOff;

- (void)didReceiveSampleBuffer:(CMSampleBufferRef)sampleBuffer;
- (void)didDecodeBarcode:(NSString *)decodedBarcodeString;
- (void)captureStill:(CMSampleBufferRef)imageSampleBuffer error:(NSError *)error;

- (CGRect)getDocumentRectangle;
- (NSArray *)getDocumentCornerPoints;
- (NSDictionary *)getDocumentResults;
- (NSArray *)getTimeoutResultsFromWarnings:(NSArray *)warningArray;
- (void)updateOrientation:(UIInterfaceOrientation)deviceOrientation;
+ (bool)checkCameraPermission;

+ (NSString*)miSnapVersion;
+ (NSString*)miSnapSDKScienceVersion;
+ (NSString*)mibiVersion;

@end
