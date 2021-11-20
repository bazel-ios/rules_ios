//
//  MiSnapSDKParameters.h
//
//  Created by Mitek Engineering on 6/27/2014.
//  Copyright (c) 2014 Mitek Systems Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

/*! @header
 
 @abstract
 The MiSnapSDKParameters class is used to set and access the parameters used during the document capture process.
 
 The API consists of
 
 - Enumeration types for controlling the capture session
 
 - Properties for each of the parameters
 
 - Methods to reset and update parameters, and create default parameters for supported document types
 
 @author Mitek Engineering on 2018-02-09
 @copyright 2012-2018 Mitek Systems, Inc. All rights reserved.
 @updated 2018-03-23
 @unsorted
 */

#define MISNAP_VERSION @"4.4.1"

// MiSnap Capture modes
typedef NS_ENUM(NSInteger, MiSnapCaptureMode) {
    MiSnapCaptureModeOff		      = 0,	   // Off
    MiSnapCaptureModeManual           = 1,     // Captures a video frame with a manual trigger
    MiSnapCaptureModeDefault	      = 2,     // Use the highest resolution video mode supported by the device
    MiSnapCaptureMode720p             = 3,     // 720p video capture mode
    MiSnapCaptureMode1080p            = 4,     // 1080p video capture mode
    MiSnapCaptureModeHighRes          = 5,     // Special mode for iPhone 6 and 6+
    MiSnapCaptureModeHighResManual    = 6,     // Default hi-res mode for older devices. This hi-res mode is the basic manual photo capture
    MiSnapCaptureModeManualAssist     = 7,     // Normal manual mode, but with the analysis and hints turned on
    MiSnapCaptureModeTestInjectImage  = 8,     // Mitek RESERVED: TestDeck inject single image mode
    MiSnapCaptureModeTestCapture      = 9,     // Mitek RESERVED: TestDeck capture mode
    MiSnapCaptureModeTestAnalyze      = 10     // Mitek RESERVED: TestDeck analyze mode
};

typedef NS_ENUM(NSInteger, MiSnapOrientationMode) {
    MiSnapOrientationModeUnknown                          = 0, // Orientation mode is not set
    MiSnapOrientationModeDeviceLandscapeGhostLandscape    = 1, // Orientation mode where the app supports Landscape only orientation for a device with the Ghost image in Landscape orientation
    MiSnapOrientationModeDevicePortraitGhostPortrait      = 2, // Orientation mode where the app supports all orientations with the Ghost image in Portrait orientation when a device is in Portrait orientation
    MiSnapOrientationModeDevicePortraitGhostLandscape     = 3  // Orientation mode where the app supports all orientations with the Ghost image in Landscape orientation when a device is in Portrait orientation
};

// MiSnap torch (flash) modes
typedef NS_ENUM(NSInteger, MiSnapTorchMode)
{
    TorchModeOFF    = 0,
    TorchModeAUTO   = 1,
    TorchModeON     = 2
};

typedef NS_ENUM(NSInteger, MiSnapGeoRegions)
{
    MiSnapGeoRegionUS         = 0,
    MiSnapGeoRegionGlobal     = 1       // Default
};

/*!
 *  
 *  Document Capture Parameters
 *
 *  This class is used to set and access the parameters used during the document
 *  capture process.  The parameters can be set using the [updateParameters:]
 *  and passing an NSDictionary with key/value pairs.  There are convenience
 *  class methods to obtain the default parameters for each document type.
 *
 *  Once set, the parameters can be accessed via the read-only properties.
 *
 */
@interface MiSnapSDKParameters : NSObject

/*!
 *  The capture mode.  See the MiSnapCaptureMode enum above for values.
 */
@property (readonly, nonatomic) MiSnapCaptureMode captureMode;

/*!
 *  The orientation mode.  See the MiSnapOrientationMode enum above for values.
 */
@property (readonly, nonatomic) MiSnapOrientationMode orientationMode;

/*!
 *  Minimum horizontal fill required to capture an image in Landscape orientation.  E.g. 800 = 80.0%
 *
 *  Range: [500, 1000]
 *  Key: kMiSnapMinLandscapeHorizontalFill
 */
@property (readonly, nonatomic) NSInteger minLandscapeHorizontalFill;

/*!
 *  Minimum horizontal fill required to capture an image in Portrait orientation.  E.g. 800 = 80.0%
 *
 *  Range: [500, 1000]
 *  Key: kMiSnapMinPortraitHorizontalFill
 */
@property (readonly, nonatomic) NSInteger minPortraitHorizontalFill;

/*!
 *  Timeout (ms)
 *
 *  Range: [15,000, 90,000]
 *  Key: kMiSnapTimeout
 */
@property (readonly, nonatomic) NSInteger timeout;

/*!
 *  Maximum number of captures for comparison
 *
 *  Range: [1, 10]
 *  Key: kMiSnapMaxCaptures
 */
@property (readonly, nonatomic) NSInteger maxCaptures;

/*!
 *  Image quality compression to apply
 *  
 *  Range: [0, 100]
 *  Key: kMiSnapImageQuality
 */
@property (readonly, nonatomic) float imageQuality;

// Environmental criteria to satisfy

/*!
 *  Minimum Corner Confidence
 *
 *  Range: [0, 1000]
 *  Key: kMiSnapCornerConfidence
 */
@property (readonly, nonatomic) float minCornerConfidence;

/*!
 *  Minimum Glare Confidence
 *
 *  Range: [0, 1000]
 *  Key: kMiSnapCornerConfidence
 */
@property (readonly, nonatomic) float minGlareConfidence;

/*!
 *  Minimum Contrast Confidence
 *
 *  Range: [0, 1000]
 *  Key: kMiSnapContrastConfidence
 */
@property (readonly, nonatomic) float minContrastConfidence;

/*!
 *  Minimum Background Confidence
 *
 *  Range: [0, 1000]
 *  Key: kMiSnapBackgroundConfidence
 */
@property (readonly, nonatomic) float minBackgroundConfidence;

/*!
 *  Minimum MICR Confidence
 *
 *  Range: [0, 1000]
 *  Key: kMiSnapMICRConfidence
 */
@property (readonly, nonatomic) float minMICRConfidence;

/*!
 *  Minimum brightness
 *
 *  Range: [0, 1000]
 *  Key: kMiSnapMinBrightness
 */
@property (readonly, nonatomic) float minBrightness;

/*!
 *  Maximum brightness
 *  
 *  Range: [0, 1000]
 *  Key: kMiSnapMaxBrightness
 */
@property (readonly, nonatomic) float maxBrightness;

/*!
 *  Minimum sharpness
 *
 *  Range: [0, 1000]
 *  Key: kMiSnapSharpness
 */
@property (readonly, nonatomic) float minSharpness;

/*!
 *  Minimum image padding between document rectangle and image frame
 *
 *  Range: [0, 1000]
 *  Key: kMiSnapMinPadding
 */
@property (readonly, nonatomic) float minPadding;

/*!
 *  Skew angle (tilt)
 *
 *  Range: [0, 1000]
 *  Key: kMiSnapAngle
 */
@property (readonly, nonatomic) float skewAngle;

/*!
 *  Rotation angle (lean)
 *
 *  Range: [0, 1000]
 *  Key: kMiSnapRotationAngle
 */
@property (readonly, nonatomic) float rotationAngle;

/*!
 *  Torch mode.  See TorchMode enum above for values.
 */
@property (readonly, nonatomic) MiSnapTorchMode torchMode;

/*!
 *  Geo.  See MiSnapGeoRegions enum above for values.
 */
@property (readonly, nonatomic) MiSnapGeoRegions geoRegion;

/*!
 *  Document type
 * 
 *  Key: kMiSnapDocumentType
 */
@property (readonly, strong, nonatomic) NSString* documentType;

/*!
 *  Short description of document type
 *
 *  Key: kMiSnapShortDescription
 */
@property (readonly, strong, nonatomic) NSString* shortDescription;

/*!
 *  Application version
 *
 *  Key: kMiSnapApplicationVersion
 */
@property (readonly, strong, nonatomic) NSString* applicationVersion;

/*!
 *  Should dismiss on success
 *
 *  Key: kMiSnapShouldDismissOnSuccess
 */
@property (readonly, nonatomic) BOOL shouldDismissOnSuccess;

/*!
 *  Server version
 *
 *  Key: kMiSnapServerVersion
 */
@property (readonly, strong, nonatomic) NSString* serverVersion;

/*!
 *  Server type
 *
 *  Key: kMiSnapServerType
 */
@property (readonly, strong, nonatomic) NSString* serverType;

/*!
 *  Animation rectangle stroke width.
 *
 *  Range: [0, 100]
 *  Key: kMiSnapAnimationRectangleStrokeWidth
 */
@property (readonly, nonatomic) CGFloat  animationRectangleStrokeWidth;

/*!
 *  Animation rectangle corner radius.  
 *  This value cannot be greater than the animationRectangleStrokeWidth.
 *
 *  Range: [0, 100]
 *  Key: kMiSnapAnimationRectangleCornerRadius
 */
@property (readonly, nonatomic) CGFloat  animationRectangleCornerRadius;

/*!
 *  Animation rectangle color.
 *  This value is specified using a string to define a hex-color.
 *  Ex: @"A136E4" which corresponds to RGB(161, 54, 228)
 *
 *  Key: kMiSnapAnimationRectangleColor
 */
@property (readonly, strong, nonatomic)	UIColor* animationRectangleColor;

/*!
 * Seamless failover
 * Values: 0, 1
 * Key: kMiSnapSeamlessFailover
 */
@property (readonly, nonatomic) BOOL seamlessFailover;

/*!
 *  A string to override the iOS default language setting.
 *  If empty or nil, the default iOS settings are used.
 */
@property (readonly, nonatomic, strong) NSString* languageOverride;

/*!
 *  Time between hints (ms)
 *
 *  Range: [1000, 10000]
 *  Key: kMiSnapSmartHintUpdatePeriod
 */
@property (readonly, nonatomic) NSInteger smartHintUpdatePeriod;

/*!
 *  Time to delay ending MiSnap session after a successful capture (ms)
 *
 *  Range: [0, 10000]
 *  Key: kMiSnapTerminationDelay
 */
@property (readonly, nonatomic, assign) NSInteger terminationDelay;

/*!
 *  Parameters used during document capture.
 */
@property (readonly, nonatomic, strong) NSMutableDictionary* paramsDictionary;

/*!
 *  A string to provide an image to analyze.
 *  Used only in mode MiSnapCaptureModeTestInjectImage
 */
@property (readonly, nonatomic, strong) NSString* injectImageName;


- (void)setApplicationVersion:(NSString*)newValue;

/*!
 *  Init
 *
 *  @return A new DocCaptureParam object or nil
 */
- (id)init;

/*!
 *  Reset any existing parameters and applies the defaults.
 */
- (void)resetParameters;

/*!
 *  Update existing parameters with a new parameter dictionary
 *
 *  @param dict A dictionary containing key-value pairs of values to update
 */
- (void)updateParameters:(NSDictionary*)dict;

/*!
 *  Returns NSDictionary for existing parameters
 */
- (NSDictionary *)toParametersDictionary;

/*!
 *  Returns a dictionary containing preliminary MIBI data with a result code
 *  key.
 *
 *  @param resultCode The result code from the capture
 *
 *  @return A dictionary containing MIBI and capture parameter data
 */
//- (NSMutableDictionary*)preliminaryMIBIDataWithResult:(NSString*)resultCode;

/*!
 *  Returns TRUE if the document type is a check.
 *
 *  @return TRUE if the document type is a check, FALSE otherwise
 */
- (BOOL)isCheck;

/*!
 *  Returns TRUE if the document type is a check back.
 *
 *  @return TRUE if the document type is a check back, FALSE otherwise
 */
- (BOOL)isCheckBack;

/*!
 *  Returns TRUE if the document type is a check front.
 *
 *  @return TRUE if the document type is a check front, FALSE otherwise
 */
- (BOOL)isCheckFront;

/*!
 *  Returns TRUE if the document type is a PDF-417 document.
 *
 *  @return TRUE if the document type is a PDF-417 document, FALSE otherwise
 */
- (BOOL)isPDF417;

/*!
 *  Returns TRUE if the document type is a credit card.
 *
 *  @return TRUE if the document type is a credit card, FALSE otherwise
 */
- (BOOL)isCreditCard;

/*!
 *  Returns a default capture parameter dictionary
 *
 *  @return NSDictionary containing default capture parameters
 */
+ (NSMutableDictionary*)defaultParametersForACH;

/*!
 *  Returns a default capture parameter dictionary
 *
 *  @return NSDictionary containing default capture parameters
 */
+ (NSMutableDictionary*)defaultParametersForCheckFront;

/*!
 *  Returns a default capture parameter dictionary
 *
 *  @return NSDictionary containing default capture parameters
 */
+ (NSMutableDictionary*)defaultParametersForCheckBack;

/*!
 *  Returns a default capture parameter dictionary
 *
 *  @return NSDictionary containing default capture parameters
 */
+ (NSMutableDictionary*)defaultParametersForRemittance;

/*!
 *  Returns a default capture parameter dictionary
 *
 *  @return NSDictionary containing default capture parameters
 */
+ (NSMutableDictionary*)defaultParametersForBalanceTransfer;

/*!
 *  Returns a default capture parameter dictionary
 *
 *  @return NSDictionary containing default capture parameters
 */
+ (NSMutableDictionary*)defaultParametersForW2;

/*!
 *  Returns a default capture parameter dictionary
 *
 *  @return NSDictionary containing default capture parameters
 */
+ (NSMutableDictionary*)defaultParametersForPassport;

/*!
 *  Returns a default capture parameter dictionary
 *
 *  @return NSDictionary containing default capture parameters
 */
+ (NSMutableDictionary*)defaultParametersForDriversLicense;

/*!
 *  Returns a default capture parameter dictionary
 *
 *  @return NSDictionary containing default capture parameters
 */
+ (NSMutableDictionary*)defaultParametersForIdCardFront;

/*!
 *  Returns a default capture parameter dictionary
 *
 *  @return NSDictionary containing default capture parameters
 */
+ (NSMutableDictionary*)defaultParametersForIdCardBack;

/*!
 *  Returns a default capture parameter dictionary
 *
 *  @return NSDictionary containing default capture parameters
 */
+ (NSMutableDictionary*)defaultParametersForLandscapeDocument;

/*!
 *  Returns a default capture parameter dictionary
 *
 *  @return NSDictionary containing default capture parameters
 */
+ (NSMutableDictionary*)defaultParametersForBarcode;

/*!
 *  Returns a default capture parameter dictionary
 *
 *  @return NSDictionary containing default capture parameters
 */
+ (NSMutableDictionary*)defaultParametersForCreditCard;

/*!
 *
 *  @return dictionary of DocCaptureParams
 */
- (NSDictionary *)toDictionary;

@end

extern NSString* const kMiSnapHintTooDim;
extern NSString* const kMiSnapHintTooBright;
extern NSString* const kMiSnapHintNotSharp;
extern NSString* const kMiSnapHintLowContrast;
extern NSString* const kMiSnapHintBusyBackground;
extern NSString* const kMiSnapHintGlare;
extern NSString* const kMiSnapHintNotCheckFront;
extern NSString* const kMiSnapHintNotCheckBack;
extern NSString* const kMiSnapHintRotation;
extern NSString* const kMiSnapHintAngleTooLarge;
extern NSString* const kMiSnapHintTooClose;
extern NSString* const kMiSnapHintTooFar;
extern NSString* const kMiSnapHintNothingDetected;
extern NSString* const kMiSnapHintHoldSteady;
extern NSString* const kMiSnapHintGoodFrame;
extern NSString* const kMiSnapOrientation;

// Tutorial info
extern NSString* const kMiSnapTutorialHelpCheckFront;
extern NSString* const kMiSnapTutorialHelpCheckBack;
extern NSString* const kMiSnapTutorialHelpLicense;
extern NSString* const kMiSnapTutorialHelpPassport;
extern NSString* const kMiSnapTutorialHelpDocument;

extern NSString* const kMiSnapTutorialFailoverAuto;
extern NSString* const kMiSnapTutorialFailoverManual;;
extern NSString* const kMiSnapTutorialPhotoAuto;
extern NSString* const kMiSnapTutorialPhotoManual;

extern NSString* const kAnalyzedAngle;
extern NSString* const kAnalyzedBrightness;
extern NSString* const kAnalyzedSharpness;
extern NSString* const kAnalyzedBorderSharpness;
extern NSString* const kAnalyzedConfidence;
extern NSString* const kAnalyzedAreaRatio;
extern NSString* const kAnalyzedWidthRatio;
extern NSString* const kAnalyzedCornerPoints;
extern NSString* const kAnalyzedBoundingBox;
extern NSString* const kAnalyzedImageSize;
extern NSString* const kAnalyzedGlare;
extern NSString* const kAnalyzedGlareBoundingBox;
extern NSString* const kAnalyzedBackgroundConfidence;
extern NSString* const kAnalyzedContrastConfidence;
extern NSString* const kMiSnapCameraWasAdjusted;

