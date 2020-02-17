//
// MLIssueTrackerBehaviour.m
// Bugsnag
//
// Created by Cristian Leonel Gibert on 4/11/18.
//

#import "MLIssueTrackerBehaviour.h"
#import "MLIssueTracker.h"

@implementation MLIssueTrackerBehaviour

- (void)viewDidAppear:(BOOL)animated
{
	[super viewDidAppear:animated];
	[MLIssueTracker leaveBreadcrumb:NSStringFromClass([self.viewController class])];
	[MLIssueTracker setTrackingModuleFromViewController:self.viewController];
	[MLIssueTracker setTrackingRepositoryFromViewController:self.viewController];
	[MLIssueTracker setTrackingInitiativeFromViewController:self.viewController];
}

@end
