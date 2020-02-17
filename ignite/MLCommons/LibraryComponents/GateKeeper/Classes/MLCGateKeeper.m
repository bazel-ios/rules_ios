//
// MLGateKeeper.m
// Pods
//
// Created by ITAY BRENNER WERTHEIN on 1/27/17.
//
//

#import "MLCGateKeeper.h"
#import "MLCGateKeeperUserDefaults.h"
#import <MLCommons/NSDictionary+Null.h>

// key to store features in user defaults
static NSString *const kGateKeeperFeaturesDict = @"gateKeeperFeaturesDict";

// key to store configs in user defaults
static NSString *const kGateKeeperConfigDict = @"gateKeeperConfigDict";

// key to store legacy data in user defaults
static NSString *const kGateKeeperDict = @"gateKeeperDict";

// key to store if last use of gatekeeper was in legacy/new mode
static NSString *const kGateKeeperNewScheme = @"last_gate_new_scheme";

static const char *queueLabel = "com.mercadolibre.gatekeeper.queue";
NSString *const MLCGateKeeperUpdatedNotification = @"MLGateKeeperUpdatedNotification";

@interface MLCGateKeeper ()

@property (nonatomic, strong) NSMutableDictionary *features;
@property (nonatomic, strong) NSMutableDictionary *configs;

@property (nonatomic, strong) NSMutableDictionary *gateKeeperInfo __deprecated_msg("deprecated, will be removed");

@property (nonatomic, strong) dispatch_queue_t queue;

@end

@implementation MLCGateKeeper

+ (instancetype)sharedGateKeeper
{
	static id sharedGateKeeper;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		sharedGateKeeper = [[self alloc] init];
	});
	return sharedGateKeeper;
}

- (instancetype)init
{
	self = [super init];
	if (self) {
		self.queue = dispatch_queue_create(queueLabel, DISPATCH_QUEUE_CONCURRENT);
		[self loadFromPreferences];
	}
	return self;
}

- (void)addDictionary:(nullable NSDictionary *) dict __deprecated_msg(
		"deprecated, will be removed")
{
	if (dict) {
		dispatch_barrier_async(self.queue, ^{
			[self.gateKeeperInfo addEntriesFromDictionary:[dict ml_dictionaryByRemovingNullValues]];
			[self syncInternalDataFromLegacy];
			[self saveToPreferencesUsingNewScheme:NO];

			[self scheduleUpdatedNotification];
		});
	}
}

- (void)replaceDictionary:(nullable NSDictionary *) dict __deprecated_msg(
		"deprecated, will be removed")
{
	dispatch_barrier_async(self.queue, ^{
		[self internalReplaceLegacyInfo:[dict ml_dictionaryByRemovingNullValues]];
		[self syncInternalDataFromLegacy];
		[self saveToPreferencesUsingNewScheme:NO];

		[self scheduleUpdatedNotification];
	});
}

- (void)replaceFeatures:(nullable NSDictionary *)features andConfigs:(nullable NSDictionary *)configs
{
	dispatch_barrier_async(self.queue, ^{
		[self internalReplaceFeatures:[features ml_dictionaryByRemovingNullValues] andConfigs:[configs ml_dictionaryByRemovingNullValues]];
		[self syncInternalDataFromNewScheme];
		[self saveToPreferencesUsingNewScheme:YES];

		[self scheduleUpdatedNotification];
	});
}

/**
 * Synchronize new scheme data from a legacy modification.
 * This method modifies new scheme data structure
 *
 * The modification on legacy structure has been applied
 * previous the call to this method
 */
- (void) syncInternalDataFromLegacy __deprecated_msg(
		"deprecated, will be removed")
{
	// copy the full legacy data to both new structures
	// because we don't know with values are features and which one is config
	[self internalReplaceFeatures:self.gateKeeperInfo andConfigs:self.gateKeeperInfo];
}

/**
 * Synchronize legacy scheme data from a new modification.
 * This method modifies new scheme data structure
 *
 * The modification on legacy structure has been applied
 * previous the call to this method
 */
- (void) syncInternalDataFromNewScheme __deprecated_msg(
		"deprecated, will be removed")
{
	// merge the info from features and configs
	NSMutableDictionary *dict = [NSMutableDictionary dictionary];
	if (self.configs) {
		  {
			[dict addEntriesFromDictionary:self.configs];
		}

		if (self.features) {
			[dict addEntriesFromDictionary:self.features];
		}
	}

	[self internalReplaceLegacyInfo:dict];
}

- (void)scheduleUpdatedNotification
{
	// Dispatch on main thread to prevent crashes
	dispatch_async(dispatch_get_main_queue(), ^{
		[[NSNotificationCenter defaultCenter] postNotificationName:MLCGateKeeperUpdatedNotification object:nil];
	});
}

- (void)loadFromPreferences
{
	self.configs = [NSMutableDictionary dictionary];
	self.features = [NSMutableDictionary dictionary];
	self.gateKeeperInfo = [NSMutableDictionary dictionary];

	MLCGateKeeperUserDefaults *userDefaults = [MLCGateKeeperUserDefaults instance];
	BOOL newScheme = [userDefaults boolForKey:kGateKeeperNewScheme];
	if (newScheme) {
		NSDictionary *featuresDict = [userDefaults dictionaryForKey:kGateKeeperFeaturesDict];
		NSDictionary *configDict = [userDefaults dictionaryForKey:kGateKeeperConfigDict];
		[self internalReplaceFeatures:featuresDict andConfigs:configDict];

		[self syncInternalDataFromNewScheme];
	} else {
		NSDictionary *legacyDict = [userDefaults dictionaryForKey:kGateKeeperDict];
		[self internalReplaceLegacyInfo:legacyDict];
		[self syncInternalDataFromLegacy];
	}
}

/**
 * Centralize the replacement of legacy internal data
 *
 * This internal method must be called from a queued task.
 */
- (void)internalReplaceLegacyInfo:(NSDictionary *) legacyDict __deprecated_msg(
		"deprecated, will be removed")
{
	self.gateKeeperInfo = [NSMutableDictionary dictionary];
	if (legacyDict) {
		[self.gateKeeperInfo addEntriesFromDictionary:legacyDict];
	}
}

/**
 * Centralize the replacement of new features/config data
 *
 * This internal method must be called from a queued task.
 */
- (void)internalReplaceFeatures:(nullable NSDictionary *)features andConfigs:(nullable NSDictionary *)configs
{
	self.features = [NSMutableDictionary dictionary];
	if (features) {
		[self.features addEntriesFromDictionary:features];
	}

	self.configs = [NSMutableDictionary dictionary];
	if (configs) {
		[self.configs addEntriesFromDictionary:configs];
	}
}

- (void)saveToPreferencesUsingNewScheme:(BOOL)new
{
	MLCGateKeeperUserDefaults *userDefaults = [MLCGateKeeperUserDefaults instance];
	[userDefaults setObject:self.gateKeeperInfo forKey:kGateKeeperDict];
	[userDefaults setObject:self.features forKey:kGateKeeperFeaturesDict];
	[userDefaults setObject:self.configs forKey:kGateKeeperConfigDict];
	[userDefaults setBool:new forKey:kGateKeeperNewScheme];
	[userDefaults synchronize];
}

- (BOOL)isFeatureEnabled:(NSString *)feature
{
	return [self isFeatureEnabled:feature defaultValue:NO];
}

- (BOOL)isFeatureEnabled:(NSString *)feature defaultValue:(BOOL)value
{
	__block BOOL returnValue;
	dispatch_sync(self.queue, ^() {
		returnValue = [self.features ml_boolForKey:feature defaultValue:value];
	});
	return returnValue;
}

- (nullable NSDictionary *)getConfigByKey:(NSString *)key
{
	__block NSDictionary *returnValue = nil;
	dispatch_sync(self.queue, ^() {
		if ([[self.configs ml_objectForKey:key] isKindOfClass:[NSDictionary class]]) {
		    returnValue = [self.configs ml_objectForKey:key];
		}
	});
	return returnValue;
}

@end
