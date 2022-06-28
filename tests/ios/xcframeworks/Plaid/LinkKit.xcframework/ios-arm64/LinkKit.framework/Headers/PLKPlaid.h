#import <UIKit/UIKit.h>

/// PLKPlaid.h exposes an Objective-C API to interact with LinkKit. The Swift API is the preferred means of integration, so
/// prefer to use the Swift API where possible.

typedef NSString PLKRawJSONMetadata;
typedef NSString PLKLanguage;
typedef NSString PLKCountryCode;

/// An NSError instance containing metadata about the error. The domain will be a kPLKExitErrorDomain value
/// and the code will be a case in the enum associated with that domain. For example, an API error will have
/// the domain value be kPLKExitErrorApiDomain and the code will be a case in the PLKApiErrorCode enum.
/// NOTE: To ensure forwards compatability, if the server returns an error in a domain that's not yet
/// supported by LinkKit it will have a domain of PLKExitErrorDomainUnknownError, a code of `-1`, and
/// an NSString * value in its userInfo dictionary for the kPLKExitErrorUnknownDomainCodeKey key.
typedef NSError PLKExitError;

typedef NS_ENUM(NSInteger, PLKProduct) {
    PLKProductAssets,
    PLKProductAuth,
    PLKProductDepositSwitch,
    PLKProductIdentity,
    PLKProductIncome,
    PLKProductInvestments,
    PLKProductLiabilities,
    PLKProductLiabilitiesReport,
    PLKProductPaymentInitiation,
    PLKProductTransactions,
    // Add new enum cases directly above this line to avoid breaking API changes
};

typedef NS_ENUM(NSInteger, PLKVerificationStatusValue) {
    PLKVerificationStatusValueNone = -1,
    PLKVerificationStatusValuePendingAutomaticVerification,
    PLKVerificationStatusValuePendingManualVerification,
    PLKVerificationStatusValueManuallyVerified,
    // Add new enum cases directly above this line to avoid breaking API changes
};

typedef NS_ENUM(NSInteger, PLKEventNameValue) {
    PLKEventNameValueNone = -1,
    PLKEventNameValueCloseOAuth,
    PLKEventNameValueError,
    PLKEventNameValueExit,
    PLKEventNameValueFailOAuth,
    PLKEventNameValueHandoff,
    PLKEventNameValueOpen,
    PLKEventNameValueOpenMyPlaid,
    PLKEventNameValueOpenOAuth,
    PLKEventNameValueSearchInstitution,
    PLKEventNameValueSelectInstitution,
    PLKEventNameValueSubmitCredentials,
    PLKEventNameValueSubmitMFA,
    PLKEventNameValueTransitionView,
    PLKEventNameValueMatchedSelectInstitution,
    PLKEventNameValueMatchedSelectVerifyMethod,
    PLKEventNameValueBankIncomeInsightsCompleted,
    PLKEventNameValueSelectDegradedInstitution,
    PLKEventNameValueSelectDownInstitution,
    PLKEventNameValueIdentityVerificationStartStep,
    PLKEventNameValueIdentityVerificationPassStep,
    PLKEventNameValueIdentityVerificationFailStep,
    PLKEventNameValueIdentityVerificationPendingReviewStep,
    PLKEventNameValueIdentityVerificationCreateSession,
    PLKEventNameValueIdentityVerificationResumeSession,
    PLKEventNameValueIdentityVerificationPassSession,
    PLKEventNameValueIdentityVerificationFailSession,
    PLKEventNameValueIdentityVerificationOpenUI,
    PLKEventNameValueIdentityVerificationResumeUI,
    PLKEventNameValueIdentityVerificationCloseUI,
    // Add new enum cases directly above this line to avoid breaking API changes
};


typedef NS_ENUM(NSInteger, PLKExitStatusValue) {
    PLKExitStatusValueNone = -1,
    PLKExitStatusValueRequiresQuestions,
    PLKExitStatusValueRequiresSelections,
    PLKExitStatusValueRequiresCode,
    PLKExitStatusValueChooseDevice,
    PLKExitStatusValueRequiresCredentials,
    PLKExitStatusValueInstitutionNotFound,
    PLKExitStatusValueRequiresAccountSelection,
    // Add new enum cases directly above this line to avoid breaking API changes
};

typedef NS_ENUM(NSInteger, PLKMFAType) {
    PLKMFATypeNone = -1,
    PLKMFATypeCode,
    PLKMFATypeDevice,
    PLKMFATypeQuestions,
    PLKMFATypeSelections,
    // Add new enum cases directly above this line to avoid breaking API changes
};

typedef NS_ENUM(NSInteger, PLKViewNameValue) {
    PLKViewNameValueNone = -1,
    PLKViewNameValueConnected,
    PLKViewNameValueConsent,
    PLKViewNameValueCredential,
    PLKViewNameValueError,
    PLKViewNameValueExit,
    PLKViewNameValueLoading,
    PLKViewNameValueMFA,
    PLKViewNameValueNumbers,
    PLKViewNameValueRecaptcha,
    PLKViewNameValueSelectAccount,
    PLKViewNameValueSelectInstitution,
    PLKViewNameValueMatchedConsent,
    PLKViewNameValueMatchedCredential,
    PLKViewNameValueMatchedMFA,
    PLKViewNameValueUploadDocuments,
    PLKViewNameValueSubmitDocuments,
    PLKViewNameValueSubmitDocumentsSuccess,
    PLKViewNameValueSubmitDocumentsError,
    PLKViewNameValueOauth,
    PLKViewNameValueAcceptTOS,
    PLKViewNameValueDocumentaryVerification,
    PLKViewNameValueKYCCheck,
    PLKViewNameValueSelfieCheck,
    PLKViewNameValueRiskCheck,
    PLKViewNameValueScreening,
    PLKViewNameValueVerifySMS,
    // Add new enum cases directly above this line to avoid breaking API changes
};

typedef NS_ENUM(NSInteger, PLKAccountSubtypeValueOther) {
    PLKAccountSubtypeValueOtherNone = -1,
    PLKAccountSubtypeValueOtherAll,
    PLKAccountSubtypeValueOtherOther,
    // Add new enum cases directly above this line to avoid breaking API changes
};

typedef NS_ENUM(NSInteger, PLKAccountSubtypeValueCredit) {
    PLKAccountSubtypeValueCreditNone = -1,
    PLKAccountSubtypeValueCreditAll,
    PLKAccountSubtypeValueCreditCreditCard,
    PLKAccountSubtypeValueCreditPaypal,
    // Add new enum cases directly above this line to avoid breaking API changes
};

typedef NS_ENUM(NSInteger, PLKAccountSubtypeValueLoan) {
    PLKAccountSubtypeValueLoanNone = -1,
    PLKAccountSubtypeValueLoanAll,
    PLKAccountSubtypeValueLoanAuto,
    PLKAccountSubtypeValueLoanBusiness,
    PLKAccountSubtypeValueLoanCommercial,
    PLKAccountSubtypeValueLoanConstruction,
    PLKAccountSubtypeValueLoanConsumer,
    PLKAccountSubtypeValueLoanHomeEquity,
    PLKAccountSubtypeValueLoanLineOfCredit,
    PLKAccountSubtypeValueLoanLoan,
    PLKAccountSubtypeValueLoanMortgage,
    PLKAccountSubtypeValueLoanOverdraft,
    PLKAccountSubtypeValueLoanStudent,
    // Add new enum cases directly above this line to avoid breaking API changes
};

typedef NS_ENUM(NSInteger, PLKAccountSubtypeValueDepository) {
    PLKAccountSubtypeValueDepositoryNone = -1,
    PLKAccountSubtypeValueDepositoryAll,
    PLKAccountSubtypeValueDepositoryCashManagement,
    PLKAccountSubtypeValueDepositoryCd,
    PLKAccountSubtypeValueDepositoryChecking,
    PLKAccountSubtypeValueDepositoryEbt,
    PLKAccountSubtypeValueDepositoryHsa,
    PLKAccountSubtypeValueDepositoryMoneyMarket,
    PLKAccountSubtypeValueDepositoryPaypal,
    PLKAccountSubtypeValueDepositoryPrepaid,
    PLKAccountSubtypeValueDepositorySavings,
    // Add new enum cases directly above this line to avoid breaking API changes
};

typedef NS_ENUM(NSInteger, PLKAccountSubtypeValueInvestment) {
    PLKAccountSubtypeValueInvestmentNone = -1,
    PLKAccountSubtypeValueInvestmentAll,
    PLKAccountSubtypeValueInvestment401a,
    PLKAccountSubtypeValueInvestment401k,
    PLKAccountSubtypeValueInvestment403B,
    PLKAccountSubtypeValueInvestment457b,
    PLKAccountSubtypeValueInvestment529,
    PLKAccountSubtypeValueInvestmentBrokerage,
    PLKAccountSubtypeValueInvestmentCashIsa,
    PLKAccountSubtypeValueInvestmentEducationSavingsAccount,
    PLKAccountSubtypeValueInvestmentFixedAnnuity,
    PLKAccountSubtypeValueInvestmentGic,
    PLKAccountSubtypeValueInvestmentHealthReimbursementArrangement,
    PLKAccountSubtypeValueInvestmentHsa,
    PLKAccountSubtypeValueInvestmentIra,
    PLKAccountSubtypeValueInvestmentIsa,
    PLKAccountSubtypeValueInvestmentKeogh,
    PLKAccountSubtypeValueInvestmentLif,
    PLKAccountSubtypeValueInvestmentLira,
    PLKAccountSubtypeValueInvestmentLrif,
    PLKAccountSubtypeValueInvestmentLrsp,
    PLKAccountSubtypeValueInvestmentMutualFund,
    PLKAccountSubtypeValueInvestmentNonTaxableBrokerageAccount,
    PLKAccountSubtypeValueInvestmentPension,
    PLKAccountSubtypeValueInvestmentPlan,
    PLKAccountSubtypeValueInvestmentPrif,
    PLKAccountSubtypeValueInvestmentProfitSharingPlan,
    PLKAccountSubtypeValueInvestmentRdsp,
    PLKAccountSubtypeValueInvestmentResp,
    PLKAccountSubtypeValueInvestmentRetirement,
    PLKAccountSubtypeValueInvestmentRlif,
    PLKAccountSubtypeValueInvestmentRoth401k,
    PLKAccountSubtypeValueInvestmentRoth,
    PLKAccountSubtypeValueInvestmentRrif,
    PLKAccountSubtypeValueInvestmentRrsp,
    PLKAccountSubtypeValueInvestmentSarsep,
    PLKAccountSubtypeValueInvestmentSepIra,
    PLKAccountSubtypeValueInvestmentSimpleIra,
    PLKAccountSubtypeValueInvestmentSipp,
    PLKAccountSubtypeValueInvestmentStockPlan,
    PLKAccountSubtypeValueInvestmentTfsa,
    PLKAccountSubtypeValueInvestmentThriftSavingsPlan,
    PLKAccountSubtypeValueInvestmentTrust,
    PLKAccountSubtypeValueInvestmentUgma,
    PLKAccountSubtypeValueInvestmentUtma,
    PLKAccountSubtypeValueInvestmentVariableAnnuity,
    // Add new enum cases directly above this line to avoid breaking API changes
};

typedef NS_ENUM(NSInteger, PLKApiErrorCode) {
    PLKApiErrorCodeInternalServerError,
    PLKApiErrorCodePlannedMaintenance
    // Add new enum cases directly above this line to avoid breaking API changes
};

typedef NS_ENUM(NSInteger, PLKInvalidRequestErrorCode) {
    PLKInvalidRequestErrorCodeMissingFields,
    PLKInvalidRequestErrorCodeUnknownFields,
    PLKInvalidRequestErrorCodeInvalidField,
    PLKInvalidRequestErrorCodeInvalidBody,
    PLKInvalidRequestErrorCodeInvalidAddress,
    PLKInvalidRequestErrorCodeNotFound,
    PLKInvalidRequestErrorCodeSandboxOnly,
    // Add new enum cases directly above this line to avoid breaking API changes
};

typedef NS_ENUM(NSInteger, PLKInvalidInputErrorCode) {
    PLKInvalidInputErrorCodeInvalidApiKeys,
    PLKInvalidInputErrorCodeUnauthorizedEnvironment,
    PLKInvalidInputErrorCodeInvalidAccessToken,
    PLKInvalidInputErrorCodeInvalidPublicToken,
    PLKInvalidInputErrorCodeInvalidProduct,
    PLKInvalidInputErrorCodeInvalidAccountId,
    PLKInvalidInputErrorCodeInvalidInstitution,
    PLKInvalidInputErrorCodeTooManyVerificationAttempts,
    // Add new enum cases directly above this line to avoid breaking API changes
};

typedef NS_ENUM(NSInteger, PLKInstitutionErrorCode) {
    PLKInstitutionErrorCodeInstitutionDown,
    PLKInstitutionErrorCodeInstitutionNotResponding,
    PLKInstitutionErrorCodeInstitutionNotAvailable,
    PLKInstitutionErrorCodeInstitutionNoLongerSupported,
    // Add new enum cases directly above this line to avoid breaking API changes
};

typedef NS_ENUM(NSInteger, PLKRateLimitErrorCode) {
    PLKRateLimitErrorCodeAccountsLimit,
    PLKRateLimitErrorCodeAdditionLimit,
    PLKRateLimitErrorCodeAuthLimit,
    PLKRateLimitErrorCodeIdentityLimit,
    PLKRateLimitErrorCodeIncomeLimit,
    PLKRateLimitErrorCodeItemGetLimit,
    PLKRateLimitErrorCodeRateLimit,
    PLKRateLimitErrorCodeTransactionsLimit,
    // Add new enum cases directly above this line to avoid breaking API changes
};

typedef NS_ENUM(NSInteger, PLKItemErrorCode) {
    PLKItemErrorCodeInsufficientCredentials,
    PLKItemErrorCodeInvalidCredentials,
    PLKItemErrorCodeInvalidMfa,
    PLKItemErrorCodeInvalidSendMethod,
    PLKItemErrorCodeInvalidUpdatedUsername,
    PLKItemErrorCodeItemLocked,
    PLKItemErrorCodeItemLoginRequired,
    PLKItemErrorCodeItemNoError,
    PLKItemErrorCodeItemNotSupported,
    PLKItemErrorCodeIncorrectDepositAmounts,
    PLKItemErrorCodeUserSetupRequired,
    PLKItemErrorCodeMfaNotSupported,
    PLKItemErrorCodeNoAccounts,
    PLKItemErrorCodeNoAuthAccounts,
    PLKItemErrorCodeNoInvestmentAccounts,
    PLKItemErrorCodeNoLiabilityAccounts,
    PLKItemErrorCodeProductNotReady,
    PLKItemErrorCodeProductsNotSupported,
    PLKItemErrorCodeInstantMatchFailed,
    // Add new enum cases directly above this line to avoid breaking API changes
};

typedef NS_ENUM(NSInteger, PLKAuthErrorCode) {
    PLKAuthErrorCodeProductNotReady,
    PLKAuthErrorCodeVerificationExpired,
    // Add new enum cases directly above this line to avoid breaking API changes
};

typedef NS_ENUM(NSInteger, PLKAssetReportErrorCode) {
    PLKAssetReportErrorCodeProductNotEnabled,
    PLKAssetReportErrorCodeDataUnavailable,
    PLKAssetReportErrorCodeProductNotReady,
    PLKAssetReportErrorCodeAssetReportGenerationFailed,
    PLKAssetReportErrorCodeInvalidParent,
    PLKAssetReportErrorCodeInsightsNotEnabled,
    PLKAssetReportErrorCodeInsightsPreviouslyNotEnabled,
    // Add new enum cases directly above this line to avoid breaking API changes
};

NS_ASSUME_NONNULL_BEGIN

static NSString *const kPLKExitErrorMessageKey = @"PLKExitErrorMessageKey";
static NSString *const kPLKExitErrorDisplayMessageKey = @"PLKExitErrorDisplayMessageKey";
static NSString *const kPLKExitErrorRawJSONKey = @"PLKExitErrorRawJSONKey";
static NSString *const kPLKExitErrorUnknownTypeKey = @"kPLKExitErrorUnknownTypeKey";
static NSString *const kPLKExitErrorCodeKey = @"kPLKExitErrorCodeKey";

static NSString *const kPLKExitErrorInvalidRequestDomain = @"PLKExitErrorInvalidRequestDomain";
static NSString *const kPLKExitErrorInvalidInputDomain = @"PLKExitErrorInvalidInputDomain";
static NSString *const kPLKExitErrorInstitutionErrorDomain = @"PLKExitErrorInstitutionErrorDomain";
static NSString *const kPLKExitErrorRateLimitExceededDomain = @"PLKExitErrorRateLimitExceededDomain";
static NSString *const kPLKExitErrorApiDomain = @"PLKExitErrorApiDomain";
static NSString *const kPLKExitErrorItemDomain = @"PLKExitErrorItemDomain";
static NSString *const kPLKExitErrorAuthDomain = @"PLKExitErrorAuthDomain";
static NSString *const kPLKExitErrorAssetReportDomain = @"PLKExitErrorAssetReportDomain";
static NSString *const kPLKExitErrorInternalDomain = @"PLKExitErrorInternalDomain";
static NSString *const kPLKExitErrorUnknownDomain = @"PLKExitErrorUnknownDomain";
static NSString *const kPLKDefaultErrorDomain = @"com.plaid.link";

@interface PLKVerificationStatus : NSObject

/// If the server returned a verification status value the SDK is not aware of, unknownStringValue will be non-nil
@property(nonatomic, readonly, nullable, copy) NSString *unknownStringValue;
@property(nonatomic, readonly) PLKVerificationStatusValue value;

@end

@interface PLKEventName : NSObject

/// If the server returned an event name value the SDK is not aware of, unknownStringValue will be non-nil
@property(nonatomic, readonly, nullable, copy) NSString *unknownStringValue;
@property(nonatomic, readonly) PLKEventNameValue value;

@end

@interface PLKViewName : NSObject

/// If the server returned an event name value the SDK is not aware of, unknownStringValue will be non-nil
@property(nonatomic, readonly, nullable, copy) NSString *unknownStringValue;
@property(nonatomic, readonly) PLKViewNameValue value;

@end

@interface PLKExitStatus : NSObject

/// If the server returned an event name value the SDK is not aware of, unknownStringValue will be non-nil
@property(nonatomic, readonly, nullable, copy) NSString *unknownStringValue;
@property(nonatomic, readonly) PLKExitStatusValue value;

@end

@protocol PLKAccountSubtype <NSObject>

@property(nonatomic, readonly, nullable, copy) NSString *rawStringValue;

@end

@interface PLKAccountSubtypeUnknown : NSObject <PLKAccountSubtype>

@property(nonatomic, readonly, nullable, copy) NSString *rawSubtypeStringValue;

+ (instancetype)createWithRawTypeStringValue:(NSString *)rawTypeStringValue
                       rawSubtypeStringValue:(NSString *)rawTypeSubStringValue;

@end

@interface PLKAccountSubtypeOther : NSObject <PLKAccountSubtype>

+ (instancetype)createWithValue:(PLKAccountSubtypeValueOther)value;
+ (instancetype)createWithRawStringValue:(NSString *)rawStringValue;

@end

@interface PLKAccountSubtypeCredit : NSObject <PLKAccountSubtype>

@property(nonatomic, readonly) PLKAccountSubtypeValueCredit subtype;

+ (instancetype)createWithValue:(PLKAccountSubtypeValueCredit)value;
+ (instancetype)createWithUnknownValue:(NSString *)unknownValue;

@end

@interface PLKAccountSubtypeLoan : NSObject <PLKAccountSubtype>

@property(nonatomic, readonly) PLKAccountSubtypeValueLoan subtype;

+ (instancetype)createWithValue:(PLKAccountSubtypeValueLoan)value;
+ (instancetype)createWithUnknownValue:(NSString *)unknownValue;

@end

@interface PLKAccountSubtypeDepository : NSObject <PLKAccountSubtype>

@property(nonatomic, readonly) PLKAccountSubtypeValueDepository subtype;

+ (instancetype)createWithValue:(PLKAccountSubtypeValueDepository)value;
+ (instancetype)createWithUnknownValue:(NSString *)unknownValue;

@end

@interface PLKAccountSubtypeInvestment : NSObject <PLKAccountSubtype>

@property(nonatomic, readonly) PLKAccountSubtypeValueInvestment subtype;

+ (instancetype)createWithValue:(PLKAccountSubtypeValueInvestment)value;
+ (instancetype)createWithUnknownValue:(NSString *)unknownValue;

@end

@interface PLKInstitution : NSObject

@property(nonatomic, readonly, copy) NSString *name;
@property(nonatomic, readonly, copy) NSString *ID;

- (instancetype)init NS_UNAVAILABLE;

@end

@interface PLKAccount : NSObject

@property(nonatomic, readonly, copy) NSString *ID;
@property(nonatomic, readonly, copy) NSString *name;
@property(nonatomic, readonly, nullable, copy) NSString *mask;
@property(nonatomic, readonly) id<PLKAccountSubtype> subtype;
@property(nonatomic, readonly, nullable) PLKVerificationStatus *verificationStatus;

- (instancetype)init NS_UNAVAILABLE;

@end

@interface PLKSuccessMetadata : NSObject

@property(nonatomic, readonly, copy) NSString *linkSessionID;
@property(nonatomic, readonly) PLKInstitution *institution;
@property(nonatomic, readonly, copy) NSArray<PLKAccount *> *accounts;
@property(nonatomic, readonly, nullable, copy) PLKRawJSONMetadata *metadataJSON;

- (instancetype)init NS_UNAVAILABLE;

@end

@interface PLKLinkSuccess : NSObject

@property(nonatomic, readonly, copy) NSString *publicToken;
@property(nonatomic, readonly) PLKSuccessMetadata *metadata;

- (instancetype)initWithPublicToken:(NSString *)publicToken
                           metadata:(PLKSuccessMetadata *)metadata NS_DESIGNATED_INITIALIZER;
- (instancetype)init NS_UNAVAILABLE;

@end

@interface PLKExitMetadata : NSObject

@property(nonatomic, readonly, nullable) PLKExitStatus *status;
@property(nonatomic, readonly, nullable) PLKInstitution *institution;
@property(nonatomic, readonly, copy) NSString *requestID;
@property(nonatomic, readonly, copy) NSString *linkSessionID;
@property(nonatomic, readonly, nullable) PLKRawJSONMetadata *metadataJSON;

- (instancetype)init NS_UNAVAILABLE;

@end

@interface PLKLinkExit : NSObject

@property(nonatomic, readonly, nullable) NSError *error;
@property(nonatomic, readonly) PLKExitMetadata *metadata;

- (instancetype)initWithError:(NSError * __nullable)error
                     metadata:(PLKExitMetadata *)metadata NS_DESIGNATED_INITIALIZER;
- (instancetype)init NS_UNAVAILABLE;

@end

@interface PLKEventMetadata : NSObject

@property(nonatomic, readonly, nullable) PLKExitError *error;
@property(nonatomic, readonly, nullable) PLKExitStatus *exitStatus;
@property(nonatomic, readonly, nullable, copy) NSString *institutionID;
@property(nonatomic, readonly, nullable, copy) NSString *institutionName;
@property(nonatomic, readonly, nullable, copy) NSString *institutionSearchQuery;
@property(nonatomic, readonly, copy) NSString *linkSessionID;
@property(nonatomic, readonly) PLKMFAType mfaType;
@property(nonatomic, readonly, nullable, copy) NSString *requestID;
@property(nonatomic, readonly) NSDate *timestamp;
@property(nonatomic, readonly, nullable) PLKViewName *viewName;
@property(nonatomic, readonly) PLKRawJSONMetadata *metadataJSON;

- (instancetype)init NS_UNAVAILABLE;

@end

@interface PLKLinkEvent : NSObject

@property(nonatomic, readonly) PLKEventName *eventName;
@property(nonatomic, readonly) PLKEventMetadata *eventMetadata;

- (instancetype)init NS_UNAVAILABLE;

@end

typedef void(^PLKOnSuccessHandler)(PLKLinkSuccess *);
typedef void(^PLKOnExitHandler)(PLKLinkExit *);
typedef void(^PLKOnEventHandler)(PLKLinkEvent *);

@interface PLKLinkTokenConfiguration : NSObject

@property(nonatomic, copy, readonly) NSString *token;
/// A BOOL indicating that Link should skip displaying a loading animation and Link UI will be presented once it is fully loaded.
/// This can be used to display custom loading UI while Link content is loading (and will skip any initial loading UI in Link).
/// Note: Dismiss custom loading UI on the OPEN & EXIT events.
///
/// Note: This should be set to `YES` when setting the `eu_config.headless` field in /link/token/create requests to `true`.
/// For reference, see https://plaid.com/docs/api/tokens/#link-token-create-request-eu-config-headless
@property(nonatomic) BOOL noLoadingState;
@property(nonatomic) PLKOnSuccessHandler onSuccess;
@property(nonatomic, strong) PLKOnExitHandler onExit;
@property(nonatomic, strong) PLKOnEventHandler onEvent;

- (instancetype)initWithToken:(NSString *)token onSuccess:(PLKOnSuccessHandler)successHandler NS_DESIGNATED_INITIALIZER;
- (instancetype)init NS_UNAVAILABLE;
+ (instancetype)createWithToken:(NSString *)token onSuccess:(PLKOnSuccessHandler)successHandler;

@end

@interface PLKOAuthNonceConfiguration : NSObject

@property(nonatomic, readonly, copy) NSString *nonce;
@property(nonatomic, readonly) NSURL *redirectUri;

- (instancetype)initWithNonce:(NSString *)nonce
                  redirectUri:(NSURL *)redirectUri NS_DESIGNATED_INITIALIZER;
- (instancetype)init NS_UNAVAILABLE;
+ (instancetype)createWithNonce:(NSString *)nonce
                    redirectUri:(NSURL *)redirectUri;

@end

@interface PLKLinkPublicKeyConfigurationToken : NSObject

@property(nonatomic, readonly, copy) NSString *publicKey;
@property(nonatomic, readonly, nullable, copy) NSString *paymentToken;
@property(nonatomic, readonly, nullable, copy) NSString *publicToken;
@property(nonatomic, readonly, nullable, copy) NSString *depositSwitchToken;

+ (instancetype)createWithPaymentToken:(NSString *)paymentToken
                             publicKey:(NSString *)publicKey;

+ (instancetype)createWithPublicToken:(NSString *)publicToken
                            publicKey:(NSString *)publicKey;

+ (instancetype)createWithDepositSwitchToken:(NSString *)depositSwitchToken
                                   publicKey:(NSString *)publicKey;

+ (instancetype)createWithPublicKey:(NSString *)publicKey;

@end

typedef NS_ENUM(NSInteger, PLKEnvironment) {
    PLKEnvironmentProduction,
    PLKEnvironmentDevelopment,
    PLKEnvironmentSandbox,
};

@interface PLKLinkPublicKeyConfiguration : NSObject

@property(nonatomic, readonly, copy) NSString *clientName;
@property(nonatomic, readonly) PLKEnvironment environment;

@property(nonatomic, copy) PLKLanguage *language;
@property(nonatomic, strong) PLKLinkPublicKeyConfigurationToken *token;
@property(nonatomic, copy) NSArray<PLKCountryCode *> *countryCodes;

@property(nonatomic) PLKOnSuccessHandler onSuccess;
@property(nonatomic, strong) PLKOnExitHandler onExit;
@property(nonatomic, strong) PLKOnEventHandler onEvent;

@property(nonatomic, copy) NSArray<id<PLKAccountSubtype>> *accountSubtypes;

@property(nonatomic, nullable) NSURL *webhook;

@property(nonatomic, nullable) PLKOAuthNonceConfiguration *oauthConfiguration;

@property(nonatomic, nullable, copy) NSString *userLegalName;
@property(nonatomic, nullable, copy) NSString *userEmailAddress;
@property(nonatomic, nullable, copy) NSString *userPhoneNumber;

@property(nonatomic, nullable, copy) NSString *linkCustomizationName;

/// An array of PLKProduct enum cases wrapped in an NSNumber.
@property(nonatomic, readwrite, copy) NSArray<NSNumber *> *products;

- (instancetype)initWithClientName:(NSString *)clientName
                       environment:(PLKEnvironment)environment
                          products:(NSArray<NSNumber *> *)products
                          language:(PLKLanguage *)language
                             token:(PLKLinkPublicKeyConfigurationToken *)token
                      countryCodes:(NSArray<PLKCountryCode *> *)countryCodes
                         onSuccess:(PLKOnSuccessHandler)successHandler;
- (instancetype)init NS_UNAVAILABLE;

+ (instancetype)createWithClientName:(NSString *)clientName
                         environment:(PLKEnvironment)environment
                            products:(NSArray<NSNumber *> *)products
                            language:(PLKLanguage *)language
                               token:(PLKLinkPublicKeyConfigurationToken *)token
                        countryCodes:(NSArray<PLKCountryCode *> *)countryCodes
                           onSuccess:(PLKOnSuccessHandler)successHandler;

@end

/// Both `PLKPresentationHandler` and `PLKDismissalHandler` clsoures take the Plaid Link View Controller to be
/// presented or dismissed as a parameter.
typedef void(^PLKPresentationHandler)(UIViewController *);
typedef void(^PLKDismissalHandler)(UIViewController *);

@protocol PLKHandler <NSObject>

- (void)openWithContextViewController:(UIViewController *)viewController;

- (void)openWithContextViewController:(UIViewController *)viewController
                              options:(NSDictionary<NSString *, NSString *> *)options;

- (void)openWithPresentationHandler:(PLKPresentationHandler)presentationHandler DEPRECATED_MSG_ATTRIBUTE("openWithPresentationHandler: is deprecated in favor openWithPresentationHandler:dismissalHandler:");
- (void)openWithPresentationHandler:(PLKPresentationHandler)presentationHandler
                   dismissalHandler:(PLKDismissalHandler)dismissalHandler;

- (void)openWithPresentationHandler:(PLKPresentationHandler)presentationHandler
options:(NSDictionary<NSString *, NSString *> *)options  DEPRECATED_MSG_ATTRIBUTE("openWithPresentationHandler:options: is deprecated in favor openWithPresentationHandler:dismissalHandler:options:");

- (void)openWithPresentationHandler:(PLKPresentationHandler)presentationHandler
                   dismissalHandler:(PLKDismissalHandler)dismissalHandler
                            options:(NSDictionary<NSString *, NSString *> *)options;

- (NSError * __nullable)continueFromRedirectUri:(NSURL *)redirectUri DEPRECATED_MSG_ATTRIBUTE("continueFromRedirectUri: is deprecated in favor continueWithRedirectUri:");
- (void)continueWithRedirectUri:(NSURL *)redirectUri;

@end

NS_ASSUME_NONNULL_END
