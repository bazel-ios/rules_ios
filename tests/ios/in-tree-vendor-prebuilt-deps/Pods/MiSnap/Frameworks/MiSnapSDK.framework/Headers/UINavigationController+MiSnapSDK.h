//
//  UINavigationController+MiSnapSDK.h
//  MiSnap
//
//  Created by Stas Tsuprenko on 4/12/17.
//  Copyright © 2017 mitek. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UINavigationController (MiSnapSDK)

- (UIInterfaceOrientationMask)supportedInterfaceOrientations;

- (BOOL)shouldAutorotate;

@end
