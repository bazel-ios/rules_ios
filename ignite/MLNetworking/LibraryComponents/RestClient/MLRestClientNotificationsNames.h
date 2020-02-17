//
// MLRestClientNotificationsNames.h
// MLNetworking
//
// Created by Nicolas Andres Suarez on 20/5/15.
// Copyright (c) 2015 MercadoLibre. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 *  Notification sent when the user's session is removed.
 */
OBJC_EXTERN NSString *const MLRestClientDidUserLogoutNotification;

/**
 *  Key in the userInfo dictionary of an MLRestClientDidUserLogoutNotification,
 *  which value is the userId of the session removed.
 */
OBJC_EXTERN NSString *const MLRestClientUserIdParamNotification;

/**
 *  Notification sent when there isn't session and user needs authenticate.
 */
OBJC_EXTERN NSString *const MLRestClientNeedsLoginNotification;

/**
 *  Notification sent when login proccess ends.
 */
OBJC_EXTERN NSString *const MLRestClientLoginEndedNotification;

/**
 *  Notification sent when login proccess is canceled.
 */
OBJC_EXTERN NSString *const MLRestClientLoginCanceledNotification;
