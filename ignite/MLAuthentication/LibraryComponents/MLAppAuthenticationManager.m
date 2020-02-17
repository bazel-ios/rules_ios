//
// MLAppAuthenticationManager.m
// Authentication
//
// Created by Cristian Perez Biancucci on 4/8/15.
// Copyright (c) 2015 MercadoLibre. All rights reserved.
//

#import <MLAuthentication/MLAppAuthenticationManager.h>
#import <MLCommons/NSString+JSON.h>
#import <MLCommons/NSDictionary+Null.h>

#define kAppTokenURL            @"https://mobile.mercadolibre.com.ar/oauth/token"

@interface MLAppAuthenticationManager ()
@property (nonatomic, strong) NSString *appToken;
@property (nonatomic, strong) id <MLAuthenticationConnectionProtocol> connectionObject;
@end

@implementation MLAppAuthenticationManager

+ (MLAppAuthenticationManager *)sharedInstance
{
	static dispatch_once_t once;
	static MLAppAuthenticationManager *sharedInstance;
	dispatch_once(&once, ^{
		sharedInstance = [[self alloc] init];
	});
	return sharedInstance;
}

+ (MLAppAuthenticationManager *)initializeWithConnectionFactory:(id <MLAuthenticationConnectionFactoryProtocol>)connectionFactory
{
	NSAssert(connectionFactory != nil, @"ConnectionFactory can not be nil.");

	MLAppAuthenticationManager *manager = [MLAppAuthenticationManager sharedInstance];
	manager.connectionFactory = connectionFactory;

	return manager;
}

- (void)createAppTokenWithAppId:(NSString *)appId
                      appSecret:(NSString *)appSecret
                        success:(void (^)(NSString *appToken))successHandler
                        failure:(void (^)(MLAppAuthenticationManagerError error))failureHandler
{
	[self createAppTokenWithAppId:appId appSecret:appSecret connectionObject:[self.connectionFactory newAuthenticationConnection] success:successHandler failure:failureHandler];
}

- (void)createAppTokenWithAppId:(NSString *)appId
                      appSecret:(NSString *)appSecret
               connectionObject:(id <MLAuthenticationConnectionProtocol>)connectionObject
                        success:(void (^)(NSString *appToken))successHandler
                        failure:(void (^)(MLAppAuthenticationManagerError error))failureHandler
{
	NSAssert(appId != nil, @"AppId can not be nil.");
	NSAssert(![appId isEqual:@""], @"AppId can not be empty.");
	NSAssert(appSecret != nil, @"AppSecret can not be nil.");
	NSAssert(![appSecret isEqual:@""], @"AppSecret can not be empty.");
	NSAssert(connectionObject != nil, @"ConnectionObject can not be nil.");

	self.connectionObject = connectionObject;
	[connectionObject makeRequestWithURLRequest:[self requestForAppId:appId appSecret:appSecret] completionBlock: ^(NSData *responseData) {
	    if ([responseData length]) {
	        NSString *response = [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding];
	        NSDictionary *responseBody = [response ml_JSONValue];
	        NSDictionary *token = [responseBody ml_objectForKey:@"token"];
	        self.appToken = [token ml_objectForKey:@"access_token"];

	        if (successHandler) {
	            successHandler(self.appToken);
			}
		} else {
	        if (failureHandler) {
	            failureHandler(MLAppAuthenticationManagerConnectionError);
			}
		}
	} failureBlock: ^(NSError *error) {
	    if (failureHandler) {
	        failureHandler(MLAppAuthenticationManagerGenericError);
		}
	}];
}

- (NSString *)getAppToken
{
	return self.appToken;
}

- (NSURLRequest *)requestForAppId:(NSString *)appId appSecret:(NSString *)appSecret
{
	NSMutableURLRequest *mutableRequest = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:kAppTokenURL]];
	[mutableRequest setHTTPMethod:@"POST"];

	NSDictionary *myBody = @{@"token" : @{@"grant_type" : @"client_credentials",
	                                      @"client_id" : appId,
	                                      @"client_secret" : appSecret}
	};

	NSData *data = [NSJSONSerialization dataWithJSONObject:myBody options:NSJSONWritingPrettyPrinted error:nil];
	NSString *bodyString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
	NSData *bodyData = [bodyString dataUsingEncoding:NSUTF8StringEncoding];

	[mutableRequest setValue:[NSString stringWithFormat:@"%lu", (unsigned long)[bodyData length]] forHTTPHeaderField:@"Content-Length"];
	[mutableRequest setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
	[mutableRequest setHTTPBody:bodyData];

	return mutableRequest;
}

@end
