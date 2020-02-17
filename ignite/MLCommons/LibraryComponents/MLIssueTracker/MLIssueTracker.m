//
// MLIssueTracker.m
// Pods
//
// Created by Nicolas Andres Suarez on 8/16/16.
//
//

#import "MLIssueTracker.h"
#import <Bugsnag/Bugsnag.h>
#import "NSDictionary+MLKeyWithRange.h"
#import "MLCCanejoBehaviourProtocol.h"

@interface MLIssueTracker ()

@end

@implementation MLIssueTracker

static NSString *_bugsnagApiKey = nil;
static BOOL _enabled = NO;
static NSString *_applicationPrefix = nil;
static NSDictionary *_moduleNameMapping = nil;
static NSDictionary *_initiativeNameMapping = nil;

static NSString *const kBsCrashKey = @"crash";
static NSString *const kBsThreadsKey = @"threads";
static NSString *const kBsBacktraceKey = @"backtrace";
static NSString *const kBsContentsKey = @"contents";
static NSString *const kBsCrashedKey = @"crashed";
static NSString *const kBsSymbolNameKey = @"symbol_name";
static NSString *const kIssueTrackerErroredClassRegex = @"[^\\s]*";
static NSString *const kDefaultModuleNameKey = @"default";
static NSString *const kDefaultInitiativeNameKey = @"default";
static NSString *const kInitiativeKey = @"initiative";
static NSString *const kRepositoryKey = @"repository_name";
static NSString *const MLIssueTrackerDefaultCustomDataTab = @"EXTRA";

+ (NSString *)appVersion
{
	return [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
}

+ (void)setBugsnagApiKey:(NSString *)bugsnagApiKey
{
	_bugsnagApiKey = [bugsnagApiKey copy];
}

+ (void)setModuleNameMapping:(NSDictionary *)moduleNameMapping
{
	_moduleNameMapping = [moduleNameMapping copy];
}

+ (void)setInitiativeNameMapping:(nonnull NSDictionary *)initiativeNameMapping
{
	_initiativeNameMapping = [initiativeNameMapping copy];
}

+ (void)setEnabled:(BOOL)enabled
{
	_enabled = enabled && _bugsnagApiKey.length > 0;
	if (_enabled) {
		[Bugsnag startBugsnagWithApiKey:_bugsnagApiKey];
		[Bugsnag configuration].appVersion = [self appVersion];
		[Bugsnag configuration].shouldAutoCaptureSessions = YES;
	}
}

+ (BOOL)enabled
{
	return _enabled;
}

+ (void)setAutomaticallyCollectBreadcrumbs:(BOOL)isEnabled
{
	[Bugsnag configuration].automaticallyCollectBreadcrumbs = isEnabled;
}

+ (void)setAutomaticallyReportUncaughtExceptions:(BOOL)isEnabled
{
	[Bugsnag configuration].autoNotify = isEnabled;
}

+ (void)setReleaseStagesThatShouldNotify:(NSArray *)releaseStagesNames
{
	[Bugsnag configuration].notifyReleaseStages = releaseStagesNames;
}

+ (void)setCurrentReleaseStage:(NSString *)releaseStageName
{
	[Bugsnag configuration].releaseStage = releaseStageName;
}

+ (void)setUserIdentifier:(NSString *)userId
{
	if ([MLIssueTracker enabled]) {
		[[Bugsnag configuration] setUser:userId
		                        withName:nil
		                        andEmail:nil];
	}
}

+ (void)leaveBreadcrumb:(NSString *)breadcrumb
{
	if ([MLIssueTracker enabled]) {
		[Bugsnag leaveBreadcrumbWithMessage:breadcrumb];
	}
}

+ (void)setTrackingModule:(NSString *)module
{
	if ([MLIssueTracker enabled]) {
		[Bugsnag configuration].context = module;
	}
}

+ (void)setTrackingModuleFromViewController:(nonnull UIViewController *)viewController
{
	if ([MLIssueTracker enabled]) {
		NSString *context;
		if ([viewController conformsToProtocol:@protocol(MLCCanejoBehaviourProtocol)]) {
			context = [(id <MLCCanejoBehaviourProtocol>)viewController context];
		} else {
			context = [self initiativeNameFrom:viewController];
		}

		[Bugsnag configuration].context = context;
	}
}

+ (void)setTrackingRepositoryFromViewController:(nonnull UIViewController *)viewController
{
	NSString *repositoryName = [self moduleNameFrom:viewController];
	[self trackOnExtraTabWithKey:kRepositoryKey andValue:repositoryName];
}

+ (void)setTrackingInitiativeFromViewController:(nonnull UIViewController *)viewController
{
	NSString *initiativeName = [self initiativeNameFrom:viewController];
	[self trackOnExtraTabWithKey:kInitiativeKey andValue:initiativeName];
}

+ (void)trackOnExtraTabWithKey:(nonnull NSString *)key andValue:(nonnull NSString *)value
{
	if (MLIssueTracker.enabled) {
		[self addAlwaysTab:MLIssueTrackerDefaultCustomDataTab withKey:key andValue:value];
	}
}

+ (NSString *)moduleNameFrom:(UIViewController *)viewController
{
	NSString *className = NSStringFromClass(viewController.class);
	return [_moduleNameMapping firstValueForKeyInRangeOfString:className] ? : [_moduleNameMapping valueForKey:kDefaultModuleNameKey];
}

+ (NSString *)initiativeNameFromClassName:(NSString *)className
{
	return [_initiativeNameMapping firstValueForKeyInRangeOfString:className] ? : [_initiativeNameMapping valueForKey:kDefaultInitiativeNameKey];
}

+ (NSString *)initiativeNameFrom:(UIViewController *)viewController
{
	NSString *className = NSStringFromClass(viewController.class);
	return [self initiativeNameFromClassName:className];
}

+ (void)logException:(NSException *)exception
{
	if ([MLIssueTracker enabled]) {
		[Bugsnag notify:exception];
	}
}

+ (void)logException:(NSException *)exception withInfo:(NSDictionary *)info
{
	if ([MLIssueTracker enabled]) {
		[Bugsnag notify:exception block: ^(BugsnagCrashReport *report) {
		    [report addMetadata:info toTabWithName:MLIssueTrackerDefaultCustomDataTab];
		}];
	}
}

+ (void)addAlwaysTab:(nonnull NSString *)tab withKey:(nonnull NSString *)key andValue:(nonnull NSString *)value
{
	if ([MLIssueTracker enabled]) {
		[Bugsnag addAttribute:key withValue:value toTabWithName:tab];
	}
}

+ (void)removeValueForKey:(nonnull NSString *)key tab:(nonnull NSString *)tab
{
	if ([MLIssueTracker enabled]) {
		[Bugsnag addAttribute:key withValue:nil toTabWithName:tab];
	}
}

+ (void)setApplicationPrefix:(NSString *)applicationPrefix
{
	_applicationPrefix = applicationPrefix;
}

+ (void)setContextUsingErroredClassNameWithRawEventData:(NSDictionary *_Nonnull)rawEventData reports:(BugsnagCrashReport *_Nonnull)reports beforeSendBlock:(MLBeforeSendBlock _Nullable)beforeSendBlock
{
	// When prefix is not set, then it doesnt make sense to have any context
	if (_applicationPrefix == nil) {
		return;
	}

	NSString *mlErroredClassName = nil;

	for (NSDictionary *thread in rawEventData[kBsCrashKey][kBsThreadsKey]) {
		NSArray *backtrace = thread[kBsBacktraceKey][kBsContentsKey];

		// When the atribute kCrashedKey is 1 means the current thread is the one that crashed
		if ([thread[kBsCrashedKey] integerValue] != 1) {
			continue;
		}

		for (NSDictionary *event in backtrace) {
			NSString *eventSymbolName = event[kBsSymbolNameKey];
			NSString *regexWithPrefix = [_applicationPrefix stringByAppendingString:kIssueTrackerErroredClassRegex];
			NSRange erroredClassNameRange = [eventSymbolName rangeOfString:regexWithPrefix options:NSRegularExpressionSearch];

			if (erroredClassNameRange.location == NSNotFound || erroredClassNameRange.length == 0) {
				continue;
			}

			mlErroredClassName = [eventSymbolName substringWithRange:erroredClassNameRange];

			break;
		}
		break;
	}

	if (mlErroredClassName != nil) {
		reports.context = beforeSendBlock(mlErroredClassName);
	}
}

+ (void)addBeforeSendBlock:(MLBeforeSendBlock _Nullable)beforeSendBlock
{
	[[Bugsnag configuration] addBeforeSendBlock: ^bool (NSDictionary *_Nonnull rawEventData, BugsnagCrashReport *_Nonnull reports) {
	    [self setContextUsingErroredClassNameWithRawEventData:rawEventData reports:reports beforeSendBlock:beforeSendBlock];
	    return YES;
	}];
}

+ (NSString *)getCurrentContext {
	return [[Bugsnag configuration] context];
}

@end
