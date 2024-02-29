//
//  MiSnapResults.h
//  MiSnap
//
//  Created by Stas Tsuprenko on 10/14/2020.
//  Copyright © 2020 Mitek Systems Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MiSnapCore/MiSnapCore.h>
#import <MiSnapScience/MiSnapScienceIQAResult.h>
#import <MiSnapScience/MiSnapScienceClassificationResult.h>
#import <MiSnapScience/MiSnapScienceExtractionResult.h>

NS_ASSUME_NONNULL_BEGIN

/**
 Frame status
 */
typedef NS_ENUM(NSInteger, MiSnapStatus) {
    /**
     Status is not set
     */
    MiSnapStatusNone                        = 0,
    /**
     A document has too much glare
     */
    MiSnapStatusTooMuchGlare                = 1,
    /**
     Front of identity document is expected but some other document is found
     
     Requires `MiSnapLicenseFeatureODC` to be supported
     */
    MiSnapStatusNotIdentityFront            = 2,
    /**
     Back of identity document is expected but some other document is found
     
     Requires `MiSnapLicenseFeatureODC` to be supported
     */
    MiSnapStatusNotIdentityBack             = 3,
    /**
     Passport is expected but some other document is found
     
     Requires `MiSnapLicenseFeatureODC` to be supported
     */
    MiSnapStatusNotPassport                 = 4,
    /**
     Check Front is expected but some other document is found
     */
    MiSnapStatusNotCheckFront               = 5,
    /**
     Check Back is expected but Check Front is found
     */
    MiSnapStatusNotCheckBack                = 6,
    /**
     1-line MRZ of EU DL is obstructed
     */
    MiSnapStatusMrzObstructed               = 7,
    /**
     A document is not found
     */
    MiSnapStatusDocumentNotFound            = 8,
    /**
     A document and background have insufficient contrast
     for corners to be accurately found
     */
    MiSnapStatusLowContrast                 = 9,
    /**
     Background has to many lines that can be confused for a document edge
     */
    MiSnapStatusBusyBackground              = 10,
    /**
     A document is too rotated relative to a guide
     */
    MiSnapStatusTooRotated                  = 11,
    /**
     A document is tilted so that one side is much closer to a camera than others
     */
    MiSnapStatusTooSkewed                   = 12,
    /**
     A document is too far
     */
    MiSnapStatusTooFar                      = 13,
    /**
     A document is too close
     */
    MiSnapStatusTooClose                    = 14,
    /**
     Insufficient lighting conditions
     */
    MiSnapStatusTooDark                     = 15,
    /**
     Too bright lighting conditions
     */
    MiSnapStatusTooBright                   = 16,
    /**
     Document is not sharp
     
     Either a camera is being focused or
     a document is in excessive motion
     */
    MiSnapStatusNotSharp                    = 17,
    /**
     A document with a wrong aspect ratio is found
     */
    MiSnapStatusWrongAspectRatio            = 18,
    /**
     A frame passed all Image Quality Analysis (IQA) checks but
     on-device classification is still in progress
     */
    MiSnapStatusClassificationInProgress    = 19,
    /**
     A frame passed all Image Quality Analysis (IQA) checks and
     on-device classification is completed
     */
    MiSnapStatusGood                        = 20
};
/**
 Result code
 */
typedef NS_ENUM(NSInteger, MiSnapResultCode) {
    /**
     Result code is not set
     */
    MiSnapResultCodeNone                  = 0,
    /**
     A session was completed by manually acquiring an image
     */
    MiSnapResultCodeSuccessStillCamera    = 1,
    /**
     A session was completed by automatically acquiring an image that passed Image Quality Analysis checks
     */
    MiSnapResultCodeSuccessVideo          = 2,
    /**
     A session was cancelled by a user
     */
    MiSnapResultCodeCancelled             = 3
};
/**
 Frame analysis result
 */
@interface MiSnapResult : NSObject
/**
 An acquired image
 */
@property (nonatomic, readonly) UIImage * _Nullable image;
/**
 Base64 representation of an acquired image that should be sent to the server for processing
 */
@property (nonatomic, readonly) NSString * _Nullable encodedImage;
/**
 An encrypted payload used for an additional authentication
 */
@property (nonatomic, readonly) NSString * _Nullable rts;
/**
 A string containing non-PII session analytics
 */
@property (nonatomic, readonly) NSString * _Nullable mibiDataString DEPRECATED_MSG_ATTRIBUTE("Use `mibi` property instead");
/**
 An object containing non-PII session analytics
 */
@property (nonatomic, readonly) MiSnapMibi * _Nonnull mibi;
/**
 Image Quality Analysis result
 */
@property (nonatomic, readonly) MiSnapScienceIQAResult * _Nonnull iqa;
/**
 Classification result
 */
@property (nonatomic, readonly) MiSnapScienceClassificationResult * _Nonnull classification;
/**
 Extraction result
 */
@property (nonatomic, readonly) MiSnapScienceExtractionResult * _Nullable extraction;
/**
 A session result code
 */
@property (nonatomic, readonly) MiSnapResultCode resultCode;
/**
 Frame statuses ordered based on priority
 
 @see `MiSnapStatus`
 */
@property (nonatomic, readonly) NSArray * _Nonnull orderedStatuses;
/**
 The highest priority frame status
 
 @see `MiSnapStatus`
 */
@property (nonatomic, readonly) MiSnapStatus highestPriorityStatus;
/**
 A convenience method for getting a string representation of `MiSnapResultCode` value
 */
+ (NSString *)stringFromMiSnapResultCode:(MiSnapResultCode)resultCode;
/**
 A convenience method for getting a string representation of `MiSnapStatus` value
 */
+ (NSString *)stringFromMiSnapStatus:(MiSnapStatus)status;
/**
 A convenience method for getting a string code representation of `MiSnapStatus` value
 */
+ (NSString *)codeFromMiSnapStatus:(MiSnapStatus)status;

@end

NS_ASSUME_NONNULL_END
