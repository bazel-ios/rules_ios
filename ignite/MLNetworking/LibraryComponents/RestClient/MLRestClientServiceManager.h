//
// MLRestClientServiceManager.h
// MLNetworking
//
// Created by Fabian Celdeiro on 12/20/14.
// Copyright (c) 2014 MercadoLibre. All rights reserved.
//

#import <Foundation/Foundation.h>

@class MLRestClientService;

@interface MLRestClientServiceManager : NSObject

- (void)enqueueService:(MLRestClientService *)service;

+ (MLRestClientServiceManager *)sharedInstance;

@end
