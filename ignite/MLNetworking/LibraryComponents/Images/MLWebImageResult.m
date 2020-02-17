//
// MLWebImageResult.m
// MLNetworking
//
// Created by Roman Babkin on 9/2/15.
// Copyright (c) 2015 MercadoLibre. All rights reserved.
//

#import "MLWebImageResult.h"

@implementation MLWebImageResult

- (instancetype)initWithPINRemoteImageManagerResult:(PINRemoteImageManagerResult *)pinImageResult withImageUrl:(NSURL *)imageURL
{
	if (self = [super init]) {
		_image = pinImageResult.image;
		_error = pinImageResult.error;
		_imageURL = imageURL;
		_resultType = [MLWebImageResult convertPINRemoteImageResultTypeToMLWebImageResultType:pinImageResult.resultType];
	}
	return self;
}

+ (MLWebImageResultType)convertPINRemoteImageResultTypeToMLWebImageResultType:(PINRemoteImageResultType)resultType
{
	switch (resultType) {
		case PINRemoteImageResultTypeNone: {
			return MLWebImageResultTypeNone;
		}

		case PINRemoteImageResultTypeMemoryCache: {
			return MLWebImageResultTypeMemoryCache;
		}

		case PINRemoteImageResultTypeCache: {
			return MLWebImageResultTypeCache;
		}

		case PINRemoteImageResultTypeDownload: {
			return MLWebImageResultTypeDownload;
		}

		case PINRemoteImageResultTypeProgress: {
			return MLWebImageResultTypeProgress;
		}
	}
}

@end
