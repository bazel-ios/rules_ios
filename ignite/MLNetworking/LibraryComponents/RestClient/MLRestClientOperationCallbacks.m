//
// MLRestClientOperationCallbacks.m
// MLNetworking
//
// Created by Nicolas Andres Suarez on 20/2/15.
// Copyright (c) 2015 MercadoLibre. All rights reserved.
//

#import "MLRestClientOperationCallbacks.h"

@implementation MLRestClientOperationCallbacks

- (id)initWithOperation:(MLNetworkingOperation *)operation
{
	self = [super init];
	if (self) {
		self.operationIdentifier = operation.operationIdentifier;
		self.delegate = operation.delegate;
	}
	return self;
}

@end
