//
// UIImageView+URL.m
// MercadoLibre
//
// Created by Leandro Fantin on 9/12/14.
// Copyright (c) 2014 MercadoLibre - Mobile Apps. All rights reserved.
//

#import "UIImageView+URL.h"
#import <objc/runtime.h>
#import <PINRemoteImage/PINImageView+PINRemoteImage.h>
#import <PINRemoteImage/PINRemoteImageManagerResult.h>
#import <PINRemoteImage/PINRemoteImageManager.h>
#import "MLWebImageResult.h"

static char kBGURLObjectKey;

@implementation UIImageView (URL)

- (NSURL *)ml_url
{
	return (NSURL *)objc_getAssociatedObject(self, &kBGURLObjectKey);
}

- (void)ml_setUrl:(NSURL *)url
{
	objc_setAssociatedObject(self, &kBGURLObjectKey, url, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (void)ml_setImageFromURL:(NSURL *)url
{
	[self ml_setUrl:url];
	[self pin_setImageFromURL:url];
}

- (void)ml_setImageFromURL:(NSURL *)url placeholderImage:(UIImage *)placeholderImage
{
	[self ml_setUrl:url];
	[self pin_setImageFromURL:url placeholderImage:placeholderImage];
}

- (void)ml_setImageFromURL:(NSURL *)url placeholderImage:(UIImage *)placeholderImage completionBlock:(MLWebImageCompletionResult)completionBlock
{
	[self ml_setUrl:url];
	__weak typeof(self) weakSelf = self;

	[self pin_setImageFromURL:url placeholderImage:placeholderImage completion: ^(PINRemoteImageManagerResult *result) {
	    if (completionBlock) {
	        completionBlock([[MLWebImageResult alloc] initWithPINRemoteImageManagerResult:result withImageUrl:[weakSelf ml_url]]);
		}
	}];
}

- (void)ml_setImageFromURL:(NSURL *)url processorKey:(NSString *)processorKey processor:(MLWebImageProcessor)processor completionBlock:(MLWebImageCompletionResult)completionBlock
{
	__weak typeof(self) weakSelf = self;

	[self pin_setImageFromURL:url processorKey:processorKey
	                processor: ^UIImage *(PINRemoteImageManagerResult *result, NSUInteger *cost) {
	    if (processor) {
	        return processor([[MLWebImageResult alloc] initWithPINRemoteImageManagerResult:result withImageUrl:[weakSelf ml_url]], cost);
		} else {
	        return result.image;
		}
	}
	               completion: ^(PINRemoteImageManagerResult *result) {
	    if (completionBlock) {
	        completionBlock([[MLWebImageResult alloc] initWithPINRemoteImageManagerResult:result withImageUrl:[weakSelf ml_url]]);
		}
	}];
}

- (void)ml_cancelRequestOperation
{
	[self pin_cancelImageDownload];
}

@end
