//
// MKAnnotationView+URL.m
// Pods
//
// Created by Leo Salmaso on 10/09/2018.
//

#import <PINRemoteImage/PINRemoteImageManager.h>
#import "MKAnnotationView+MLURL.h"

@implementation MKAnnotationView (URL)

- (void)ml_setImageWithURL:(nonnull NSURL *)url placeholderImage:(UIImage *)placeholder
{
	[self ml_setImageWithURL:url placeholderImage:placeholder withSize:CGSizeZero];
}

- (void)ml_setImageWithURL:(nonnull NSURL *)url placeholderImage:(UIImage *)placeholder withSize:(CGSize)size
{
	// When the size is zero lets just add the placeholder
	if (CGSizeEqualToSize(size, CGSizeZero)) {
		self.image = placeholder;
	} else {
		// Otherwise, lets check if there is an existing image
		if (self.image == nil) {
			self.image = [self scaleImage:placeholder toSize:size];
		} else {
			self.image = placeholder;
		}
	}

	[[PINRemoteImageManager sharedImageManager] downloadImageWithURL:url completion: ^(PINRemoteImageManagerResult *_Nonnull result) {
	    if (result.error == nil) {
	        dispatch_async(dispatch_get_main_queue(), ^{
							   if (self.image == nil) {
							       self.image = CGSizeEqualToSize(size, CGSizeZero) ? result.image : [self scaleImage:result.image
							                                                                                   toSize:size];
							   } else {
							       [CATransaction begin];
							       [CATransaction setAnimationDuration:0.3];
							       [CATransaction setAnimationTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut]];
							       [UIView animateWithDuration:0.3 animations: ^{
							           self.centerOffset = CGPointMake(0, -size.height / 2);
							           self.image = [self scaleImage:result.image toSize:size];
								   }];
							       [CATransaction commit];
							   }
						   });
		}
	}];
}

- (UIImage *)scaleImage:(UIImage *)image toSize:(CGSize)targetSize
{
	UIGraphicsBeginImageContextWithOptions(targetSize, NO, 0);
	[image drawInRect:CGRectMake(0, 0, targetSize.width, targetSize.height)];
	UIImage *scaledImage = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();
	return scaledImage;
}

@end
