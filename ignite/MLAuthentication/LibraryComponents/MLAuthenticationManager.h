//
// MLAuthenticationManager.h
// Authentication
//
// Created by Christian Perez Biancucci on 2/18/15.
// Copyright (c) 2015 MercadoLibre S.A. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MLAuthentication/MLSession.h>
#import <MLAuthentication/MLAuthenticationConnectionProtocol.h>
#import <MLAuthentication/MLAuthenticationConnectionFactoryProtocol.h>
#import "ignite/MLSecurity_swift-Swift.h"

typedef NS_ENUM (NSInteger, MLAuthenticationManagerError) {
	MLAuthenticationManagerInvalidPasswordError   = 0,
	MLAuthenticationManagerUserNotFoundError      = 1,
	MLAuthenticationManagerAttemptsExceededError  = 2,
	MLAuthenticationManagerConnectionError        = 3,
	MLAuthenticationManagerOperatorNotSupported   = 4,
	MLAuthenticationManagerSiteNotAllowedError    = 5,
	MLAuthenticationManagerInvalidSocialToken     = 6,
	MLAuthenticationManagerInvalidOneTimePassword = 7,
	MLAuthenticationManagerGenericError           = 8
};

@interface MLAuthenticationManager : NSObject

/*!
   Social token type for Facebook login
 */
	OBJC_EXTERN NSString *const MLAuthenticationSocialTokenFacebookType;
/*!
   Social token type for Google login
 */
OBJC_EXTERN NSString *const MLAuthenticationSocialTokenGoogleType;

@property (nonatomic, copy) NSString *appId;
@property (nonatomic, strong) id <MLAuthenticationConnectionFactoryProtocol> connectionFactory;

+ (MLAuthenticationManager *)sharedInstance;

+ (MLAuthenticationManager *)initializeWithAppId:(NSString *)appId
                              keychainIdentifier:(NSString *)keychain
                            andConnectionFactory:(id <MLAuthenticationConnectionFactoryProtocol>)connectionFactory;

- (MLSession *)getSession;

- (void)saveSession:(MLSession *)session;

- (MLSession *)refreshSession;

- (BOOL)isOperatorSession;

- (BOOL)canBeIdentified;

- (NSString *)fastTrackFirstName;

- (NSString *)fastTrackUsername;

- (DeviceAttestationService *)getNewDeviceAttestationService;

- (void)createSessionWithNickname:(NSString *)nickname
                         password:(NSString *)password
                          success:(void (^)(MLSession *session))successHandler
                          failure:(void (^)(MLAuthenticationManagerError error))failureHandler
      authenticationByTransaction:(void (^)(NSString *validationURL, NSString *transactionId))transactionHandler;

- (void)createSessionWithNickname:(NSString *)nickname
                         password:(NSString *)password
                 connectionObject:(id <MLAuthenticationConnectionProtocol>)connectionObject
                          success:(void (^)(MLSession *session))successHandler
                          failure:(void (^)(MLAuthenticationManagerError error))failureHandler
      authenticationByTransaction:(void (^)(NSString *validationURL, NSString *transactionId))transactionHandler;

- (void)createSessionWithNickname:(NSString *)nickname
                         password:(NSString *)password
                notificationToken:(NSString *)notificationToken
                          success:(void (^)(MLSession *session))successHandler
                          failure:(void (^)(MLAuthenticationManagerError error))failureHandler
      authenticationByTransaction:(void (^)(NSString *validationURL, NSString *transactionId))transactionHandler;

- (void)createSessionWithNickname:(NSString *)nickname
                         password:(NSString *)password
                notificationToken:(NSString *)notificationToken
                 connectionObject:(id <MLAuthenticationConnectionProtocol>)connectionObject
                          success:(void (^)(MLSession *session))successHandler
                          failure:(void (^)(MLAuthenticationManagerError error))failureHandler
      authenticationByTransaction:(void (^)(NSString *validationURL, NSString *transactionId))transactionHandler;

- (void)createSessionWithTransactionId:(NSString *)transactionId
                               success:(void (^)(MLSession *session))successHandler
                               failure:(void (^)(MLAuthenticationManagerError error))failureHandler
           authenticationByTransaction:(void (^)(NSString *validationURL, NSString *transactionId))transactionHandler;

- (void)createSessionWithTransactionId:(NSString *)transactionId
                      connectionObject:(id <MLAuthenticationConnectionProtocol>)connectionObject
                               success:(void (^)(MLSession *session))successHandler
                               failure:(void (^)(MLAuthenticationManagerError error))failureHandler
           authenticationByTransaction:(void (^)(NSString *validationURL, NSString *transactionId))transactionHandler;

/*!
   Creates a session with a social token.
   The social token type should be one of the declared in this class:
   MLAuthenticationSocialTokenFacebookType
   MLAuthenticationSocialTokenGoogleType
 */
- (void)createSessionWithNickname:(NSString *)nickname
                      socialToken:(NSString *)token
                  socialTokenType:(NSString *)tokenType
                          success:(void (^)(MLSession *session))successHandler
                          failure:(void (^)(MLAuthenticationManagerError))failureHandler
      authenticationByTransaction:(void (^)(NSString *validationURL, NSString *transactionId))transactionHandler;

/*!
   Creates a session with a social token.
   The social token type should be one of the declared in this class:
   MLAuthenticationSocialTokenFacebookType
   MLAuthenticationSocialTokenGoogleType
 */
- (void)createSessionWithNickname:(NSString *)nickname
                      socialToken:(NSString *)token
                  socialTokenType:(NSString *)tokenType
                 connectionObject:(id <MLAuthenticationConnectionProtocol>)connectionObject
                          success:(void (^)(MLSession *session))successHandler
                          failure:(void (^)(MLAuthenticationManagerError))failureHandler
      authenticationByTransaction:(void (^)(NSString *validationURL, NSString *transactionId))transactionHandler;

/*!
   Creates a session with a otp web.
 */
- (void)createSessionWithOneTimePassword:(NSString *)oneTimePassword
                                 success:(void (^)(MLSession *session))successHandler
                                 failure:(void (^)(MLAuthenticationManagerError))failureHandler
             authenticationByTransaction:(void (^)(NSString *validationURL, NSString *transactionId))transactionHandler;

- (void)createSessionWithOneTimePassword:(NSString *)oneTimePassword
                        connectionObject:(id <MLAuthenticationConnectionProtocol>)connectionObject
                                 success:(void (^)(MLSession *session))successHandler
                                 failure:(void (^)(MLAuthenticationManagerError))failureHandler
             authenticationByTransaction:(void (^)(NSString *validationURL, NSString *transactionId))transactionHandler;

- (void)logout;

@end
