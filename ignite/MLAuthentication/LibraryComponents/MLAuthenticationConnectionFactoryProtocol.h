//
// MLAuthenticationConnectionFactoryProtocol.h
// Authentication
//
// Created by Cristian Perez Biancucci on 2/24/15.
// Copyright (c) 2015 MercadoLibre S.A. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MLAuthentication/MLAuthenticationConnectionProtocol.h>

@protocol MLAuthenticationConnectionFactoryProtocol <NSObject>

- (id <MLAuthenticationConnectionProtocol>)newAuthenticationConnection;

@end
