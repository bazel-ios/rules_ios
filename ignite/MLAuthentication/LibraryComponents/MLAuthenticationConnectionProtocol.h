//
// MLAuthenticationConnectionProtocol.h
// Authentication
//
// Created by Christian Perez Biancucci on 2/18/15.
// Copyright (c) 2015 MercadoLibre S.A. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol MLAuthenticationConnectionProtocol <NSObject>

- (void)makeRequestWithURLRequest:(NSURLRequest *)request
                  completionBlock:(void (^)(NSData *responseData))completionBlock
                     failureBlock:(void (^)(NSError *error))failureBlock;

- (void)invalidate;

@end
