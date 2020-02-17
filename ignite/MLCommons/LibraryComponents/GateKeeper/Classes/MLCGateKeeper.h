//
// MLGateKeeper.h
// Pods
//
// Created by ITAY BRENNER WERTHEIN on 1/27/17.
//
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/**
 *  This notification is pushed when features are updated
 *  Always are pushed on main thread.
 */
OBJC_EXTERN NSString *const MLCGateKeeperUpdatedNotification;

@interface MLCGateKeeper : NSObject

/**
 *  Shared Instance
 */
+ (instancetype)sharedGateKeeper;

/**
 *  Add Keys and Values to GateKeeper's Dictionary
 *
 */
- (void)addDictionary:(nullable NSDictionary *) dict __deprecated_msg("deprecated, will be removed don't use this method again");

/**
 * Replace GateKeeper Dictionary with a new one
 * This method is deprecated use replaceFeatures:andConfigs: instead
 */
- (void)replaceDictionary:(nullable NSDictionary *) dict __deprecated_msg("deprecated, will be removed, use replaceFeatures:andConfigs:");

/**
 * Replace features and configs values with a new ones
 */
- (void)replaceFeatures:(nullable NSDictionary *)features andConfigs:(nullable NSDictionary *)configs;

/**
 *  Returns whether a feature is enabled or not
 *
 *  @param feature feature
 */
- (BOOL)isFeatureEnabled:(NSString *)feature;

/**
 *  Returns whether a feature is enabled or not, if nil returns default
 *
 *  @param feature feature
 *  @param value default value if nil
 */
- (BOOL)isFeatureEnabled:(NSString *)feature defaultValue:(BOOL)value;

/**
 *  Config for key
 *
 *  @return NSDictionary with the configuration
 *  @param key Configuration name
 */
- (nullable NSDictionary *)getConfigByKey:(NSString *)key;

@end

NS_ASSUME_NONNULL_END
