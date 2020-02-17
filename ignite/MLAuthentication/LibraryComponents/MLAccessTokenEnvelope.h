//
// MLAccessTokenEnvelope.h
// Bugsnag
//
// Created by FEDERICO VENTRE on 16/01/2019.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface MLAccessTokenEnvelope : NSObject

@property (nonatomic, copy) NSString *accessToken;
@property (nonatomic, copy) NSString *keychainId;
@property (nonatomic, copy) NSString *clientId;

- (BOOL)isAccessTokenEnvelopValid;

@end

NS_ASSUME_NONNULL_END
