//
//  IASDKCore.h
//  IASDKCore
//
//  Created by Digital Turbine on 29/01/2017.
//  Copyright © 2022 Digital Turbine. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

//! Project version number for IASDKCore.
FOUNDATION_EXPORT double IASDKCoreVersionNumber;

//! Project version string for IASDKCore.
FOUNDATION_EXPORT const unsigned char IASDKCoreVersionString[];

#import <IASDKCore/IAInterfaceAllocBlocker.h>
#import <IASDKCore/IAInterfaceBuilder.h>
#import <IASDKCore/IAInterfaceSingleton.h>

#import <IASDKCore/IAGlobalAdDelegate.h>

#import <IASDKCore/IAInterfaceUnitController.h>

#import <IASDKCore/IAAdSpot.h>
#import <IASDKCore/IAAdRequest.h>
#import <IASDKCore/IAUserData.h>
#import <IASDKCore/IADebugger.h>
#import <IASDKCore/IAAdModel.h>

#import <IASDKCore/IAUnitController.h>
#import <IASDKCore/IAUnitDelegate.h>
#import <IASDKCore/IAViewUnitController.h>
#import <IASDKCore/IAFullscreenUnitController.h>
#import <IASDKCore/IAContentController.h>
#import <IASDKCore/IABaseView.h>
#import <IASDKCore/IAAdView.h>
#import <IASDKCore/IAMRAIDAdView.h>

#import <IASDKCore/IAMediation.h>
#import <IASDKCore/IAMediationAdMob.h>
#import <IASDKCore/IAMediationDFP.h>
#import <IASDKCore/IAMediationFyber.h>
#import <IASDKCore/IAMediationMax.h>
#import <IASDKCore/IAMediationIronSource.h>
#import <IASDKCore/IAMediationAdmost.h>
#import <IASDKCore/IAGDPRConsent.h>
#import <IASDKCore/IALGPDConsent.h>
#import <IASDKCore/IACoppaApplies.h>
#import <IASDKCore/FMPBiddingManager.h>

#import <IASDKCore/IASDKMRAID.h>

#import <IASDKCore/IAMRAIDContentController.h>
#import <IASDKCore/IAMRAIDContentDelegate.h>
#import <IASDKCore/IAMRAIDContentModel.h>

#import <IASDKCore/IASDKVideo.h>

#import <IASDKCore/IAVideoContentController.h>
#import <IASDKCore/IAVideoContentDelegate.h>
#import <IASDKCore/IAVideoLayout.h>
#import <IASDKCore/IAVideoContentModel.h>
#import <IASDKCore/IAVideoView.h>

typedef void (^IASDKCoreInitBlock)(BOOL success, NSError * _Nullable error);

typedef NS_ENUM(NSInteger, IASDKCoreInitErrorType) {
    IASDKCoreInitErrorTypeUnknown = 0,
    IASDKCoreInitErrorTypeFailedToDownloadMandatoryData = 1,
    IASDKCoreInitErrorTypeMissingModules = 2,
    IASDKCoreInitErrorTypeInvalidAppID = 3,
    IASDKCoreInitErrorTypeCancelled = 4
};

@interface IASDKCore : NSObject <IAInterfaceSingleton>

@property (atomic, strong, nullable, readonly) NSString *appID;
@property (atomic, readonly, getter=isInitialised) BOOL initialised;
@property (atomic, strong, nullable) NSString *publisherAppStoreID; // publisher app ID in Apple’s App Store

/**
 *  @brief Use this delegate in order to get an info about every shown ad.
 */
@property (atomic, weak, nullable) id<IAGlobalAdDelegate> globalAdDelegate;

/**
 *  @brief The GDPR consent status.
 *
 *  @discussion Use this property in order to set the GDPR consent accoring to your preferences.
 *
 * It can be used as one of the following, in order to allow/restrict:
 *
 * - `[IASDKCore.sharedInstance setGDPRConsent:YES]`
 *
 * - `[IASDKCore.sharedInstance setGDPRConsent:true]`
 *
 * - `IASDKCore.sharedInstance.GDPRConsent = NO`
 *
 * - `IASDKCore.sharedInstance.GDPRConsent = 1`
 *
 * - `IASDKCore.sharedInstance.GDPRConsent = IAGDPRConsentTypeGiven`
 *
 * Or it can be cleared by using the one of the following:
 *
 * - `[IASDKCore.sharedInstance clearGDPRConsentData]`
 *
 * - `IASDKCore.sharedInstance.GDPRConsent = IAGDPRConsentTypeUnknown`. <b>Important</b>: setting the `IAGDPRConsentTypeUnknown`, will clear the `GDPRConsentString` as well.
 *
 * The default (or after calling the `clearGDPRConsentData` method) value is unknown, which is the `IAGDPRConsentTypeUnknown`.
 *
 * The property is thread-safe.
 */
@property (atomic) IAGDPRConsentType GDPRConsent;

/**
 *  @brief Use this property in order to provide a custom GDPR consent data.
 *
 *  @discussion It will be passed as is, without any management/modification.
 */
@property (atomic, nullable) NSString *GDPRConsentString;

/**
 *  @brief Use this property in order to provide the CCPA string. Once it's set, it is saved on a device.
 *
 *  @discussion It will be passed as is, without any validation/modification. In order to clear this data permanently from a device, pass a nil or empty string.
 */
@property (atomic, nullable) NSString *CCPAString;

/**
 *  @brief The LGPD consent status.
 *
 *  @discussion Use this property in order to set the LGPD consent accoring to your preferences.
 *
 * It can be used as one of the following, in order to allow/restrict:
 *
 * - `[IASDKCore.sharedInstance setLGPDConsent:YES]`
 *
 * - `[IASDKCore.sharedInstance setLGPDConsent:true]`
 *
 * - `IASDKCore.sharedInstance.LGPDConsent = NO`
 *
 * - `IASDKCore.sharedInstance.LGPDConsent = 1`
 *
 * - `IASDKCore.sharedInstance.LGPDConsent = IALGPDConsentTypeGiven`
 *
 * Or it can be cleared by using the one of the following:
 *
 * - `[IASDKCore.sharedInstance clearLGPDConsentData]`
 *
 * - `IASDKCore.sharedInstance.LGPDConsent = IALGPDConsentTypeUnknown`. <b>Important</b>: setting the `IALGPDConsentTypeUnknown`, will clear the `LGPDConsentString` as well.
 *
 * The default (or after calling the `clearLGPDConsentData` method) value is unknown, which is the `IALGPDConsentTypeUnknown`.
 *
 * The property is thread-safe.
 */
@property (atomic) IALGPDConsentType LGPDConsent;


/**
 *  @brief The COPPA complience status.
 *
 *  @discussion Use this property in order to set the COPPA complience accoring to your preferences.
 *
 * It can be used as one of the following, in order to allow/restrict:
 *
 * - `[IASDKCore.sharedInstance setCoppaApplies:YES]`
 *
 * - `[IASDKCore.sharedInstance setCoppaApplies:true]`
 *
 * - `IASDKCore.sharedInstance.coppaApplies = NO`
 *
 * - `IASDKCore.sharedInstance.coppaApplies = 1`
 *
 * - `IASDKCore.sharedInstance.setCoppaApplies = IACoppaAppliesTypeGiven`
 *
 * Or it can be cleared by using the following:
 *
 * - `IASDKCore.sharedInstance.coppaApplies = IACoppaAppliesTypeUnknown`.
 *
 * The default value is unknown, which is the `IACoppaAppliesTypeUnknown`.
 *
 * The property is thread-safe.
 */
@property (atomic) IACoppaAppliesType coppaApplies;

/**
 *  @brief Use this property in order to provide a user Id. Once it's set, it is saved on a device.
 *
 *  @discussion It will be passed as is, without any validation/modification. In order to clear it from a device, pass a nil or empty string.
 */
@property (atomic, nullable) NSString *userID;

/**
 *  @brief Use userData for better ad targeting.
 *  @discussion This userData will be used in bidding flow, while bidding token creation.
 */
@property (nonatomic, nullable) IAUserData *userData;

/**
 *  @brief Single keyword string or several keywords, separated by comma.
 *  @discussion These keywords will be used in bidding flow, while bidding token creation.
 */
@property (nonatomic, nullable) NSString *keywords;

/**
 *  @brief In case is enabled and the responded creative supports this feature, the creative will start interacting without sound.
 *  @discussion This value will be used in bidding flow, while bidding token creation.
 */
@property (nonatomic) BOOL muteAudio;

/**
 *  @brief Indicates which SDK is mediating Fyber. Mediation type value set for IAAdSpot will be checked before and used if there was any set.
 *  @discussion This value will be used in bidding flow, while bidding token creation.
 */
@property (nonatomic, nullable) IAMediation *mediationType;

/**
 *  @brief Can be used in order to get test ads in bidding flow.
 */
@property (nonatomic, strong, nullable) IADebugger *debugger;

/**
 *  @brief Singleton method, use for any instance call.
 */
+ (instancetype _Null_unspecified)sharedInstance;

/**
 *  @brief Initialisation of the SDK. Must be invoked before requesting the ads.
 *
 *  @discussion Should be invoked on the main thread. Otherwise it will convert the flow to the main thread. Is asynchronous method.
 *
 *  @param appID A required param. Must be a valid application ID, otherwise the SDK will not be able to request/render the ads.
 */
- (void)initWithAppID:(NSString * _Nonnull)appID;

/**
 *  @brief Initialisation of the SDK. Must be invoked before requesting the ads.
 *
 *  @discussion Should be invoked on the main thread. Otherwise it will convert the flow to the main thread. Is asynchronous method.
 *
 *  @param appID A required param. Must be a valid application ID, otherwise the SDK will not be able to request/render the ads.
 *
 *  @param completionBlock An optional callback for the init result notification. The error code is represented as `IASDKCoreInitErrorType` enum.
 *
 *  @param completionQueue An optional queue for the completion block. If is not provided, the completion block will be invoked on the main queue.
 */
- (void)initWithAppID:(NSString * _Nonnull)appID
      completionBlock:(IASDKCoreInitBlock _Nullable)completionBlock
      completionQueue:(dispatch_queue_t _Nullable)completionQueue;

/**
 *  @brief Get the IASDK current version as the NSString instance.
 *
 *  @discussion The format is `x.y.z`.
 */
- (NSString * _Null_unspecified)version;

/**
 *  @brief Clears all the GDPR related information. The state of the `GDPRConsent` property will become `-1` or `IAGDPRConsentTypeUnknown`.
 */
- (void)clearGDPRConsentData;

/**
 *  @brief Clears all the LGPD related information. The state of the `LGPDConsent` property will become `-1` or `IALGPDConsentTypeUnknown`.
 */
- (void)clearLGPDConsentData;

/**
 *  @brief Enable in order to manage audio session on behalf of SDK.
 *
 *  @discussion Resolves an occasional issue wnen there is no sound in VAST in iPadOS 16.1+ on certain iPads, in case AVAudioSession isn't managed explicitly in host app.
 *  This method isn't thread-safe and should be used immediately after SDK init.
 */
- (void)enableAutomaticAudioSessionManagement;

@end
