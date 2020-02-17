//
// MLAuthenticationManager.m
// Authentication
//
// Created by Christian Perez Biancucci on 2/18/15.
// Copyright (c) 2015 MercadoLibre S.A. All rights reserved.
//

#import <MLAuthentication/MLAuthenticationManager.h>
#import <MLCommons/UIDevice+Hardware.h>
#import <MLCommons/NSString+JSON.h>
#import <MLAuthentication/MLKeychain.h>
#import <MLAuthentication/MLAuthenticationNotificationsNames.h>
#import <MLCommons/NSDictionary+Null.h>
#import <MLAuthentication/MLAccessTokenEnvelope.h>
#import <MLAuthentication/MLSession+MLDictionary.h>
#import <MLAuthentication/MLAccessTokenEnvelope+MLDictionary.h>

#define kLoginAPIURL            @"https://mobile.mercadolibre.com.ar/mobile_authentications"
#define kLoginValidationURL     @"https://mobile.mercadolibre.com.ar/transaction_mobile_authentications"
#define GROUP_NAME              @"T9VUHG6RU2.com.mercadolibre"

@interface MLAuthenticationManager ()

@property (nonatomic, strong) MLSession *session;
@property (nonatomic, strong) MLKeychain *keychain;
@property (atomic) BOOL storeInProgress;
@property (atomic) BOOL updateDeviceProfileIdInProgress;
@property (nonatomic, strong) id <MLAuthenticationConnectionProtocol> connectionObject;
@end

@implementation MLAuthenticationManager

NSString *const MLAuthenticationSocialTokenFacebookType = @"facebook";
NSString *const MLAuthenticationSocialTokenGoogleType = @"google";
NSString *const MLInvalidDeviceProfileId = @"invalid_device_profile_id";

+ (MLAuthenticationManager *)sharedInstance
{
	static dispatch_once_t once;
	static MLAuthenticationManager *sharedInstance;
	dispatch_once(&once, ^{
		sharedInstance = [[self alloc] init];
	});
	return sharedInstance;
}

+ (MLAuthenticationManager *)initializeWithAppId:(NSString *)appId
                              keychainIdentifier:(NSString *)keychain
                            andConnectionFactory:(id <MLAuthenticationConnectionFactoryProtocol>)connectionFactory
{
	NSAssert(appId != nil, @"AppId can not be nil.");
	NSAssert(![appId isEqual:@""], @"AppId can not be empty.");
	NSAssert(keychain != nil, @"KeychainIdentifier can not be nil..");
	NSAssert(![keychain isEqual:@""], @"KeychainIdentifier can not be empty.");
	NSAssert(connectionFactory != nil, @"ConnectionFactory can not be nil.");

	MLAuthenticationManager *manager = [MLAuthenticationManager sharedInstance];
	manager.appId = appId;
	manager.keychain = [[MLKeychain alloc] initWithService:keychain withGroup:GROUP_NAME];
	manager.connectionFactory = connectionFactory;
	[manager loadSession];

	return manager;
}

- (void)checkSuccessfulInitialization
{
	NSAssert(self.appId != nil, @"AppId can not be nil.");
	NSAssert(![self.appId isEqual:@""], @"AppId can not be empty.");
	NSAssert(self.keychain != nil, @"KeychainIdentifier can not be nil..");
	NSAssert(![self.keychain isEqual:@""], @"KeychainIdentifier can not be empty.");
	NSAssert(self.connectionFactory != nil, @"ConnectionFactory can not be nil.");
}

- (MLSession *)getSession
{
	[self checkSuccessfulInitialization];

	if ([self.session isSessionValid]) {
		[self updateDeviceProfileId];
		return self.session;
	} else {
		return nil;
	}
}

- (void)saveSession:(MLSession *)session
{
	[self checkSuccessfulInitialization];

	if (session == nil) {
		NSAssert(session != nil, @"Session can not be nil.");
		return;
	}

	if ([self sessionToBeSavedIsValid:session]) {
		NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
		[dateFormatter setDateFormat:@"dd-MM-yyyy hh:mma"];
		NSString *stringDate = [dateFormatter stringFromDate:session.lastDayActive];

		NSMutableDictionary *keychainSession = [[NSMutableDictionary alloc] initWithDictionary:@{@"accessToken" : session.accessToken, @"deviceProfileId" : session.deviceProfileId, @"lastDayActive" : stringDate, @"userId" : session.userId, @"nickname" : session.nickname, @"siteId" : session.siteId, @"firstName" : session.firstName, @"lastName" : session.lastName, @"email" : session.email}];

		if (session.scopes) {
		    [keychainSession setObject:session.scopes forKey:@"scopes"];
		}

		if (session.accessTokenEnvelopes) {
		    [keychainSession setObject:session.accessTokenEnvelopes forKey:@"access_token_envelopes"];

		    for (int i = 0; i < session.accessTokenEnvelopes.count; i++) {
		        MLAccessTokenEnvelope *accessTokenEnvelope = [[MLAccessTokenEnvelope alloc] initWithDictionary:session.accessTokenEnvelopes[i]];

		        MLKeychain *keychainEnvelope = [[MLKeychain alloc] initWithService:accessTokenEnvelope.keychainId withGroup:GROUP_NAME];
		        [keychainSession setObject:accessTokenEnvelope.accessToken forKey:@"accessToken"];

		        NSData *sessionData = [NSKeyedArchiver archivedDataWithRootObject:keychainSession];

		        if ([keychainEnvelope find:@"session"]) {
		            [keychainEnvelope update:@"session" data:sessionData];
				} else {
		            [keychainEnvelope insert:@"session" data:sessionData];
				}
		        [self saveFastTrackUsername:session.nickname andFirstName:session.firstName andKeychain:keychainEnvelope];
			}
		} else {
		    NSData *sessionData = [NSKeyedArchiver archivedDataWithRootObject:keychainSession];

		    if ([self.keychain find:@"session"]) {
		        [self.keychain update:@"session" data:sessionData];
			} else {
		        [self.keychain insert:@"session" data:sessionData];
			}

		    [self saveFastTrackUsername:session.nickname andFirstName:session.firstName andKeychain:self.keychain];
		}

		self.session = session;
	}
}

- (void)saveFastTrackUsername:(NSString *)username andFirstName:(NSString *)firstName andKeychain:(MLKeychain *)keychain
{
    NSMutableDictionary *fastTrackInformation = [[NSMutableDictionary alloc] initWithDictionary:@{@"username" : username, @"firstName" : firstName}];

    NSData *fastTrackData = [NSKeyedArchiver archivedDataWithRootObject:fastTrackInformation];

    if ([keychain find:@"fastTrack"]) {
        [keychain update:@"fastTrack" data:fastTrackData];
	} else {
        [keychain insert:@"fastTrack" data:fastTrackData];
	}
}

- (BOOL)isOperatorSession
{
    [self checkSuccessfulInitialization];

    if ([self.session isSessionValid]) {
        if (self.session.scopes && [self.session.scopes count]) {
            return YES;
		}
	}
    return NO;
}

- (BOOL)isAdminSession
{
    if ([self.session.scopes containsObject:@"write"] && [self.session.scopes containsObject:@"read"] && [self.session.scopes containsObject:@"offline_access"]) {
        return YES;
	}
    return NO;
}

- (BOOL)canBeIdentified
{
    [self checkSuccessfulInitialization];
    return [self fastTrackUsername].length > 0;
}

- (NSString *)fastTrackFirstName
{
    [self checkSuccessfulInitialization];
    NSString *firstName;

    NSData *fastTrackData = [self.keychain find:@"fastTrack"];

    if ([fastTrackData length]) {
        NSDictionary *keychainSession = (NSDictionary *)[NSKeyedUnarchiver unarchiveObjectWithData:fastTrackData];
        firstName = [keychainSession ml_objectForKey:@"firstName"];
	}

    return firstName;
}

- (NSString *)fastTrackUsername
{
    [self checkSuccessfulInitialization];
    NSString *username;

    NSData *fastTrackData = [self.keychain find:@"fastTrack"];

    if ([fastTrackData length]) {
        NSDictionary *keychainSession = (NSDictionary *)[NSKeyedUnarchiver unarchiveObjectWithData:fastTrackData];
        username = [keychainSession ml_objectForKey:@"username"];
	}

    return username;
}

- (void)createSessionWithNickname:(NSString *)nickname
                         password:(NSString *)password
                          success:(void (^)(MLSession *session))successHandler
                          failure:(void (^)(MLAuthenticationManagerError))failureHandler
      authenticationByTransaction:(void (^)(NSString *validationURL, NSString *transactionId))transactionHandler
{
    [self createSessionWithNickname:nickname password:password connectionObject:[self.connectionFactory newAuthenticationConnection] success:successHandler failure:failureHandler authenticationByTransaction:transactionHandler];
}

- (void)createSessionWithNickname:(NSString *)nickname
                         password:(NSString *)password
                 connectionObject:(id <MLAuthenticationConnectionProtocol>)connectionObject
                          success:(void (^)(MLSession *session))successHandler
                          failure:(void (^)(MLAuthenticationManagerError error))failureHandler
      authenticationByTransaction:(void (^)(NSString *validationURL, NSString *transactionId))transactionHandler
{
    [self createSessionWithNickname:nickname password:password notificationToken:@"" connectionObject:connectionObject success:successHandler failure:failureHandler authenticationByTransaction:transactionHandler];
}

- (void)createSessionWithNickname:(NSString *)nickname
                         password:(NSString *)password
                notificationToken:(NSString *)notificationToken
                          success:(void (^)(MLSession *session))successHandler
                          failure:(void (^)(MLAuthenticationManagerError error))failureHandler
      authenticationByTransaction:(void (^)(NSString *validationURL, NSString *transactionId))transactionHandler
{
    [self createSessionWithNickname:nickname password:password notificationToken:notificationToken connectionObject:[self.connectionFactory newAuthenticationConnection] success:successHandler failure:failureHandler authenticationByTransaction:transactionHandler];
}

- (void)createSessionWithNickname:(NSString *)nickname
                         password:(NSString *)password
                notificationToken:(NSString *)notificationToken
                 connectionObject:(id <MLAuthenticationConnectionProtocol>)connectionObject
                          success:(void (^)(MLSession *session))successHandler
                          failure:(void (^)(MLAuthenticationManagerError error))failureHandler
      authenticationByTransaction:(void (^)(NSString *validationURL, NSString *transactionId))transactionHandler
{
    [self checkSuccessfulInitialization];

    NSAssert(nickname != nil, @"Nickname can not be nil.");
    NSAssert(![nickname isEqual:@""], @"Nickname can not be empty.");
    NSAssert(password != nil, @"Password can not be nil.");
    NSAssert(![password isEqual:@""], @"Password can not be empty.");
    NSAssert(connectionObject != nil, @"ConnectionObject can not be nil.");
    NSAssert(notificationToken != nil, @"NotificationToken can not be nil.");

    [self logout];
    self.connectionObject = connectionObject;

    __typeof(self) __weak weakSelf = self;

    [self provideAttestationSignatureToHandler: ^(NSString *attestationSignature) {
        [weakSelf.connectionObject makeRequestWithURLRequest:[weakSelf requestForNickname:nickname password:password notificationToken:notificationToken attestationToken:attestationSignature] completionBlock: ^(NSData *responseData) {
            [weakSelf onCreateSessionCompletionWithData:responseData success:successHandler failure:failureHandler];
		} failureBlock: ^(NSError *error) {
            [weakSelf onCreateSessionFailureWithError:error success:successHandler failure:failureHandler authenticationByTransaction:transactionHandler];
		}];
	}];
}

- (DeviceAttestationService *)getNewDeviceAttestationService {
    DeviceAttestationService *deviceAttestationService = [[DeviceAttestationService alloc] init];
    return deviceAttestationService;
}

- (void)provideAttestationSignatureToHandler:(void (^)(NSString *attestationSignature))handler
{
    DeviceAttestationService *deviceAttestationService = [self getNewDeviceAttestationService];
    [deviceAttestationService generateTokenWithHandler: ^(DeviceToken *deviceToken, NSString *error) {
        NSString *attestationSignature;
        if (deviceToken) {
            attestationSignature = deviceToken.value;
		} else {
            attestationSignature = error;
		}
        handler(attestationSignature);
	}];
}

- (void)createSessionWithTransactionId:(NSString *)transactionId
                               success:(void (^)(MLSession *session))successHandler
                               failure:(void (^)(MLAuthenticationManagerError))failureHandler
           authenticationByTransaction:(void (^)(NSString *validationURL, NSString *transactionId))transactionHandler
{
    [self createSessionWithTransactionId:transactionId connectionObject:[self.connectionFactory newAuthenticationConnection] success:successHandler failure:failureHandler authenticationByTransaction:transactionHandler];
}

- (void)createSessionWithTransactionId:(NSString *)transactionId
                      connectionObject:(id <MLAuthenticationConnectionProtocol>)connectionObject
                               success:(void (^)(MLSession *session))successHandler
                               failure:(void (^)(MLAuthenticationManagerError))failureHandler
           authenticationByTransaction:(void (^)(NSString *validationURL, NSString *transactionId))transactionHandler
{
    [self checkSuccessfulInitialization];

    NSAssert(transactionId != nil, @"TransactionId can not be nil.");
    NSAssert(![transactionId isEqual:@""], @"TransactionId can not be empty.");

    [self logout];
    self.connectionObject = connectionObject;

    __typeof(self) __weak weakSelf = self;
    [self provideAttestationSignatureToHandler: ^(NSString *attestationSignature) {
        [weakSelf.connectionObject makeRequestWithURLRequest:[weakSelf requestAuthenticationByTransactionId:transactionId withAttestationToken:attestationSignature] completionBlock: ^(NSData *responseData) {
            [weakSelf onCreateSessionCompletionWithData:responseData
                                                success:successHandler
                                                failure:failureHandler];
		} failureBlock: ^(NSError *error) {
            [weakSelf onCreateSessionFailureWithError:error
                                              success:successHandler
                                              failure:failureHandler
                          authenticationByTransaction:transactionHandler];
		}];
	}];
}

- (void)createSessionFromResponseData:(NSData *)responseData
{
    NSString *response = [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding];
    NSDictionary *responseBody = [response ml_JSONValue];
    MLSession *session = [[MLSession alloc] initWithDictionary:responseBody];
    [self saveSession:session];
}

- (NSString *)getDeviceProfileFromResponseData:(NSData *)responseData
{
    NSString *response = [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding];
    NSDictionary *responseBody = [response ml_JSONValue];
    NSString *deviceProfileId = [responseBody ml_objectForKey:@"device_profile_id"];
    if (deviceProfileId.length == 0) {
        return MLInvalidDeviceProfileId;
	}
    return [responseBody ml_objectForKey:@"device_profile_id"];
}

- (BOOL)sessionToBeSavedIsValid:(MLSession *)session
{
    if (session.accessToken.length == 0) {
        NSAssert(session.accessToken != nil, @"AccessToken can not be nil.");
        NSAssert(![session.accessToken isEqual:@""], @"AccessToken can not be empty.");
        return NO;
	}

    if (session.userId.length == 0) {
        NSAssert(session.userId != nil, @"UserId can not be nil.");
        NSAssert(![session.userId isEqual:@""], @"UserId can not be empty.");
        return NO;
	}

    if (session.siteId.length == 0) {
        NSAssert(session.siteId != nil, @"SiteId can not be nil.");
        NSAssert(![session.siteId isEqual:@""], @"SiteId can not be empty.");
        return NO;
	}

    if (session.firstName == nil) {
        NSAssert(session.firstName != nil, @"FirstName can not be nil.");
        return NO;
	}

    if (session.lastName == nil) {
        NSAssert(session.lastName != nil, @"LastName can not be nil.");
        return NO;
	}

    if (session.email.length == 0) {
        NSAssert(session.email != nil, @"Email can not be nil.");
        NSAssert(![session.email isEqual:@""], @"Email can not be empty.");
        return NO;
	}

    if (session.lastDayActive == nil) {
        NSAssert(session.lastDayActive != nil, @"LastDayActive can not be nil.");
        return NO;
	}

    if (session.nickname == nil) {
        NSAssert(session.nickname != nil, @"Nickname can not be nil.");
        return NO;
	}

    if (session.deviceProfileId.length == 0) {
        session.deviceProfileId = MLInvalidDeviceProfileId;
	}

    if (![session isAccessTokenEnvelopesValid]) {
        NSAssert([session isAccessTokenEnvelopesValid], @"Access Token Envelopes is invalid");
        return NO;
	}

    return YES;
}

- (void)loadSession
{
    [self checkSuccessfulInitialization];

    self.session = [[MLSession alloc] init];

    NSData *sessionData = [self.keychain find:@"session"];

    if ([sessionData length]) {
        NSDictionary *keychainSession = (NSDictionary *)[NSKeyedUnarchiver unarchiveObjectWithData:sessionData];
        self.session = [[MLSession alloc] initWithDictionary:keychainSession];
	}
}

- (BOOL)shouldUpdateSession
{
    NSData *sessionData = [self.keychain find:@"session"];

    if (![sessionData length]) {
        return YES;
	}

    NSDictionary *keychainSession = (NSDictionary *)[NSKeyedUnarchiver unarchiveObjectWithData:sessionData];
    MLSession *session = [[MLSession alloc] initWithDictionary:keychainSession];

    return ![session.accessToken isEqualToString:self.session.accessToken];
}

- (MLSession *)refreshSession
{
    if ([self shouldUpdateSession]) {
        [self loadSession];
	}

    return [self getSession];
}

- (void)logout
{
    [self checkSuccessfulInitialization];

    if (self.session.accessToken) {
        self.connectionObject = [self.connectionFactory newAuthenticationConnection];
        [self.connectionObject makeRequestWithURLRequest:[self requestLogout] completionBlock:nil failureBlock:nil];
	}

    if (self.session.accessTokenEnvelopes) {
        for (int i = 0; i < self.session.accessTokenEnvelopes.count; i++) {
            MLAccessTokenEnvelope *accessTokenEnvelope = [[MLAccessTokenEnvelope alloc] initWithDictionary:self.session.accessTokenEnvelopes[i]];

            MLKeychain *keychain = [[MLKeychain alloc] initWithService:accessTokenEnvelope.keychainId withGroup:GROUP_NAME];
            [keychain remove:@"session"];
		}
	}

    self.session = nil;
}

- (void)updateDeviceProfileId
{
    if (self.session.lastDayActive != nil && !self.updateDeviceProfileIdInProgress) {
        NSCalendar *calendar = [NSCalendar currentCalendar];
        NSInteger difference = [[calendar components:NSCalendarUnitDay fromDate:self.session.lastDayActive toDate:[NSDate date] options:0] day];

        // Si paso mas de un dia desde que utilizo la app, actualizamos el device profile
        if (difference >= 1) {
            self.updateDeviceProfileIdInProgress = YES;
            [[self.connectionFactory newAuthenticationConnection] makeRequestWithURLRequest:[self requestUpdateDeviceProfile] completionBlock: ^(NSData *responseData) {
                self.session.deviceProfileId = [self getDeviceProfileFromResponseData:responseData];
                self.session.lastDayActive = [NSDate date];
                [self saveSession:self.session];
                self.updateDeviceProfileIdInProgress = NO;
			} failureBlock: ^(NSError *error) {
                self.updateDeviceProfileIdInProgress = NO;
			}];
		}
	}
}

- (NSURLRequest *)buildRequestWithRoot:(NSMutableURLRequest *)mutableRequest body:(NSDictionary *)authenticationBody notificationToken:(NSDictionary *)notificationTokenUpdate {
    NSDictionary *myBody;
    if (!notificationTokenUpdate) {
        myBody = @{@"authentication_request" : authenticationBody};
	} else {
        myBody = @{@"authentication_request" : authenticationBody, @"notification_token_update" : notificationTokenUpdate};
	}

    NSData *data = [NSJSONSerialization dataWithJSONObject:myBody options:NSJSONWritingPrettyPrinted error:nil];
    NSString *bodyString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    NSData *bodyData = [bodyString dataUsingEncoding:NSUTF8StringEncoding];

    [mutableRequest setValue:[NSString stringWithFormat:@"%lu", (unsigned long)[bodyData length]] forHTTPHeaderField:@"Content-Length"];
    [mutableRequest setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [mutableRequest setHTTPBody:bodyData];

    return mutableRequest;
}

- (NSURLRequest *)requestForNickname:(NSString *)nickname password:(NSString *)password notificationToken:(NSString *)notificationToken attestationToken:(NSString *)attestationSignature
{
    NSMutableURLRequest *mutableRequest = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:kLoginAPIURL]];
    [mutableRequest setHTTPMethod:@"POST"];

    NSString *deviceId = [[[UIDevice currentDevice] identifierForVendor] UUIDString];

    NSDictionary *authenticationBody =
		@{@"user_credentials" :
		  @{@"name" : nickname,
		    @"password" : password},
		  @"mobile_device_profile_session" : [[UIDevice currentDevice]fingerPrint],
		  @"attestation_signature" : attestationSignature,
		  @"client_id" : self.appId,
		  @"os" : @"iOS"};

    NSDictionary *notificationTokenUpdate = nil;
    if (deviceId) {
        notificationTokenUpdate =
			@{@"token" : notificationToken,
			  @"device_id" : deviceId};
	}

    return [self buildRequestWithRoot:mutableRequest body:authenticationBody notificationToken:notificationTokenUpdate];
}

- (NSURLRequest *)requestLogout
{
    NSMutableURLRequest *mutableRequest = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:[[kLoginAPIURL stringByAppendingString:@"?access_token="] stringByAppendingString:self.session.accessToken]]];
    [mutableRequest setHTTPMethod:@"DELETE"];

    return mutableRequest;
}

- (NSURLRequest *)requestUpdateDeviceProfile
{
    NSMutableURLRequest *mutableRequest = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:[[kLoginAPIURL stringByAppendingString:@"?access_token="] stringByAppendingString:self.session.accessToken]]];
    [mutableRequest setHTTPMethod:@"PUT"];

    NSDictionary *myBody = @{@"mobile_device_profile_session" : [[UIDevice currentDevice]fingerPrint]};

    NSData *data = [NSJSONSerialization dataWithJSONObject:myBody options:NSJSONWritingPrettyPrinted error:nil];
    NSString *bodyString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    NSData *bodyData = [bodyString dataUsingEncoding:NSUTF8StringEncoding];

    [mutableRequest setValue:[NSString stringWithFormat:@"%lu", (unsigned long)[bodyData length]] forHTTPHeaderField:@"Content-Length"];
    [mutableRequest setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [mutableRequest setHTTPBody:bodyData];

    return mutableRequest;
}

- (NSURLRequest *)requestAuthenticationByTransactionId:(NSString *)transactionId withAttestationToken:(NSString *)attestationSignature
{
    NSMutableURLRequest *mutableRequest = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:kLoginValidationURL]];
    [mutableRequest setHTTPMethod:@"POST"];

    NSDictionary *authenticationBody = @{@"transaction_id" : transactionId,
                                         @"attestation_signature" : attestationSignature};

    return [self buildRequestWithRoot:mutableRequest body:authenticationBody notificationToken:nil];
}

- (void)onCreateSessionCompletionWithData:(NSData *)responseData
                                  success:(void (^)(MLSession *session))successHandler
                                  failure:(void (^)(MLAuthenticationManagerError error))failureHandler
{
    if ([responseData length]) {
        [self createSessionFromResponseData:responseData];

        // Validate session created from response data is valid before posting success notification
        if (self.session && [self.session isSessionValid]) {
            [[NSNotificationCenter defaultCenter] postNotificationName:MLAuthenticationCreateSessionSuccessNotification object:nil userInfo:@{MLAuthenticationCreateSessionSuccessNotificationObject : self.session}];
            if (successHandler) {
                successHandler(self.session);
			}
		} else {
            if (failureHandler) {
                failureHandler(MLAuthenticationManagerGenericError);
			}
		}
	} else {
        if (failureHandler) {
            failureHandler(MLAuthenticationManagerConnectionError);
		}
	}
}

- (void)onCreateSessionFailureWithError:(NSError *)error
                                success:(void (^)(MLSession *session))successHandler
                                failure:(void (^)(MLAuthenticationManagerError error))failureHandler
            authenticationByTransaction:(void (^)(NSString *validationURL, NSString *transactionId))transactionHandler
{
    if (error.code == 406) {
        NSDictionary *response = [NSJSONSerialization JSONObjectWithData:[[error.userInfo ml_objectForKey:@"response"] dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingAllowFragments error:nil];
        NSDictionary *authenticationTransaction = [response ml_objectForKey:@"authentication_transaction"];
        NSString *transactionId = [authenticationTransaction ml_objectForKey:@"id"];
        NSString *validationURL = [authenticationTransaction ml_objectForKey:@"validation_url"];
        if (transactionHandler) {
            transactionHandler(validationURL, transactionId);
		}
	} else {
        NSString *errorMessage = [self parseError:error];
        MLAuthenticationManagerError authenticationError = [self parseErrorMessage:errorMessage];
        if (failureHandler) {
            failureHandler(authenticationError);
		}
	}
}

- (NSString *)parseError:(NSError *)error
{
    NSDictionary *userInfo = [error userInfo];
    NSString *userInfoResponse = [userInfo ml_objectForKey:@"response"];
    NSString *message = nil;
    NSDictionary *response = nil;
    if (userInfoResponse) {
        response = [NSJSONSerialization JSONObjectWithData:[[userInfo ml_objectForKey:@"response"] dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingAllowFragments error:nil];
        message = [response ml_objectForKey:@"credentials_validation_result"];
	}

    return message;
}

- (MLAuthenticationManagerError)parseErrorMessage:(NSString *)message
{
    MLAuthenticationManagerError error;

    if ([message isEqualToString:@"INVALID_PWD"]) {
        error = MLAuthenticationManagerInvalidPasswordError;
	} else if ([message isEqualToString:@"USER_NOT_FOUND"]) {
        error = MLAuthenticationManagerUserNotFoundError;
	} else if ([message isEqualToString:@"ATTEMPTS_EXCEEDED"]) {
        error = MLAuthenticationManagerAttemptsExceededError;
	} else if ([message isEqualToString:@"OPERATOR_NOT_SUPPORTED"]) {
        error = MLAuthenticationManagerOperatorNotSupported;
	} else if ([message isEqualToString:@"INVALID_SOCIAL_TOKEN"]) {
        error = MLAuthenticationManagerInvalidSocialToken;
	} else if ([message isEqualToString:@"INVALID_ONE_TIME_PASSWORD"]) {
        error = MLAuthenticationManagerInvalidOneTimePassword;
	} else {
        error = MLAuthenticationManagerGenericError;
	}

    return error;
}

#pragma mark - Social login

- (void)createSessionWithNickname:(NSString *)nickname
                      socialToken:(NSString *)token
                  socialTokenType:(NSString *)tokenType
                          success:(void (^)(MLSession *session))successHandler
                          failure:(void (^)(MLAuthenticationManagerError))failureHandler
      authenticationByTransaction:(void (^)(NSString *validationURL, NSString *transactionId))transactionHandler
{
    [self createSessionWithNickname:nickname socialToken:token socialTokenType:tokenType connectionObject:[self.connectionFactory newAuthenticationConnection] success:successHandler failure:failureHandler authenticationByTransaction:transactionHandler];
}

- (void)createSessionWithNickname:(NSString *)nickname
                      socialToken:(NSString *)token
                  socialTokenType:(NSString *)tokenType
                 connectionObject:(id <MLAuthenticationConnectionProtocol>)connectionObject
                          success:(void (^)(MLSession *session))successHandler
                          failure:(void (^)(MLAuthenticationManagerError))failureHandler
      authenticationByTransaction:(void (^)(NSString *validationURL, NSString *transactionId))transactionHandler
{
    [self checkSuccessfulInitialization];

    NSAssert(nickname != nil, @"Nickname can not be nil.");
    NSAssert(![nickname isEqual:@""], @"Nickname can not be empty.");
    NSAssert(token != nil, @"Password can not be nil.");
    NSAssert(![token isEqual:@""], @"Password can not be empty.");
    NSAssert(connectionObject != nil, @"ConnectionObject can not be nil.");
    NSAssert([self isValidSocialTokenType:tokenType], @"Invalid social token type.");

    [self logout];

    self.connectionObject = connectionObject;

    __typeof(self) __weak weakSelf = self;
    [self provideAttestationSignatureToHandler: ^(NSString *attestationSignature) {
        [weakSelf.connectionObject makeRequestWithURLRequest:[weakSelf requestForNickname:nickname socialToken:token socialTokenType:tokenType attestationToken:attestationSignature]
                                             completionBlock: ^(NSData *responseData) {
            [weakSelf onCreateSessionCompletionWithData:responseData
                                                success:successHandler
                                                failure:failureHandler];
		}
                                                failureBlock: ^(NSError *error) {
            [weakSelf onCreateSessionFailureWithError:error
                                              success:successHandler
                                              failure:failureHandler
                          authenticationByTransaction:transactionHandler];
		}];
	}];
}

- (NSURLRequest *)requestForNickname:(NSString *)nickname socialToken:(NSString *)token socialTokenType:(NSString *)tokenType attestationToken:(NSString *)attestationSignature
{
    NSMutableURLRequest *mutableRequest = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:kLoginAPIURL]];
    [mutableRequest setHTTPMethod:@"POST"];

    NSDictionary *userCredentials =
		@{@"user_credentials" :
		  @{@"name" : nickname,
		    @"social_token" : token,
		    @"social_token_type" : tokenType},
		  @"mobile_device_profile_session" : [[UIDevice currentDevice]fingerPrint],
		  @"attestation_signature" : attestationSignature,
		  @"client_id" : self.appId,
		  @"os" : @"iOS"};

    return [self buildRequestWithRoot:mutableRequest body:userCredentials notificationToken:nil];
}

- (BOOL)isValidSocialTokenType:(NSString *)socialTokenType
{
    return [socialTokenType isEqualToString:MLAuthenticationSocialTokenFacebookType] || [socialTokenType isEqualToString:MLAuthenticationSocialTokenGoogleType];
}

#pragma mark - Otp From Web

- (void)createSessionWithOneTimePassword:(NSString *)oneTimePassword
                                 success:(void (^)(MLSession *session))successHandler
                                 failure:(void (^)(MLAuthenticationManagerError))failureHandler
             authenticationByTransaction:(void (^)(NSString *validationURL, NSString *transactionId))transactionHandler
{
    [self createSessionWithOneTimePassword:oneTimePassword connectionObject:[self.connectionFactory newAuthenticationConnection] success:successHandler failure:failureHandler authenticationByTransaction:transactionHandler];
}

- (void)createSessionWithOneTimePassword:(NSString *)oneTimePassword
                        connectionObject:(id <MLAuthenticationConnectionProtocol>)connectionObject
                                 success:(void (^)(MLSession *session))successHandler
                                 failure:(void (^)(MLAuthenticationManagerError))failureHandler
             authenticationByTransaction:(void (^)(NSString *validationURL, NSString *transactionId))transactionHandler
{
    [self checkSuccessfulInitialization];

    NSAssert(oneTimePassword != nil, @"Otp can not be nil.");
    NSAssert(![oneTimePassword isEqual:@""], @"Otp can not be empty.");

    [self logout];

    self.connectionObject = connectionObject;

    __typeof(self) __weak weakSelf = self;
    [self provideAttestationSignatureToHandler: ^(NSString *attestationSignature) {
        [weakSelf.connectionObject makeRequestWithURLRequest:[weakSelf requestForOneTimePassword:oneTimePassword withAttestationToken:attestationSignature]
                                             completionBlock: ^(NSData *responseData) {
            [weakSelf onCreateSessionCompletionWithData:responseData
                                                success:successHandler
                                                failure:failureHandler];
		}
                                                failureBlock: ^(NSError *error) {
            [weakSelf onCreateSessionFailureWithError:error
                                              success:successHandler
                                              failure:failureHandler
                          authenticationByTransaction:transactionHandler];
		}];
	}];
}

- (NSURLRequest *)requestForOneTimePassword:(NSString *)oneTimePassword withAttestationToken:(NSString *)attestationSignature
{
    NSMutableURLRequest *mutableRequest = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:kLoginAPIURL]];
    [mutableRequest setHTTPMethod:@"POST"];

    NSDictionary *userCredentials =
		@{@"user_credentials" :
		  @{@"one_time_password" : oneTimePassword},
		  @"mobile_device_profile_session" : [[UIDevice currentDevice]fingerPrint],
		  @"attestation_signature" : attestationSignature,
		  @"client_id" : self.appId,
		  @"os" : @"iOS"};

    return [self buildRequestWithRoot:mutableRequest body:userCredentials notificationToken:nil];
}

@end
