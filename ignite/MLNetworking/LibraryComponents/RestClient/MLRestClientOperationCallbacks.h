//
// MLRestClientOperationCallbacks.h
// MLNetworking
//
// Created by Nicolas Andres Suarez on 20/2/15.
// Copyright (c) 2015 MercadoLibre. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MLNetworkingOperationDelegate.h"
#import "MLNetworkingOperation.h"

@interface MLRestClientOperationCallbacks : NSObject

@property (nonatomic, copy) NSString *operationIdentifier;
@property (nonatomic, weak) id <MLNetworkingOperationDelegate> delegate;

- (id)initWithOperation:(MLNetworkingOperation *)operation;

@end
