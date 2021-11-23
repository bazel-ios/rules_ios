//
//  MiSnapSDK.h
//  MiSnapSDK
//
//  Created by Greg Fisch on 6/25/14.
//  Copyright (c) 2014 mitek. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import <UiKit/UIKit.h>

#import "MiSnapSDKParameters.h"
#import "MiSnapSDKCaptureView.h"
#import "MiSnapSDKResourceLocator.h"
#import "MiSnapSDKImageUtilities.h"
#import "MiSnapSDKCaptureUtils.h"
#import "UINavigationController+MiSnapSDK.h"

/*! @header
 
 @abstract
 The MiSnap SDK API is an interface that allows the app developer targeting Mitek
 Mobile Imaging servers to construct mobile device apps.
 
 The API consists of
 
 - a method for invoking the MiSnapViewController, which starts the capture session
 and captures the image
 
 - calls into the API to query and establish parameters MiSnap uses during operation
 
 - constant values that can be used by the app developer to override MiSnap defaults
 
 - callback protocols to which the app must conform in order to retrieve MiSnap results
 
 @author Mitek Engineering on 2018-02-09
 @copyright 2012-2018 Mitek Systems, Inc. All rights reserved.
 @updated 2018-03-23
 @unsorted
 */



// Parameter names for NSDictionary representation
// Viewfinder and Document sizes

/*! @group MiSnap Input Parameters key constants
 
 @abstract Parameter names for use in NSDictionary passed to @link setupMiSnapWithParams: @/link
 */


/*!	By establishing this MiSnap parameter with a non-zero value, MiSnap will attempt to use the
 corresponding mode.
 
 By establishing this MiSnap parameter with the value 2, MiSnap will attempt to determine the
 best video frame size for the given device.
 
 This parameter replaces both the kMiSnapAllowVideoFramesMode and the kMiSnapAllowVideoFrames
 parameters.
 
 It should not be changed without consulting with <i>Mitek Professional Services</i>.
 
 @note Values
 "0" == off<br>
 "1" == manual capture<br>
 "2" == default to the highest video resolution supported by the device<br>
 "3" == force use of 720p (i.e. 1280x720) for video frame processing (if available)<br>
 "4" == force use of 1080p (i.e. 1920x1080) for video frame processing (if available)<br>
 "5" == force use of a special hi-res capture mode for iPhone 6 and 6+ for video frame processing
 at the highest resolution supported by the device, or a special manual photo mode for older devices<br>
*/
extern NSString* const kMiSnapCaptureMode;


/*! This parameter specifies the horizontal width in Landscape orientation as a percentage of the viewfinder
 that the document must fill before the image will be captured.  The width of the
 Guide Image will scale based on this value
 
 Default value is 700 (70%) for all document types except Driver's License where the default is 610 and Passport where the default is 600
 
 @note Values
 range 500-1000 measured in tenths of a percent (i.e. value of 800 == 80%)<br>
 default = 700
 */
extern NSString* const kMiSnapMinLandscapeHorizontalFill;

/*! This parameter specifies the horizontal width in Portrait orientation as a percentage of the viewfinder
 that the document must fill before the image will be captured.  The width of the
 Guide Image will scale based on this value
 
 Default value is 875 (87.5%) for all document types
 
 @note Values
 range 500-1000 measured in tenths of a percent (i.e. value of 800 == 80%)<br>
 default = 875
 */
extern NSString* const kMiSnapMinPortraitHorizontalFill;


/*!	The length of time (in milliseconds) a user is given to attempt to capture an image.
 *  range 1000 - 90000 (1 second to 90 seconds)
 */
extern NSString* const kMiSnapTimeout;

/*!	The maximum number of successful captures to perform before returning the sharpest image.
 
 @note Values
 range 1-10<br>
 default = 5
 */
extern NSString* const kMiSnapMaxCaptures;


// Image quality parameters

/*!	indicates how much to compress the image. Typically, images are compressed to reduce
 bandwidth overhead and time when transferring the image to Mitek mobile imaging servers.
 
The recommended default value has been carefully tuned for image quality purposes - Do not change default value without consulting Mitek.
 
 @note Values
 range: 0-100<br>
 0 == "minimum quality"/"maximum compression"<br>
 100 == "maximum quality"/"no compression"<br>
 default = 30
 */
extern NSString* const kMiSnapImageQuality;

// Environmental criteria to satisfy

/*!	The acceptable corner confidence to allow automatic image capture
 (applies to video camera only)
 
 @note Values
 range: 0 - 1000 (1000 indicates "ideal confidence")<br>
 default = Varies by document type
 */
extern NSString* const kMiSnapCornerConfidence;

/*!	The acceptable glare confidence to allow automatic image capture
 (applies to video camera only)
 
 @note Values
 range: 0 - 1000 (1000 indicates "ideal confidence")<br>
 default = Varies by document type
 */
extern NSString* const kMiSnapGlareConfidence;

/*!	The acceptable contrast confidence to allow automatic image capture
 (applies to video camera only)
 
 @note Values
 range: 0 - 1000 (1000 indicates "ideal confidence")<br>
 default = Varies by document type
 */
extern NSString* const kMiSnapContrastConfidence;

/*!	The acceptable background confidence to allow automatic image capture
 (applies to video camera only)
 
 @note Values
 range: 0 - 1000 (1000 indicates "ideal confidence")<br>
 default = Varies by document type
 */
extern NSString* const kMiSnapBackgroundConfidence;

/*!	The acceptable confidence a MICR is detected on check front to allow automatic image capture
 (applies to video camera only)
 
 @note Values
 range: 0 - 1000 (1000 indicates "ideal confidence")<br>
 default = Varies by document type
 */
extern NSString* const kMiSnapMICRConfidence;

/*!	The acceptable brightness to allow automatic image capture
 (applies to video camera only)
 
 @note Values
 range: 0 - 1000 (1000 indicates "ideal brightness")<br>
 default = Varies by document type
 */
extern NSString* const kMiSnapMinBrightness;

/*! The minimum padding in pixels around a document
 
 @note Values
 range: 0 - 1000
 default = 7
 */
extern NSString* const kMiSnapMinPadding;


/*!	The maximum acceptable brightness to allow automatic image capture
 (applies to video camera only)
 
 The recommended default value has been carefully tuned for image quality purposes - Do not change default value without consulting Mitek.
 
 @note Values
 range: 0 - 1000 (1000 indicates "ideal brightness"; 0 indicates ignore setting)<br>
 default = 700
 */
extern NSString* const kMiSnapMaxBrightness;


/*!	The acceptable sharpness (where 1000 is “ideal”) to allow automatic image capture
 (applies to video camera only).
 
 The recommended default value has been carefully tuned for image quality purposes - Do not change default value without consulting Mitek.
 
 @note Values
 range: 0 - 1000 (1000 indicates "ideal sharpness"; 0 indicates ignore setting)<br>
 default = Document specific: 600 for ACH/CheckFront, 100 for CheckBack, 200 for CheckBack withEndorsement Detection,
 750 for AutoInsurance, 850 for BalanceTransfer/Remittance, 400 for BusinessCard,
 350 for DriverLicense, 400 for W2, and 400 for all other types of documents.
 */
extern NSString* const kMiSnapSharpness;


/*! The detected angle of skew from the display measured at the time of automatic image capture.

 @note Values
range 0-1000 measured in tenths of a percent (i.e. 150 == 15%)<br>
0 indicates that the angle setting is to be ignored by MiSnap during processing. Angle greater than 0 indicates the device is rotated off the plane of the document.<br>
default = 150
*/
extern NSString* const kMiSnapAngle;

/*! The detected angle rotated from the display measured at the time of automatic image capture.
 
 @note Values
 range 0-1000 measured in tenths of a percent (i.e. 150 == 15%)<br>
 0 indicates that the angle setting is to be ignored by MiSnap during processing. Angle greater than 0 indicates the document is rotated off axis, like a crooked picture frame.<br>
 default = 150
 */
extern NSString* const kMiSnapRotationAngle;

// Flash/Torch

/*!	The initial setting for the torch in MiSnap Video Auto-Capture mode.<br>
 
 For value AUTO (or AUTO+DL), MiSnap uses the @link kMiSnapMinBrightness @/link calculated for
 each video frame passed into MiSnap to automatically determine when to turn on the device torch
 for the user.  (If the user subsequently turns off the torch, or turns on the torch prior to
 the auto-torch calculation kicking in and then turns off the torch, the Auto-Torch calculation
 will be suspended for the remainder of that MiSnap capture session.)
 
 For @link kMiSnapDocumentType @/link containing "DRIVER_LICENSE", MiSnap will ignore the
 AUTO setting and leave the torch off (but will make it available for the user).  AUTO+DL
 ignores this MiSnap internal override.
 
 The recommended default value has been carefully tuned for image quality purposes - Do not change default value without consulting Mitek.
 
 @note Values
 2 == ON - torch on<br>
 1 == Auto - MiSnap determines if torch is needed during Video Frame processing<br>
 0 == OFF - no torch<br>
 default = 1, except if kMiSnapDocumentType contains "DRIVER_LICENSE" the recommended use is to set this to 0 
 */
extern NSString* const kMiSnapTorchMode;

/*!    The initial setting for the Geo Region US or Global in MiSnap<br>
 
 @note Values
 0 == Geo US - Use for US documents<br>
 1 == Geo Global - Use for Global documents<br>
 default = 1
 */
extern NSString* const kMiSnapGeoRegion;

// Document type

/*!	The type of document to be captured.
 
 If value @link kMiSnapDocumentTypePDF417 @/link is specified, then MiSnap will internally
 capture an image of the 2D Barcode and return the decoded string using key
 @link kMiSnapPDF417Data @/link in the @link kMiSnapResultCode @/link field in the delegate
 callback @link miSnapFinishedReturningEncodedImage:originalImage:andResults: @/link
 
 @note Values
 default = "ACH"
 • “ACH” – for capturing front of check for ACH use case
 • “CheckFront” - for capturing front of check for mobile deposit
 • “CheckBack” - for capturing back of check for mobile deposit
 • “REMITTANCE” or “BALANCE_TRANSFER” - for capturing a bill payment stub for bill pay or balance transfer use cases
 • “DRIVER_LICENSE” - for capturing the front of a Driver's License
*/
extern NSString* const kMiSnapDocumentType;

/*! A human readable description of the document type referenced in
 @link kMiSnapDocumentType @/link
 
 @note Values
 default = "ACH Enrollment"
 */
extern NSString* const kMiSnapShortDescription;


// Customizable UI Elements

/*! Stroke-width(thickness) in pixels of the line representing the rectangle that is
 animated when MiSnap has determined that the user has successfully captured an image of
 a document
 
 @note Values
 range 1-100<br>
 default = 20
 */
extern NSString* const kMiSnapAnimationRectangleStrokeWidth;


/*!	Corner-radius in pixels of the line representing the rectangle that is animated
 when MiSnap has determined that the user has successfully captured an image of a document
 
 @note Values
 range 1-100<br>
 default = 16
 */
extern NSString* const kMiSnapAnimationRectangleCornerRadius;


/*!	6-character color value (HTML-like RGB format, with two hex characters per R, G, and B)
 of the rectangle that is animated when MiSnap has determined that the user has
 successfully captured an image of a document.
 
 @note Values
 range 6-character string with hex values, no prefix<br>
 default = ED1C24
 */
extern NSString* const kMiSnapAnimationRectangleColor;

/* Seamless failover
 @note Values
 0 - seamless failover disabled (smart failover will be presented)
 1 - seamless failover enabled
 default = 0
 */
extern NSString* const kMiSnapSeamlessFailover;

/*! @group MiSnap Input Parameters Document Type constant values */

/*! indicates MiSnap use internal parameters to attempt to capture the back of a check,
 displaying "Back of check" at the top of the capture preview display.
 */
extern NSString* const kMiSnapDocumentTypeCheckBack;

/*! indicates MiSnap use internal parameters to attempt to capture the front of a check,
 displaying "Front of check" at the top of the capture preview display.
 */
extern NSString* const kMiSnapDocumentTypeCheckFront;

/*! indicates MiSnap use internal parameters to attempt to capture a generic landscape document */
extern NSString* const kMiSnapDocumentTypeLandscapeDoc;

/*! indicates MiSnap should internally invoke the barcode reader library and return the
 text of the captured PDF417
 */
extern NSString* const kMiSnapDocumentTypePDF417;

/*! @group MiSnap Input Parameters key constants
 @abstract keys for values in NSDictionary passed to MiSnap as parameters to
 @link setupMiSnapWithParams: @/link
 */

/*! indicates MiSnap should scan for a credit card and return the
 *	text of the captured account number
 */
extern NSString* const kMiSnapDocumentTypeCreditCard;

/*! indicates MiSnap use internal parameters to attempt to capture the front of a check;
 *	differs from @link kMiSnapDocumentTypeCheckFront @/link in terms of parameter specifics
 *	and that ACH never attempts to display the "Front Image" hint.
 */
extern NSString* const kMiSnapDocumentTypeACH;

/*! indicates MiSnap use internal parameters to attempt to capture an Auto Insurance Card.
 *	this can be a generic auto-insurance card or a prefix for one of several specific vendors.
 */
extern NSString* const kMiSnapDocumentTypeAutoInsurancePrefix;

/*! indicates MiSnap use internal parameters to attempt to capture a coupon to be used for
 *	balance transfer.
 */
extern NSString* const kMiSnapDocumentTypeBalanceTransfer;

/*! indicates MiSnap use internal parameters to attempt to capture a business card. */
extern NSString* const kMiSnapDocumentTypeBusinessCard;

/*! indicates MiSnap use internal parameters to attempt to capture a portrait Driver License.
 *	this can be a generic driver's license in terms of UX, or the prefix for an internal
 *	Driver License in terms of specific of the capture process.
 */
extern NSString* const kMiSnapDocumentTypeDriverLicense;

/*! indicates MiSnap use internal parameters to attempt to capture a front of ID card */
extern NSString* const kMiSnapDocumentTypeIdCardFront;

/*! indicates MiSnap use internal parameters to attempt to capture a back of ID card */
extern NSString* const kMiSnapDocumentTypeIdCardBack;

/*! indicates MiSnap use internal parameters to attempt to capture a coupon for Bill Pay */
extern NSString* const kMiSnapDocumentTypeRemittance;

/*! indicates MiSnap use internal parameters to attempt to capture an auto VIN number */
extern NSString* const kMiSnapDocumentTypeVIN;

/*! indicates MiSnap use internal parameters to attempt to capture a W-2 document */
extern NSString* const kMiSnapDocumentTypeW2;

/*! indicates MiSnap use internal parameters to attempt to capture a Passport document */
extern NSString* const kMiSnapDocumentTypePassport;



// Server Versions that MiSnap knows about
// Versions
 extern NSString* const kMiSnapVersion;
 extern NSString* const kMiSnapServerVersion;
 extern NSString* const kMiSnapServerType;
 extern NSString* const kMiSnapMibiVersion;
 extern NSString* const kMiSnapScienceVersion;
 extern NSString* const kMiSnapApplicationVersion;
 extern NSString* const kMiSnapShouldDismissOnSuccess;

/*!	@group MiSnap Output Parameters key constants
 @abstract keys for values in NSDictionary passed back as parameter to
 @link miSnapFinishedReturningEncodedImage:originalImage:andResults: @/link or
 @link miSnapCancelledWithResults: @/link
 */

/*! The key constant to access the value indicating success, cancellation, or other MiSnap
 termination conditions as passed in the @link MiSnapViewControllerDelegate @/link protocol
 method callbacks @link miSnapFinishedReturningEncodedImage:originalImage:andResults: @/link
 and @link miSnapCancelledWithResults: @/link
 
 @note Values
 @link kMiSnapResultSuccessVideo @/link , @link kMiSnapResultSuccessStillCamera @/link ,
 @link kMiSnapResultSuccessPDF417 @/link , @link kMiSnapResultCameraNotSufficient @/link ,
 @link kMiSnapResultCancelled @/link , @link kMiSnapResultVideoCaptureFailed @/link .
 */
extern NSString* const kMiSnapResultCode;


/*! The key constant to access the value containing the PDF417 data captured by the barcode
 reader library in MiSnap as passed in the @link MiSnapViewControllerDelegate @/link protocol
 method callback @link miSnapFinishedReturningEncodedImage:originalImage:andResults: @/link
 */
extern NSString* const kMiSnapPDF417Data;

/*! The key constant to access the value containing the MiBI/UXP data collected during the video
 auto-capture process in MiSnap as passed in the @link MiSnapViewControllerDelegate @/link
 protocol method callbacks
 @link miSnapFinishedReturningEncodedImage:originalImage:andResults: @/link and
 @link miSnapCancelledWithResults: @/link.
 
 Mitek Best Practices Guide recommend passing this data to the Mitek imaging server to which
 the app is connected (usually via app proxy server) in the case of cancellation to ensure
 that MiBI/UXP data for abandoned sessions is collected.
 */
extern NSString* const kMiSnapMIBIData;


/*! The detected skew angle between the device display surface and the document, measured at the time of automatic image
 capture. 0 means there was no detected difference: E.g. The surface and document were parallel. This should never exceed the Angle
 input parameter.
 
 @note Values
 range: 0-1000 measured in tenths of a percent (i.e. 150 == 15%).<br>
 0 means there was no detected difference in rotation or skew.
 */
extern NSString* const kMiSnapReturnAngle;


/*! The detected rotation angle of the document within the display, measured at the time of automatic image
 capture. 0 means there was no detected difference: E.g. The document edges are parallel to the display edges.  This should never exceed the Rotation
 input parameter.
 
 @note Values
 range: 0-1000 measured in tenths of a percent (i.e. 150 == 15%).<br>
 0 means there was no detected difference in rotation or skew.
 */
extern NSString* const kMiSnapReturnRotation;


/*!	The brightness value (where 1000 is “ideal”) measured at the time of automatic image
 capture (applies to video camera only)
 
 @note Values
 range: 0-1000 (1000 represents "ideal brightness")
 */
extern NSString* const kMiSnapReturnBrightness;


/*! The sharpness value (where 1000 is “ideal”) measured at the time of automatic image
 capture (applies to video camera only). <br><br>
 
 @note Values
 range: 0-1000 (1000 represents "ideal sharpness")
 */
extern NSString* const kMiSnapReturnSharpness;


/*!	The glare value (where 1000 is “ideal”) measured at the time of automatic image
 capture (applies to video camera only)
 
 @note Values
 range: 0-1000 (1000 represents "ideal no glare")
 */
extern NSString* const kMiSnapReturnGlare;

/*!    The corner points measured at the time of automatic image
 capture (applies to video camera only)
 
 @note Values
 array of points A, B, C, D relative to the top of the device screen:
 A = Upper left corner
 B = Upper right corner
 C = Lower right corner
 D = Loer left corner
 */
extern NSString* const kMiSnapReturnCornerPoints;


/*!	The corner confidence value (where 1000 is “ideal”) measured at the time of automatic image
 capture (applies to video camera only)
 
 @note Values
 range: 0-1000 (1000 represents "ideal high corner confidence")
 */
extern NSString* const kMiSnapReturnCornerConfidence;


/*!	The MICR confidence value (where 1000 is “ideal”) measured at the time of automatic image
 capture (applies to video camera only)
 
 @note Values
 range: 0-1000 (1000 represents "ideal MICR confidence")
 */
extern NSString* const kMiSnapReturnMICRConfidence;


/*!	The background confidence value (where 1000 is “ideal”) measured at the time of automatic image
 capture (applies to video camera only)
 
 @note Values
 range: 0-1000 (1000 represents "ideal background, not busy")
 */
extern NSString* const kMiSnapReturnBackgroundConfidence;


/*!	The contrast confidence value (where 1000 is “ideal”) measured at the time of automatic image
 capture (applies to video camera only)
 
 @note Values
 range: 0-1000 (1000 represents "ideal contrast between document borders and background")
 */
extern NSString* const kMiSnapReturnContrastConfidence;


/*! The minimum number of pixels between the document rectangle and the image frame
 @note Values
 range: 0-1000
 */
extern NSString* const kMiSnapReturnMinPadding;

///*! A string representing the value(s) read from the MICR line if present.  Nil, or empty, if no
// MICR was found
// */
//extern NSString* const  kMiSnapReturnMICR;

/*!	An indicator of whether or not MiSnap was in still or an Auto-capture mode at the time of
 capture.<br><br>
 
 @note Values
 "0" == off<br>
 "1" == manual<br>
 "2" == default to a device appropriate setting<br>
 "3" == force use of 720p (i.e. 1280x720) for video frame processing (if available)<br>
 "4" == force use of 1080p (i.e. 1920x1080) for video frame processing (if available)<br>
 "5" == force use of a photo mode for video frame processing at the highest resolution supported by the device<br>
 */
extern NSString* const kMiSnapReturnCaptureMode;

/*! An indicator of MiSnap orientation mode<br><br>
 
 @note Values
 "0" == Unknown<br>
 "1" == device in landscape, ghost image in landscape<br>
 "2" == device in portrait, ghost image in portrait<br>
 "3" == device in portrait, ghost image in landscape<br>
 */
extern NSString* const kMiSnapOrientationMode;

/*!	An indicator of whether or not the torch was on or off at the end of the MiSnap session
 
 @note Values
 1 == Torch was on at end of session<br>
 0 == Torch was off at end of session
 */
extern NSString* const kMiSnapReturnLighting;

/*!	@group MiSnap Output ResultCode value constants  */


/*! MiSnap image capture transaction resulted in successful auto-capture in video-mode */
extern NSString* const kMiSnapResultSuccessVideo;

/*! MiSnap image capture transaction resulted in successful capture in still-camera mode */
extern NSString* const kMiSnapResultSuccessStillCamera;

/*! MiSnap transaction aborted due to inability of camera to perform necessary function */
extern NSString* const kMiSnapResultCameraNotSufficient;

/*! MiSnap transaction cancelled by user */
extern NSString* const kMiSnapResultCancelled;

/*! MiSnap video-mode auto-capture failed and auto-failover to still camera disabled */
extern NSString* const kMiSnapResultVideoCaptureFailed;

/*! MiSnap successful barcode capture */
extern NSString* const kMiSnapResultSuccessPDF417;

/*! The amount of time in milliseconds to delay before MiSnap terminates after
 a successful capture.*/
extern NSString* const kMiSnapTerminationDelay;

/*! The time in milliseconds before first hint is sent or subsequent hints are sent. */
extern NSString* const kMiSnapSmartHintUpdatePeriod;

/*! A key to retrieve various document warnings after image analysis. */
extern NSString* const kMiSnapResultWarnings;

/*! A key to retrieve prioritized warnings after image analysis. */
extern NSString* const kAnalyzedWarnings;

/*! A key to retrieve mrz result; note it's only present if MiSnapFCSSDK is integrated */
extern NSString* const kMiSnapMrzResult;

/*! A key to retrieve mrz string; note it's only present if MiSnapFCSSDK is integrated */
extern NSString* const kMiSnapMrzString;

/*! A key to retrieve mrz document number; note it's only present if MiSnapFCSSDK is integrated */
extern NSString* const kMiSnapMrzDocNumber;

/*! A key to retrieve mrz date of birth; note it's only present if MiSnapFCSSDK is integrated */
extern NSString* const kMiSnapMrzDob;

/*! A key to retrieve mrz date of expiry; note it's only present if MiSnapFCSSDK is integrated */
extern NSString* const kMiSnapMrzDoe;

typedef NS_ENUM(NSInteger, MiSnapResultWarningCodes)
{
	MiSnapResultWarning_NothingDetected		= 1 << 0,
	MiSnapResultWarning_TooFar				= 1 << 1,
	MiSnapResultWarning_TooDim				= 1 << 2,
	MiSnapResultWarning_TooBright			= 1 << 3,
	MiSnapResultWarning_AngleTooLarge		= 1 << 4,
	MiSnapResultWarning_NotSharp			= 1 << 5,
	MiSnapResultWarning_TooClose			= 1 << 6,
	MiSnapResultWarning_Rotation			= 1 << 7,
	MiSnapResultWarning_LowContrast		 	= 1 << 8,
	MiSnapResultWarning_BusyBackground		= 1 << 9,
	MiSnapResultWarning_Glare				= 1 << 10,
	MiSnapResultWarning_WrongDocument		= 1 << 11,
};

typedef NS_ENUM(NSInteger, MiSnapTutorialMode)
{
    MiSnapTutorialModeNone          = 0,
    MiSnapTutorialModeFirstTime     = 1,
    MiSnapTutorialModeHelp          = 2,
    MiSnapTutorialModeFailover      = 3
};
