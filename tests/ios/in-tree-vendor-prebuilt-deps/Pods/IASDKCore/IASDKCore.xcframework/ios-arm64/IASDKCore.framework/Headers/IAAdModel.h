//
//  IAAdModel.h
//  IASDKCore
//
//  Created by Digital Turbine on 13/03/2017.
//  Copyright © 2022 Digital Turbine. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <IASDKCore/IAInterfaceContentModel.h>

@interface IAAdModel : NSObject <NSCopying>

@property (nonatomic, readonly, getter=isRewarded) BOOL rewarded;

/**
 *  @discussion Ad model is base; this member extends it to concrete type ad model.
 */
@property (nonatomic, strong, nullable, readonly) id<IAInterfaceContentModel> contentModel;

@end
