//
// MLLocationManager.m
// MLCommons
//
// Created by Mauricio Minestrelli on 10/24/16.
// Copyright © 2016 MercadoLibre. All rights reserved.
//

#import "MLLocationManager.h"
#import <SystemConfiguration/CaptiveNetwork.h>
#import <NetworkExtension/NEHotspotHelper.h>
#import <MLReachability/MLReachability.h>
#import "MLLocationUserDefaults.h"
#import <CoreLocation/CoreLocation.h>

NSString *const kMLLocationFoundNotificationName = @"MLLocationFound";
NSString *const kMLLocationErrorNotificationName = @"MLLocationError";
NSString *const kMLLocationFoundUserInfoKey = @"MLLocationFoundUserInfoKey";
NSString *const kMLLocationErrorUserInfoKey = @"MLLocationErrorUserInfoKey";
NSString *const kMLLocationDomain = @"com.mercadolibre.commons";
NSString *const kMLLocationChangeAuthorizationStatusAuthorized = @"MLLocationAuthorizationAuthorized";
NSString *const kMLLocationChangeAuthorizationStatusNotAuthorized = @"MLLocationAuthorizationNotAuthorized";

static CGFloat const kMLLocationDefaultTimeout = 10.0;

@interface MLLocationManager () <CLLocationManagerDelegate>
/** The instance of CLLocationManager encapsulated by this class. */
@property (nonatomic, strong) CLLocationManager *locationManager;
@property (nonatomic) NSTimeInterval timeout;
@property (nonatomic, strong) NSTimer *timer;

@end

@implementation MLLocationManager

void dispatch_once_on_main_thread(
	dispatch_once_t *predicate,
	dispatch_block_t block)
{
	if ([NSThread isMainThread]) {
		dispatch_once(predicate, block);
	} else {
		if (DISPATCH_EXPECT(*predicate == 0L, NO)) {
			dispatch_sync(dispatch_get_main_queue(), ^{
				dispatch_once(predicate, block);
			});
		}
	}
}

+ (instancetype)sharedInstance
{
	static MLLocationManager *_instance;
	static dispatch_once_t _onceToken;
	dispatch_once_on_main_thread(&_onceToken, ^{
		_instance = [[self alloc] init];
	});
	return _instance;
}

- (id)init
{
	self = [super init];

	if (self) {
		self.locationManager = [[CLLocationManager alloc] init];
		self.locationManager.delegate = self;
	}

	return self;
}

- (void)obtainLocation:(BOOL)forced
{
	self.timeout = kMLLocationDefaultTimeout;
	[self getCurrentLocation:forced];
}

- (void)getCurrentLocation:(BOOL)forced
{
	MLReachability *reachability = [MLReachability reachabilityForInternetConnection];
	MLNetworkStatus networkStatus = [reachability currentReachabilityStatus];

	if (networkStatus == MLReachableViaWiFi) {
		NSString *bssid = [self retrieveNetworkBSSID];
		MLLocationCoordinate *coordinate = [self attemptLocationRetrievalWithBSSID:bssid];

		// Saved and not expired, post from user defaults.
		if (coordinate && ![coordinate isExpired]) {
			[[NSNotificationCenter defaultCenter] postNotificationName:kMLLocationFoundNotificationName object:nil userInfo:@{kMLLocationFoundUserInfoKey : coordinate}];
			return;
		}
		// Expired or not saved. Localize and save if success.
		[self localize];
		return;
	} else {
	    if (forced) {
	        [self localize];
	        return;
		}
	    [self postMLLocationErrorWithError:[self mlLocationErrorFromAuthorizationError]];
	}
}

- (void)obtainLocation:(BOOL)forced withTimeout:(NSTimeInterval)timeout
{
    self.timeout = timeout;
    [self getCurrentLocation:forced];
}

- (MLLocationCoordinate *)obtainSavedLocation
{
    if (@available(iOS 13.0, *)) {
        return nil;
	}

    MLReachability *reachability = [MLReachability reachabilityForInternetConnection];
    MLNetworkStatus networkStatus = [reachability currentReachabilityStatus];

    if (networkStatus == MLReachableViaWiFi) {
        NSString *bssid = [self retrieveNetworkBSSID];
        MLLocationCoordinate *coordinate = [self attemptLocationRetrievalWithBSSID:bssid];

        // Saved and not expired, return from user defaults.
        if (coordinate && ![coordinate isExpired]) {
            return coordinate;
		}
	}
    return nil;
}

- (void)stopObtainingLocation
{
    [self.locationManager stopUpdatingLocation];
}

+ (CLAuthorizationStatus)authorizationStatus
{
    return [CLLocationManager authorizationStatus];
}

+ (BOOL)locationServicesEnabled
{
    return [CLLocationManager locationServicesEnabled];
}

- (void)requestWhenInUseAuthorization
{
    return [self.locationManager requestWhenInUseAuthorization];
}

#pragma mark - Private methods

- (NSString *)retrieveNetworkBSSID
{
    if (@available(iOS 13.0, *)) {
        return nil;
	}

    NSString *bssid = nil;
    NSArray *interFaceNames = (__bridge_transfer id)CNCopySupportedInterfaces();

    if ([interFaceNames count] > 0) {
        NSDictionary *info = (__bridge_transfer id)CNCopyCurrentNetworkInfo((__bridge CFStringRef)interFaceNames[0]);

        if (info[@"BSSID"]) {
            bssid = info[@"BSSID"];
		}
	}

#if TARGET_IPHONE_SIMULATOR
    // Return a mocked BSSID to use in debugging
    bssid = @"50:50:50:50:50:50";
#endif
    return bssid;
}

- (MLLocationCoordinate *)attemptLocationRetrievalWithBSSID:(NSString *)bssid
{
    if (bssid == nil) {
        return nil;
	}

    if (@available(iOS 13.0, *)) {
        return nil;
	}

    MLLocationUserDefaults *userDefaults = [MLLocationUserDefaults locationUserDefaults];
    NSDictionary *dict = [userDefaults objectForKey:bssid];
    MLLocationCoordinate *coordinate = [[MLLocationCoordinate alloc]initWithDictionary:dict];

    return coordinate;
}

- (void)localize
{
    if ([CLLocationManager locationServicesEnabled] && [CLLocationManager authorizationStatus] == kCLAuthorizationStatusAuthorizedWhenInUse) {
        [self requestLocationWithAccuracy:kCLLocationAccuracyNearestTenMeters];
	} else {
        [self postMLLocationErrorWithError:[self mlLocationErrorFromAuthorizationError]];
	}
}

- (void)requestLocationWithAccuracy:(CLLocationAccuracy)accuracy
{
    // In case a previous timer was fired, we invalidate it.
    [self invalidateTimer];

    // Create timer to stop location after timeout.
    self.timer = [NSTimer scheduledTimerWithTimeInterval:self.timeout target:self selector:@selector(locationTimeoutReached) userInfo:nil repeats:NO];

    self.locationManager.desiredAccuracy = accuracy;
    [self.locationManager startUpdatingLocation];
}

- (void)saveNetworkWithLocation:(MLLocationCoordinate *)location andBSSID:(NSString *)bssid
{
    if (bssid) {
        MLLocationUserDefaults *userDefaults = [MLLocationUserDefaults locationUserDefaults];
        [userDefaults setObject:[location dictionaryRepresentation] forKey:bssid];
        [userDefaults synchronize];
	}
}

#pragma mark - Notification posting
- (void)postMLLocationErrorWithError:(NSError *)error
{
    [[NSNotificationCenter defaultCenter] postNotificationName:kMLLocationErrorNotificationName object:nil userInfo:@{kMLLocationErrorUserInfoKey : error}];
}

#pragma mark - Errors
- (NSError *)mlLocationErrorFromAuthorizationError
{
    NSInteger code;
    NSDictionary *userInfo = nil;
    switch ([CLLocationManager authorizationStatus]) {
		case kCLAuthorizationStatusNotDetermined: {
			code = kMLLocationErrorLocationAuthorizationStatusNotDetermined;
			userInfo = @{NSLocalizedDescriptionKey : @"Location authorization status not determined"};
			break;
		}

		case kCLAuthorizationStatusRestricted: {
			code = kMLLocationErrorLocationAuthorizationStatusRestricted;
			userInfo = @{NSLocalizedDescriptionKey : @"Location authorization status restricted"};
			break;
		}

		case kCLAuthorizationStatusDenied: {
			code = kMLLocationErrorLocationAuthorizationStatusDenied;
			userInfo = @{NSLocalizedDescriptionKey : @"Location authorization status denied"};
			break;
		}

		default: {
			code = kMLLocationErrorLocationServicesUnavailable;
			userInfo = @{NSLocalizedDescriptionKey : @"Location services unavailable"};
			break;
		}
	}
    NSError *error = [[NSError alloc]initWithDomain:kMLLocationDomain code:code userInfo:userInfo];
    return error;
}

- (NSError *)mlLocationErrorFromClError:(NSError *)clError
{
    NSInteger code;
    NSDictionary *userInfo = nil;

    switch (clError.code) {
		case kCLErrorLocationUnknown: {
			code = kMLLocationErrorLocationUnknown;
			userInfo = @{NSLocalizedDescriptionKey : @"Location is currently unknown, but CL will keep trying"};
			break;
		}

		case kCLErrorDenied: {
			code = kMLLocationErrorDenied;
			userInfo = @{NSLocalizedDescriptionKey : @"Access to location or ranging has been denied by the user"};
			break;
		}

		case kCLErrorNetwork: {
			code = kMLLocationErrorNetwork;
			userInfo = @{NSLocalizedDescriptionKey : @"General, network-related error"};
			break;
		}

		case kCLErrorRangingFailure: {
			code = kMLLocationErrorRangingFailure;
			userInfo = @{NSLocalizedDescriptionKey : @"Ranging cannot be performed"};
			break;
		}

		case kCLErrorRangingUnavailable: {
			code = kMLLocationErrorRangingUnavailable;
			userInfo = @{NSLocalizedDescriptionKey : @"General ranging failure"};
			break;
		}

		default: {
			code = kMLLocationErrorDefaultError;
			userInfo = @{NSLocalizedDescriptionKey : @"Default location error"};
			break;
		}
	}
    NSError *error = [[NSError alloc]initWithDomain:kMLLocationDomain code:code userInfo:userInfo];
    return error;
}

#pragma mark - CCLocationManagerDelegate

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    [self invalidateTimer];

    [self.locationManager stopUpdatingLocation];
    [self postMLLocationErrorWithError:[self mlLocationErrorFromClError:error]];
}

- (void)locationManager:(CLLocationManager *)manager
     didUpdateLocations:(NSArray <CLLocation *> *)locations
{
    [self invalidateTimer];

    [self.locationManager stopUpdatingLocation];
    CLLocation *currentLocation = [locations lastObject];
    NSString *bssid = [self retrieveNetworkBSSID];
    MLLocationCoordinate *coordinate = [[MLLocationCoordinate alloc] initWithLocation:currentLocation];

    [self saveNetworkWithLocation:coordinate andBSSID:bssid];
    [[NSNotificationCenter defaultCenter] postNotificationName:kMLLocationFoundNotificationName object:nil userInfo:@{kMLLocationFoundUserInfoKey : coordinate}];
}

- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status
{
    if (status == kCLAuthorizationStatusRestricted || status == kCLAuthorizationStatusDenied) {
        [[NSNotificationCenter defaultCenter] postNotificationName:kMLLocationChangeAuthorizationStatusNotAuthorized object:nil userInfo:nil];
	}

    if (status == kCLAuthorizationStatusAuthorizedAlways || status == kCLAuthorizationStatusAuthorizedWhenInUse) {
        [[NSNotificationCenter defaultCenter] postNotificationName:kMLLocationChangeAuthorizationStatusAuthorized object:nil userInfo:nil];
	}
}

#pragma mark - NSTimer method

- (void)locationTimeoutReached
{
    [self invalidateTimer];

    [self.locationManager stopUpdatingLocation];

    // Create NSError with timeout error code and description
    NSError *timeoutError = [[NSError alloc] initWithDomain:kMLLocationDomain code:kMLLocationErrorTimeout userInfo:@{NSLocalizedDescriptionKey : @"Timeout obtaining location"}];

    [self postMLLocationErrorWithError:timeoutError];
}

- (void)invalidateTimer
{
    [self.timer invalidate];
    self.timer = nil;
}

@end
