//
// MLAuthenticationNotificationsNames.h
// Pods
//
// Created by Federico Nazrala on 11/12/15.
//
//

#import <Foundation/Foundation.h>

@interface MLAuthenticationNotificationsNames : NSObject

/**
 *  Notification sent when the authentication finished successfully
 */
	OBJC_EXTERN NSString *const MLAuthenticationCreateSessionSuccessNotification;

/**
 * Key for MLSession in userInfo from MLAuthenticationCreateSessionSuccessNotification
 */
OBJC_EXTERN NSString *const MLAuthenticationCreateSessionSuccessNotificationObject;

@end
