//
// MLConfigurationJSON.h
// MLNetworking
//
// Created by Fabian Celdeiro on 12/5/14.
// Copyright (c) 2014 MercadoLibre. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MLNetworkingConfiguration.h"

NS_ASSUME_NONNULL_BEGIN

@interface MLNetworkingConfigurationDataJSON : MLNetworkingConfiguration

@property (nonatomic, strong, nullable) NSDictionary *bodyDic;

@end

NS_ASSUME_NONNULL_END
