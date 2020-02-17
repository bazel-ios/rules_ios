//
// MLSession.h
// Authentication
//
// Created by Christian Perez Biancucci on 2/10/15.
// Copyright (c) 2015 MercadoLibre S.A. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MLSession : NSObject

@property (nonatomic, strong) NSString *userId;
@property (nonatomic, strong) NSString *nickname;
@property (nonatomic, strong) NSString *siteId;
@property (nonatomic, strong) NSString *deviceProfileId;
@property (nonatomic, strong) NSString *accessToken;
@property (atomic, strong) NSDate *lastDayActive;
@property (nonatomic, strong) NSString *firstName;
@property (nonatomic, strong) NSString *lastName;
@property (nonatomic, strong) NSString *email;
@property (nonatomic, strong) NSArray *scopes;
@property (nonatomic, strong) NSArray *accessTokenEnvelopes;

- (BOOL)isSessionValid;
- (BOOL)isAccessTokenEnvelopesValid;

@end
