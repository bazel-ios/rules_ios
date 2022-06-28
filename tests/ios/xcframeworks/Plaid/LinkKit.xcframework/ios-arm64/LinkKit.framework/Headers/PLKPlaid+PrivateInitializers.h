#ifndef PLKPlaid_PrivateInitializers_h
#define PLKPlaid_PrivateInitializers_h

/// NOTE: The initializers exposed through this header are meant for use only by internal LinkKit code and are
/// subject to change without notice, or a corresponding semantic version bump. If there is a use case that requires
/// the use of these initializers, please let Plaid know so a path forward can be found using the public, stable API.
NS_ASSUME_NONNULL_BEGIN

@interface PLKVerificationStatus (PrivateInitializers)

+ (instancetype)createWithValue:(PLKVerificationStatusValue)value;
+ (instancetype)createWithUnknownStringValue:(NSString *)unknownStringValue;

@end

@interface PLKEventName (PrivateInitializers)

+ (instancetype)createWithValue:(PLKEventNameValue)value;
+ (instancetype)createWithUnknownStringValue:(NSString *)unknownStringValue;

@end

@interface PLKViewName (PrivateInitializers)

+ (instancetype)createWithValue:(PLKViewNameValue)value;
+ (instancetype)createWithUnknownStringValue:(NSString *)unknownStringValue;

@end

@interface PLKExitStatus (PrivateInitializers)

+ (instancetype)createWithValue:(PLKExitStatusValue)value;
+ (instancetype)createWithUnknownStringValue:(NSString *)unknownStringValue;

@end

@interface PLKAccount (PrivateInitializers)

- (instancetype)initWithAccountID:(NSString *)ID
                             name:(NSString *)name
                             mask:(NSString * __nullable)mask
                          subtype:(id<PLKAccountSubtype>)subtype
               verificationStatus:(PLKVerificationStatus * __nullable)verificationStatus;

@end

@interface PLKInstitution (PrivateInitializers)

- (instancetype)initWithID:(NSString *)ID
                      name:(NSString *)name;

@end

@interface PLKEventMetadata (PrivateInitializers)

- (instancetype)initWithError:(PLKExitError * __nullable)error
                   exitStatus:(PLKExitStatus * __nullable)exitStatus
                institutionID:(NSString * __nullable)institutionID
              institutionName:(NSString * __nullable)institutionName
       institutionSearchQuery:(NSString * __nullable)institutionSearchQuery
                linkSessionID:(NSString *)linkSessionID
                      mfaType:(PLKMFAType)mfaType
                    requestID:(NSString * __nullable)requestID
                    timestamp:(NSDate *)timestamp
                     viewName:(PLKViewName * __nullable)viewName
                 metadataJSON:(PLKRawJSONMetadata * __nullable)metadataJSON;

@end

@interface PLKLinkEvent (PrivateInitializers)

- (instancetype)initWithEventName:(PLKEventName *)eventName
                    eventMetadata:(PLKEventMetadata *)eventMetadata;

@end

@interface PLKExitMetadata (PrivateInitializers)

- (instancetype)initWithStatus:(PLKExitStatus * __nullable)status
                   institution:(PLKInstitution * __nullable)institution
                     requestID:(NSString * __nullable)requestID
                 linkSessionID:(NSString * __nullable)linkSessionID
                  metadataJSON:(PLKRawJSONMetadata * __nullable)metadataJSON;

@end

@interface PLKLinkExit (PrivateInitializers)

- (instancetype)initWithError:(NSError * __nullable)error
                     metadata:(PLKExitMetadata *)metadata;

@end

@interface PLKLinkSuccess (PrivateInitializers)

- (instancetype)initWithPublicToken:(NSString *)publicToken
                           metadata:(PLKSuccessMetadata *)metadata;

@end

@interface PLKSuccessMetadata (PrivateInitializers)

- (instancetype)initWithLinkSessionID:(NSString *)linkSessionID
                          institution:(PLKInstitution *)institution
                             accounts:(NSArray<PLKAccount *> *)accounts
                         metadataJSON:(PLKRawJSONMetadata * __nullable)metadataJSON;

@end

NS_ASSUME_NONNULL_END


#endif  // PLKPlaid_PrivateInitializers_h

