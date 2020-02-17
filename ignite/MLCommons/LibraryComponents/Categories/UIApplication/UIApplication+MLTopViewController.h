//
// UIApplication+MLTopViewController.h
// MLCommons
//
// Created by MAURO CARREÑO on 3/22/17.
// Copyright © 2017 MercadoLibre. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UIApplication (MLTopViewController)

/**
 * Returns the top most visible view controller.
 */
+ (UIViewController *)ml_topViewController;

@end
