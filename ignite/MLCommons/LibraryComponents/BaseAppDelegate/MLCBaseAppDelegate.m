//
// MLBaseAppDelegate.m
// MLCommons
//
// Created by Santiago Lazzari on 29/07/2019.
//

#import "MLCBaseAppDelegate.h"
#import "ignite/MLCommons_swift-Swift.h"


@interface MLCBaseAppDelegate ()

@property (strong, nonatomic) MLCAppBehaviourManager *behaviourManager;

@end

@implementation MLCBaseAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
	self.behaviourManager = [[MLCAppBehaviourManager alloc] init];

	[self applicationIsSubscribingAppBehaviours:self.behaviourManager];
	[self.behaviourManager applicationIsConfiguringModules];
	[self.behaviourManager applicationDidConfigureModules];

	return true;
}

- (void)applicationIsSubscribingAppBehaviours:(MLCAppBehaviourManager *)behaviourManager {
	// Might be overriten
}

@end
