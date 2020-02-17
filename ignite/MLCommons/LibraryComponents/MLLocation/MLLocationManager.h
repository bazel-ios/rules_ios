//
// MLLocationManager.h
// MLCommons
//
// Created by Mauricio Minestrelli on 10/24/16.
// Copyright © 2016 MercadoLibre. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MLLocationCoordinate.h"
NS_ASSUME_NONNULL_BEGIN
typedef NS_ENUM (NSInteger, MLLocationErrors) {
	kMLLocationErrorLocationServicesUnavailable = 0,   // location is currently unknown
	kMLLocationErrorLocationAuthorizationStatusNotDetermined,   // User has not yet made a choice with regards to this application
	kMLLocationErrorLocationAuthorizationStatusRestricted,  // This application is not authorized to use location services.  Due to active restrictions on location services, the user cannot change this status, and may not have personally denied authorization
	kMLLocationErrorLocationAuthorizationStatusDenied,  // User has explicitly denied authorization for this application, or location services are disabled in Settings.
	kMLLocationErrorLocationUnknown,    // location is currently unknown, but CL will keep trying
	kMLLocationErrorDenied, // Access to location or ranging has been denied by the user
	kMLLocationErrorNetwork,    // general, network-related error
	kMLLocationErrorRangingUnavailable, // Ranging cannot be performed
	kMLLocationErrorRangingFailure, // General ranging failure
	kMLLocationErrorTimeout, // Location service reached timeout
	kMLLocationErrorDefaultError,   // Default error
};

/** MLLocation notification callback name for success. Suscribe to nofifications with this name to handle location succes and get current location.
 */
extern NSString *const kMLLocationFoundNotificationName;
/** MLLocation notification callback name for failure. Suscribe to nofifications with this name to handle location errors and get information about the failure.
 */
extern NSString *const kMLLocationErrorNotificationName;

/** User info dictionary key to retrieve MLLocation object from location found notification
 */
extern NSString *const kMLLocationFoundUserInfoKey;
/** User info dictionary key to retrieve NSError object from location error notification
 */
extern NSString *const kMLLocationErrorUserInfoKey;

/** MLLocation notification callback name for Authorization status change to Authorized. Suscribe to nofifications with this name to handle authorization status change to authorize
 */
extern NSString *const kMLLocationChangeAuthorizationStatusAuthorized;

/** MLLocation notification callback name for Authorization status change to Not Authorized. Suscribe to nofifications with this name to handle authorization status change to not authorize
 */
extern NSString *const kMLLocationChangeAuthorizationStatusNotAuthorized;

@interface MLLocationManager : NSObject

- (id)init __attribute__((unavailable("Cannot use init for this class, use +(MLLocationManager*)sharedInstance instead")));

/** Returns the singleton instance of this class. */
+ (instancetype)sharedInstance;

/** Request location asynchronously.
 * @param forced location forced for greater precision and harder battery usage. Location not forced to reduce battery use an good location precision. When forced param is YES, if there is no wifi, this method will try to get location. When forced param is NO, if there is no wifi, an error will be returned.
 * This method has a default timeout of 1 second.
 * To obtain location (or errors retrieving it) suscribe NSNotification's default center with notification names kLocationFoundNotificationName for success and kLocationErrorNotificationName for failure
 * kLocationFoundNotificationName notification returns an instance of MLLocationCoordinate, with latitude, longitude and creation date.
 * kLocationErrorNotificationName notification returns an instance of NSError, with a MLLocationError.
 */
- (void)obtainLocation:(BOOL)forced;

/** This method does the same as obtaintLocation:(BOOL) forced, the only difference is the timeout param to set how much time the manager will wait until location service has finished.
 */
- (void)obtainLocation:(BOOL)forced withTimeout:(NSTimeInterval)timeout;

/** Request location synchronously.
 * Return MLLocationCoordinate saved from MLLocationUserDefaults. The location is retrieved if the user is connected to a saved WiFi (via BSSID) and location is not older than six months from today, nil if not.
 */
__deprecated_msg("Deprecated for iOS 13+, it will return nil on those versions");
- (nullable MLLocationCoordinate *)obtainSavedLocation;

/** Stop obtaining location
 */
- (void)stopObtainingLocation;

/*
 *  authorizationStatus
 *
 *  Discussion:
 *      Returns the current authorization status of the calling application.
 */
+ (CLAuthorizationStatus)authorizationStatus;

/*
 *  locationServicesEnabled
 *
 *  Discussion:
 *      Determines whether the user has location services enabled.
 *      If NO, and you proceed to call other MLLocation API, user will be prompted with the warning
 *      dialog. You may want to check this property and use location services only when explicitly requested by the user.
 */
+ (BOOL)locationServicesEnabled;

/*
 *  requestWhenInUseAuthorization
 *
 *  Discussion:
 *      When +authorizationStatus == kCLAuthorizationStatusNotDetermined,
 *      calling this method will trigger a prompt to request "when-in-use"
 *      authorization from the user.  If possible, perform this call in response
 *      to direct user request for a location-based service so that the reason
 *      for the prompt will be clear.  Any authorization change as a result of
 *      the prompt will be reflected via the usual delegate callback:
 *      -locationManager:didChangeAuthorizationStatus:.
 *
 *      If received, "when-in-use" authorization grants access to the user's
 *      location via -startUpdatingLocation/-startRangingBeaconsInRegion while
 *      in the foreground.  If updates have been started when going to the
 *      background, then a status bar banner will be displayed to maintain
 *      visibility to the user, and updates will continue until stopped
 *      normally, or the app is killed by the user.
 *
 *      "When-in-use" authorization does NOT enable monitoring API on regions,
 *      significant location changes, or visits, and -startUpdatingLocation will
 *      not succeed if invoked from the background.
 *
 *      When +authorizationStatus != kCLAuthorizationStatusNotDetermined, (ie
 *      generally after the first call) this method will do nothing.
 *
 *      If the NSLocationWhenInUseUsageDescription key is not specified in your
 *      Info.plist, this method will do nothing, as your app will be assumed not
 *      to support WhenInUse authorization.
 */
- (void)requestWhenInUseAuthorization;

@end
NS_ASSUME_NONNULL_END
