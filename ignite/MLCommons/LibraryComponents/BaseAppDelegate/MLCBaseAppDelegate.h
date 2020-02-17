//
// MLBaseAppDelegate.h
// MLCommons
//
// Created by Santiago Lazzari on 29/07/2019.
//

#import <UIKit/UIKit.h>

@class MLCAppBehaviourManager;

NS_ASSUME_NONNULL_BEGIN

@interface MLCBaseAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

- (void)applicationIsSubscribingAppBehaviours:(MLCAppBehaviourManager *)behaviourManager;

@end

NS_ASSUME_NONNULL_END
