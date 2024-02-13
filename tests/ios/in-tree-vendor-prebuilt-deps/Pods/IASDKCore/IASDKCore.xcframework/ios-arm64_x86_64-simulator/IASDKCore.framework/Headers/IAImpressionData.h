//
//  IAImpressionData.h
//  IASDKCore
//
//  Copyright © 2022 Digital Turbine. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <IASDKCore/IAInterfaceAllocBlocker.h>

/**
 *  @class The shown ad impression info.
 */
@interface IAImpressionData : NSObject<IAInterfaceAllocBlocker>

/**
 *  @brief The demand source name.
 */
@property (nonatomic, nullable, copy, readonly) NSString *demandSourceName;

/**
 *  @brief The ISO country code.
 */
@property (nonatomic, nullable, copy, readonly) NSString *country;

/**
 *  @brief The session ID.
 */
@property (nonatomic, nullable, copy, readonly) NSString *sessionID;

/**
 *  @brief The advertiser domain.
 */
@property (nonatomic, nullable, copy, readonly) NSString *advertiserDomain;

/**
 *  @brief The creative ID.
 */
@property (nonatomic, nullable, copy, readonly) NSString *creativeID;

/**
 *  @brief The campaign ID.
 */
@property (nonatomic, nullable, copy, readonly) NSString *campaignID;

/**
 *  @brief The pricing value.
 */
@property (nonatomic, nullable, copy, readonly) NSNumber *pricingValue;

/**
 *  @brief The pricing currency.
 */
@property (nonatomic, nullable, copy, readonly) NSString *pricingCurrency;

/**
 *  @brief Is ad duration (if applicable).
 */
@property (nonatomic, nullable, copy, readonly) NSNumber *duration;

/**
 *  @brief Is true in case of skippable ad.
 */
@property (nonatomic, readonly, getter=isSkippable) BOOL skippable;

- (NSString * _Nonnull)customDescription;

@end
