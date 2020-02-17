//
// MKAnnotationView+URL.h
// Pods
//
// Created by Leo Salmaso on 10/09/2018.
//

#import <MapKit/MapKit.h>
#import <UIKit/UIKit.h>

@interface MKAnnotationView (URL)

- (void)ml_setImageWithURL:(nonnull NSURL *)url placeholderImage:(UIImage *)placeholder;
- (void)ml_setImageWithURL:(nonnull NSURL *)url placeholderImage:(UIImage *)placeholder withSize:(CGSize)size;

@end
