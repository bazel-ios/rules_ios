//
// MLIssueTracker.h
// Pods
//
// Created by Nicolas Andres Suarez on 8/16/16.
//
//

#import <Foundation/Foundation.h>

/**
 *  Block that will be excecuted before sending a report to the issue tracker
 *  @param mlErroredClassName The class name belonging to the client that produced
 *  the error
 *
 *  @return NSString representing the context of this errored class
 */
typedef NSString *_Nullable (^MLBeforeSendBlock)(NSString *_Nullable mlErroredClassName);

/**
 *  Wrapper class to implement the actual crash tracking library.
 *  Only works in release mode.
 */
@interface MLIssueTracker : NSObject

/**
 *  Set Bugsnag api key
 *
 *  @param bugsnagApiKey bugsnag api key
 */
+ (void)setBugsnagApiKey:(nonnull NSString *)bugsnagApiKey;

/**
 *  Map with module prefix as key and module name as value, that match class prefix to setup context name.
 *
 *  @param moduleNameMapping Dictionary contaning prefix of module as key, and module name as value
 */
+ (void)setModuleNameMapping:(nonnull NSDictionary *)moduleNameMapping;

+ (void)setInitiativeNameMapping:(nonnull NSDictionary *)initiativeNameMapping;

/**
 * Set Enabled
 *
 * @param enabled issue tracking enabled
 */
+ (void)setEnabled:(BOOL)enabled;

+ (void)setAutomaticallyCollectBreadcrumbs:(BOOL)isEnabled;

+ (void)setAutomaticallyReportUncaughtExceptions:(BOOL)isEnabled;

/**
 * @param releaseStagesNames name of release stages that should notify
 */
+ (void)setReleaseStagesThatShouldNotify:(nonnull NSArray *)releaseStagesNames;

/**
 * stage name
 *
 * @param releaseStageName name of the current release stage
 */
+ (void)setCurrentReleaseStage:(nonnull NSString *)releaseStageName;

/**
 *  Set user identifier
 *
 *  @param userId User identifier
 */
+ (void)setUserIdentifier:(nullable NSString *)userId;

/**
 *  Leave a "breadcrumb" log message, to aid with debugging.
 *  It could be the name of viewcontroller that is currently being displayed.
 *
 *  @param breadcrumb Name of the breadcrumb
 */
+ (void)leaveBreadcrumb:(nonnull NSString *)breadcrumb;

/**
 *  It represents the context in which the application is running
 *
 *  @param module Name of the module which is currently running
 */
+ (void)setTrackingModule:(nullable NSString *) module __deprecated_msg("Use setTrackingModuleFromViewController:");

/**
 *  It represents the context in which the application is running
 *
 *  @param viewController Name of the view controller which is currently running
 */
+ (void)setTrackingModuleFromViewController:(nonnull UIViewController *)viewController;

/**
 *  It represents the repository in which the view controller was coded
 *
 *  @param viewController Name of the view controller which is currently running
 */
+ (void)setTrackingRepositoryFromViewController:(nonnull UIViewController *)viewController;

/**
 *  It represents the initiative in which the application is running
 *
 *  @param viewController Name of the view controller which is currently running
 */
+ (void)setTrackingInitiativeFromViewController:(nonnull UIViewController *)viewController;

/**
 *  Logs a Non-fatal exception
 *
 *  @param exception Exception to log.
 */
+ (void)logException:(nonnull NSException *)exception;

/**
 *  Logs a Non-fatal exception with extra info.
 *
 *  @param exception Exception to log.
 *  @param info Further information attached to an error report.
 */
+ (void)logException:(nonnull NSException *)exception withInfo:(nullable NSDictionary *)info;

/**
 * Adds the key-value pair to every error in the specified tab
 */
+ (void)addAlwaysTab:(nonnull NSString *)tab withKey:(nonnull NSString *)key andValue:(nonnull NSString *)value;

/**
 * Remove the key-value pair to every error in the specified tab
 */
+ (void)removeValueForKey:(nonnull NSString *)key tab:(nonnull NSString *)tab;

/**
 *  Set an application prefix witch will be used to filter the clients errored class name
 *  when called to before send block.
 *
 *  @param applicationPrefix Represents the prefix of the clients application
 */
+ (void)setApplicationPrefix:(nonnull NSString *)applicationPrefix;

/**
 *  Adds a before send block to the issue tracker.
 */
+ (void)addBeforeSendBlock:(MLBeforeSendBlock _Nullable)beforeSendBlock;

/**
 *  Returns applications current context.
 */
+ (NSString *)getCurrentContext;

@end
