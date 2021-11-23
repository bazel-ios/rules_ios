//
//  MiSnapSDKResourceLocator.h
//  MiSnap
//
//  Created by Greg Fisch on 11/4/14.
//  Copyright (c) 2014 mitek. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "MiSnapSDKParameters.h"


@interface MiSnapSDKResourceLocator : NSObject

@property (nonatomic, weak) NSString* languageKey;

- (UIImage*)getLocalizedImage:(NSString *)imageName;
- (UIImage*)getLocalizedImage:(NSString *)imageName withOrientation:(UIInterfaceOrientation)orientation withOrientationMode:(MiSnapOrientationMode)orientationMode;
- (UIImage*)getLocalizedTutorialImage:(NSString *)imageName withOrientation:(UIInterfaceOrientation)orientation withOrientationMode:(MiSnapOrientationMode)orientationMode;
- (NSString*)getLocalizedString:(NSString*)key;

+ (MiSnapSDKResourceLocator *)initWithLanguageKey:(NSString*)key;

@end
