//
// MLAppAuthenticationManager.h
// Authentication
//
// Created by Cristian Perez Biancucci on 4/8/15.
// Copyright (c) 2015 MercadoLibre. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MLAuthentication/MLAuthenticationConnectionFactoryProtocol.h>
#import <MLAuthentication/MLAuthenticationConnectionProtocol.h>

typedef NS_ENUM (NSInteger, MLAppAuthenticationManagerError) {
	MLAppAuthenticationManagerGenericError    = 0,
	MLAppAuthenticationManagerConnectionError = 1,
};

@interface MLAppAuthenticationManager : NSObject

@property (nonatomic, strong) id <MLAuthenticationConnectionFactoryProtocol> connectionFactory;

+ (MLAppAuthenticationManager *)sharedInstance;

+ (MLAppAuthenticationManager *)initializeWithConnectionFactory:(id <MLAuthenticationConnectionFactoryProtocol>)connectionFactory;

- (void)createAppTokenWithAppId:(NSString *)appId
                      appSecret:(NSString *)appSecret
                        success:(void (^)(NSString *appToken))successHandler
                        failure:(void (^)(MLAppAuthenticationManagerError error))failureHandler;

- (void)createAppTokenWithAppId:(NSString *)appId
                      appSecret:(NSString *)appSecret
               connectionObject:(id <MLAuthenticationConnectionProtocol>)connectionObject
                        success:(void (^)(NSString *appToken))successHandler
                        failure:(void (^)(MLAppAuthenticationManagerError error))failureHandler;

- (NSString *)getAppToken;

@end
