//
// MLRestClientAuthenticationConnectionFactory.m
// MLNetworking
//
// Created by Nicolas Andres Suarez on 27/4/15.
// Copyright (c) 2015 MercadoLibre. All rights reserved.
//

#import "MLRestClientAuthenticationConnectionFactory.h"
#import "MLRestClientAuthenticationConnection.h"

@implementation MLRestClientAuthenticationConnectionFactory

- (id <MLAuthenticationConnectionProtocol>)newAuthenticationConnection
{
	return [[MLRestClientAuthenticationConnection alloc] init];
}

@end
