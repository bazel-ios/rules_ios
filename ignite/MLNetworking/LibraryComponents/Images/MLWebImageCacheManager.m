//
// MLWebImageCacheManager.m
// MLNetworking
//
// Created by Roman Babkin on 9/1/15.
// Copyright (c) 2015 MercadoLibre. All rights reserved.
//

#import "MLWebImageCacheManager.h"
#import <PINRemoteImage/PINRemoteImageManager.h>
#import <PINCache/PINCache.h>

@implementation MLWebImageCacheManager

- (void)setMemoryCacheCostLimit:(NSUInteger)costLimit
{
	PINCache *cache = [PINRemoteImageManager sharedImageManager].cache;
	[cache.memoryCache setCostLimit:costLimit];
}

- (void)setDiskCacheByteLimit:(NSUInteger)byteLimit
{
	PINCache *cache = [PINRemoteImageManager sharedImageManager].cache;
	[cache.diskCache setByteLimit:byteLimit];
}

- (void)setMemoryCacheAgeLimit:(NSTimeInterval)ageLimit
{
	PINCache *cache = [PINRemoteImageManager sharedImageManager].cache;
	[cache.memoryCache setAgeLimit:ageLimit];
}

- (void)setDiskCacheAgeLimit:(NSTimeInterval)ageLimit
{
	PINCache *cache = [PINRemoteImageManager sharedImageManager].cache;
	[cache.diskCache setAgeLimit:ageLimit];
}

@end
