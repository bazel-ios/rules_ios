//
//  MiSnapSDKScienceParameters.h
//  MiSnapSDKScience
//
//  Created by Steve Blake on 10/30/17.
//  Copyright © 2017 Mitek Systems. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MobileFlow/MobileFlow.h>

/*!
 * MiSnapSDK Science Capture Modes
 */
typedef NS_ENUM(NSInteger, MiSnapSDKScienceCaptureMode) {
    MiSnapSDKScienceCaptureModeOff              = 0,     // Off
    MiSnapSDKScienceCaptureModeManual           = 1,     // Captures a video frame with a manual trigger
    MiSnapSDKScienceCaptureModeDefault          = 2,     // Use the highest resolution video mode supported by the device
    MiSnapSDKScienceCaptureMode720p             = 3,     // 720p video capture mode
    MiSnapSDKScienceCaptureMode1080p            = 4,     // 1080p video capture mode
    MiSnapSDKScienceCaptureModeHighRes          = 5,     // Special mode for iPhone 6 and 6+
    MiSnapSDKScienceCaptureModeHighResManual    = 6,     // Default hi-res mode for older devices. This hi-res mode is the basic manual photo capture
    MiSnapSDKScienceCaptureModeManualAssist     = 7,     // Normal manual mode, but with the analysis and hints turned on
    MiSnapSDKScienceCaptureModeTestInjectImage  = 8,     // Mitek RESERVED: TestDeck inject single image mode
    MiSnapSDKScienceCaptureModeTestCapture      = 9,     // Mitek RESERVED: TestDeck capture mode
    MiSnapSDKScienceCaptureModeTestAnalyze      = 10     // Mitek RESERVED: TestDeck analyze mode
};

typedef NS_ENUM(NSInteger, MiSnapSDKScienceOrientationMode) {
    MiSnapSDKScienceOrientationModeUnknown                          = 0, // Orientation mode is not set
    MiSnapSDKScienceOrientationModeDeviceLandscapeGhostLandscape    = 1, // Orientation mode where the app supports Landscape only orientation for a device with the Ghost image in Landscape orientation
    MiSnapSDKScienceOrientationModeDevicePortraitGhostPortrait      = 2, // Orientation mode where the app supports all orientations with the Ghost image in Portrait orientation when a device is in Portrait orientation
    MiSnapSDKScienceOrientationModeDevicePortraitGhostLandscape     = 3  // Orientation mode where the app supports all orientations with the Ghost image in Landscape orientation when a device is in Portrait orientation
};

typedef NS_ENUM(NSInteger, MiSnapSDKScienceGeoRegions)
{
    MiSnapSDKScienceGeoRegionUS         = 0,
    MiSnapSDKScienceGeoRegionGlobal     = 1     // Default
};


/*!
 @class MiSnapSDKScienceParameters
 @abstract
 MiSnapSDKScienceParameters is a class that defines parameters used for analyzing video frames and the science results.
 */
@interface MiSnapSDKScienceParameters : NSObject

/*!
 @abstract Creates an instance of MiSnapSDKScienceParameters
 @param docType the document type to use. The docType should be one of the
 constants for kMiSnapSDKScienceDocumentType[type] defined in this interface.
 @return an instance of MiSnapSDKScienceParameters that has default properties set
 */
- (instancetype)initWithDefaultParametersForDocumentType:(NSString*)docType;

/*!
 * The video mode.  YES runs session with RGBA images. NO runs session with Gray images.
 */
@property (nonatomic) BOOL analyzeRGBVideo;

/*!
 *  The capture mode.  See the MiSnapSDKScienceCaptureMode enum above for values.
 */
@property (nonatomic) MiSnapSDKScienceCaptureMode captureMode;

/*!
 *  The orientation mode.  See the MiSnapSDKScienceOrientationMode enum above for values.
 */
@property (nonatomic) MiSnapSDKScienceOrientationMode orientationMode;

/**
 *  Geo.  See MiSnapSDKScienceGeo enum above for values.
 */
@property (nonatomic) MiSnapSDKScienceGeoRegions geoRegion;

/*!
 *  Document type
 *
 *  Key: kMiSnapSDKScienceDocumentType
 */
@property (nonatomic) NSString* documentType;

// Environmental criteria to satisfy
/*!
 *  Minimum horizontal fill required to capture an image in Landscape orientation.  E.g. 800 = 80.0%
 *
 *  Range: [500, 1000]
 *  Key: kMiSnapMinLandscapeHorizontalFill
 */
@property (nonatomic) NSInteger minLandscapeHorizontalFill;

/*!
 *  Minimum horizontal fill required to capture an image in Portrait orientation.  E.g. 800 = 80.0%
 *
 *  Range: [500, 1000]
 *  Key: kMiSnapMinPortraitHorizontalFill
 */
@property (nonatomic) NSInteger minPortraitHorizontalFill;

/*!
 *  Minimum Corner Confidence
 *
 *  Range: [0, 1000]
 *  Key: kMiSnapCornerConfidence
 */
@property (nonatomic) float minCornerConfidence;

/*!
 *  Minimum Glare Confidence
 *
 *  Range: [0, 1000]
 *  Key: kMiSnapCornerConfidence
 */
@property (nonatomic) float minGlareConfidence;

/*!
 *  Minimum Contrast Confidence
 *
 *  Range: [0, 1000]
 *  Key: kMiSnapContrastConfidence
 */
@property (nonatomic) float minContrastConfidence;

/*!
 *  Minimum Background Confidence
 *
 *  Range: [0, 1000]
 *  Key: kMiSnapBackgroundConfidence
 */
@property (nonatomic) float minBackgroundConfidence;

/*!
 *  Minimum MICR Confidence
 *
 *  Range: [0, 1000]
 *  Key: kMiSnapMICRConfidence
 */
@property (nonatomic) float minMICRConfidence;

/*!
 *  Minimum brightness
 *
 *  Range: [0, 1000]
 *  Key: kMiSnapMinBrightness
 */
@property (nonatomic) float minBrightness;

/*!
 *  Maximum brightness
 *
 *  Range: [0, 1000]
 *  Key: kMiSnapMaxBrightness
 */
@property (nonatomic) float maxBrightness;

/*!
 *  Minimum sharpness
 *
 *  Range: [0, 1000]
 *  Key: kMiSnapSharpness
 */
@property (nonatomic) float minSharpness;

/*!
 *  Minimum image padding between document rectangle and image frame
 *
 *  Range: [0, 1000]
 *  Key: kMiSnapMinPadding
 */
@property (nonatomic) float minPadding;

/*!
 *  Skew angle (tilt)
 *
 *  Range: [0, 1000]
 *  Key: kMiSnapAngle
 */
@property (nonatomic) float maxSkewAngle;

/*!
 *  Rotation angle (lean)
 *
 *  Range: [0, 1000]
 *  Key: kMiSnapRotationAngle
 */
@property (nonatomic) float maxRotationAngle;

/*!
 *  Aspect ratio mismatch
 *
 *  Range: [0, 100]
 */
@property (nonatomic) float maxAspectRatioMismatch;

/*! Indicates MiSnap use internal parameters to attempt to capture the front of a check;
 */
extern NSString* const kMiSnapSDKScienceDocumentTypeACH;

/*! Indicates MiSnap use internal parameters to attempt to capture the front of a check.
 */
extern NSString* const kMiSnapSDKScienceDocumentTypeCheckFront;

/*! Indicates MiSnap use internal parameters to attempt to capture the back of a check.
 */
extern NSString* const kMiSnapSDKScienceDocumentTypeCheckBack;

/*! Indicates MiSnap use internal parameters to attempt to capture a Passport document
 */
extern NSString* const kMiSnapSDKScienceDocumentTypePassport;

/*! Indicates MiSnap use internal parameters to attempt to capture a Driver License.
 */
extern NSString* const kMiSnapSDKScienceDocumentTypeDriverLicense;

/*! Indicates MiSnap use internal parameters to attempt to capture a front of ID card
 */
extern NSString* const kMiSnapSDKScienceDocumentTypeIdCardFront;

/*! Indicates MiSnap use internal parameters to attempt to capture a back of ID card
 */
extern NSString* const kMiSnapSDKScienceDocumentTypeIdCardBack;

/*! Indicates MiSnap use internal parameters to attempt to capture a generic landscape document
 */
extern NSString* const kMiSnapSDKScienceDocumentTypeLandscapeDoc;


////////////// Not Supported ///////////////////////////////////////////////////////////////////
/*! Indicates MiSnap use internal parameters to attempt to capture an Auto Insurance Card.
 *    this can be a generic auto-insurance card or a prefix for one of several specific vendors.
 */
//extern NSString* const kMiSnapSDKScienceDocumentTypeAutoInsurancePrefix;

/*! Indicates MiSnap use internal parameters to attempt to capture a coupon to be used for
 *    balance transfer.
 */
//extern NSString* const kMiSnapSDKScienceDocumentTypeBalanceTransfer;

/*! Indicates MiSnap use internal parameters to attempt to capture a business card. */
//extern NSString* const kMiSnapSDKScienceDocumentTypeBusinessCard;

/*! Indicates MiSnap use internal parameters to attempt to capture a coupon for Bill Pay */
//extern NSString* const kMiSnapSDKScienceDocumentTypeRemittance;

/*! Indicates MiSnap use internal parameters to attempt to capture an auto VIN number */
//extern NSString* const kMiSnapSDKScienceDocumentTypeVIN;

/*! Indicates MiSnap use internal parameters to attempt to capture a W-2 document */
//extern NSString* const kMiSnapSDKScienceDocumentTypeW2;

/*! Indicates MiSnap should internally invoke the barcode reader library and return the
 text of the captured PDF417
 */
//extern NSString* const kMiSnapSDKScienceDocumentTypePDF417;

/*! @group MiSnap Input Parameters key constants
 @abstract keys for values in NSDictionary passed to MiSnap as parameters to
 @link setupMiSnapWithParams: @/link
 */

/*! Indicates MiSnap should scan for a credit card and return the
 *    text of the captured account number
 */
//extern NSString* const kMiSnapSDKScienceDocumentTypeCreditCard;

@end
