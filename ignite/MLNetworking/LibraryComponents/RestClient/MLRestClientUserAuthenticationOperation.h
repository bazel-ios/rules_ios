//
// MLRestClientUserAuthenticationOperation.h
// MLNetworking
//
// Created by Fabian Celdeiro on 12/16/14.
// Copyright (c) 2014 MercadoLibre. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MLRestClientAuthenticationOperation.h"

@interface MLRestClientUserAuthenticationOperation : MLRestClientAuthenticationOperation

/**
 *  Initialize the instance
 *
 *  @param appId Application identifier
 *  @param authMode Authentication mode
 *
 *  @return Instance of MLRestClientUserAuthenticationOperation initialized
 */
- (instancetype)initWithAppId:(NSString *)appId
           authenticationMode:(MLRestClientAuthenticationMode)authMode NS_DESIGNATED_INITIALIZER;

@end
