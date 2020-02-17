//
// NSDictionary+MLNetworkingQueryString.h
// MLNetworking
//
// Created by Fabian Celdeiro on 12/22/14.
// Copyright (c) 2014 MercadoLibre. All rights reserved.
//

#import <Foundation/Foundation.h>
__deprecated_msg("Don't use MLNetworkingQueryString, you must use NSURLQueryItem from NSURLComponents library")
@interface NSDictionary (MLNetworkingQueryString)

- (NSString *)mlNetworking_queryString;
@end
