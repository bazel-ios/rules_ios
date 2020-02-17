//
// MLWebImageCacheManager.h
// MLNetworking
//
// Created by Roman Babkin on 9/1/15.
// Copyright (c) 2015 MercadoLibre. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MLWebImageCacheManager : NSObject

/**
 *  Sets the maximum cost allowed on memory before objects begin to be removed.
 *  The cost is calculated based on the dimensions of the image: heigth x witdh.
 */
- (void)setMemoryCacheCostLimit:(NSUInteger)costLimit;

/**
 *  Sets the maximum number of bytes allowed on disk.
 *  Defaults to 0.0, meaning no practical limit.
 */
- (void)setDiskCacheByteLimit:(NSUInteger)byteLimit;

/**
 *  Sets the maximum number of seconds an image is allowed to exist in the memory cache
 *  Defaults to 0.0
 */
- (void)setMemoryCacheAgeLimit:(NSTimeInterval)ageLimit;

/**
 *  Sets the maximum number of seconds an image is allowed to exist in the disk cache
 *  Default to 0.0
 */
- (void)setDiskCacheAgeLimit:(NSTimeInterval)ageLimit;

@end
