//
// MLRestClientAppTokenAuthenticationOperation.h
// MLNetworking
//
// Created by Fabian Celdeiro on 12/24/14.
// Copyright (c) 2014 MercadoLibre. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MLRestClientAuthenticationOperation.h"

@interface MLRestClientAppTokenAuthenticationOperation : MLRestClientAuthenticationOperation

/**
 *  Application secret key used in the authentication process
 */
@property (nonatomic, readonly) NSString *appSecret;

/**
 *  Initialize the instance
 *
 *  @param appId Application identifier
 *  @param appSecret Application secret key
 *
 *  @return Instance of MLRestClientAppTokenAuthenticationOperation initialized
 */
- (instancetype)initWithAppId:(NSString *)appId
                 andAppSecret:(NSString *)appSecret NS_DESIGNATED_INITIALIZER;

@end
