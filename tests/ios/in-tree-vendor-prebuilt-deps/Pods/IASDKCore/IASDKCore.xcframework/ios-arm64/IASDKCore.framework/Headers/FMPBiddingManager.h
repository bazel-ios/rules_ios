//
//  FMPBiddingManager.h
//  IASDKCore
//
//  Created by Digital Turbine on 25/03/2021.
//  Copyright © 2022 Digital Turbine. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <IASDKCore/IAInterfaceSingleton.h>

@interface FMPBiddingManager : NSObject<IAInterfaceSingleton>

- (NSString * _Nullable)biddingToken;

@end
