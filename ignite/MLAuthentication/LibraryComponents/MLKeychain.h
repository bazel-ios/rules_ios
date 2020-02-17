//
// MLKeychain.h
// KeyChain
//
// Created by KH1386 on 3/10/14.
// Copyright (c) 2014 KH1386. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MLKeychain : NSObject
{
	NSString *service;
	NSString *group;
}
- (id)initWithService:(NSString *)service_ withGroup:(NSString *)group_;

- (BOOL)insert:(NSString *)key data:(NSData *)data;
- (BOOL)update:(NSString *)key data:(NSData *)data;
- (BOOL)remove:(NSString *)key;
- (NSData *)find:(NSString *)key;
@end
