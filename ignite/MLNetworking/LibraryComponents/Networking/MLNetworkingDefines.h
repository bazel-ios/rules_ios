//
// MLNetworkingDefines.h
// MLNetworking
//
// Created by Fabian Celdeiro on 1/29/15.
// Copyright (c) 2015 MercadoLibre. All rights reserved.
//

#import <Foundation/Foundation.h>

#define MLNETWORKING_ASSERT_NOT_MAIN_THREAD NSAssert(![NSThread isMainThread], @"This method must not be called on the main thread");

#ifdef DEBUG
	#define  MLNetworkingLog(text, ...) NSLog(text, ## __VA_ARGS__)
#else
	#define  MLNetworkingLog(text, ...)
#endif

#define MLNetworkingDynamicCast(x, c) ((c *)([x isKindOfClass:[c class]] ? x : nil))
