//
// MLNetworkingConfigurationDataCustomURLRequest.h
// MLNetworking
//
// Created by Fabian Celdeiro on 12/18/14.
// Copyright (c) 2014 MercadoLibre. All rights reserved.
//

#import "MLNetworkingConfiguration.h"
#import "MLNetworkingConfigurationDataJSON.h"

@interface MLNetworkingConfigurationDataCustomURLRequest : MLNetworkingConfigurationDataJSON

@property (nonatomic, strong) NSURLRequest *customURLRequest;

@end
