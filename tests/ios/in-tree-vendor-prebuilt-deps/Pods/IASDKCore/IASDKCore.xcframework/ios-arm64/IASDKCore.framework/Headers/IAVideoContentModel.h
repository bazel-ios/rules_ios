//
//  IAVideoContentModel.h
//  IASDKCore
//
//  Created by Digital Turbine on 12/04/2017.
//  Copyright © 2022 Digital Turbine. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <IASDKCore/IAInterfaceBuilder.h>
#import <IASDKCore/IAInterfaceContentModel.h>

typedef enum : NSInteger {
    IAVideoTypeUndefined = 0,
    IAVideoTypeInterstitial,
    IAVideoTypeRewarded,
} IAVideoType;

@class IAVASTModel;

@interface IAVideoContentModel : NSObject <IAInterfaceContentModel>

@property (nonatomic) IAVideoType videoType;
@property (nonatomic, strong, nonnull) IAVASTModel *VASTModel;
@property (nonatomic) NSTimeInterval skipSeconds;

@end
