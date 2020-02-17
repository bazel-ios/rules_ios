//
// MLWebImageResult.h
// MLNetworking
//
// Created by Roman Babkin on 9/2/15.
// Copyright (c) 2015 MercadoLibre. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <PINRemoteImage/PINRemoteImageManagerResult.h>

/** How the image was fetched. */
typedef NS_ENUM (NSUInteger, MLWebImageResultType) {
	/** Returned if no image is returned */
	MLWebImageResultTypeNone = 0,
	/** Image was fetched from the memory cache */
	MLWebImageResultTypeMemoryCache,
	/** Image was fetched from the disk cache */
	MLWebImageResultTypeCache,
	/** Image was downloaded */
	MLWebImageResultTypeDownload,
	/** Image is image is downloading */
	MLWebImageResultTypeProgress
};

@interface MLWebImageResult : NSObject

@property (nonatomic, readonly, strong) UIImage *image;
@property (nonatomic, readonly, strong) NSError *error;
@property (nonatomic, readonly, strong) NSURL *imageURL;
@property (nonatomic, readonly, assign) MLWebImageResultType resultType;

- (instancetype)initWithPINRemoteImageManagerResult:(PINRemoteImageManagerResult *)pinImageResult withImageUrl:(NSURL *)imageURL;

@end
