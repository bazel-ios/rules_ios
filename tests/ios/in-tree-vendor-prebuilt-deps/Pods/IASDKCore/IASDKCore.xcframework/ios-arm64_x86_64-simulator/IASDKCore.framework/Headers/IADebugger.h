//
//  IADebugger.h
//  IASDKCore
//
//  Created by Digital Turbine on 15/03/2017.
//  Copyright © 2022 Digital Turbine. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <IASDKCore/IAInterfaceBuilder.h>

@protocol IADebuggerBuilder <NSObject>

@required

@property (nonatomic, copy, nullable) NSString *server;
@property (nonatomic, copy, nullable) NSString *database;
@property (nonatomic, copy, nullable) NSString *mockResponsePath;
@property (nonatomic, copy, nullable) NSString *localJSONResponsePath;

@property (class, nonatomic, copy, nullable) NSString *localJSONConfigPath;
@property (class, nonatomic, copy, nullable) NSString *globalConfigPath;
@property (class, nonatomic) BOOL adReportingEnabled;

@end

@interface IADebugger : NSObject <IAInterfaceBuilder, IADebuggerBuilder, NSCopying>

+ (instancetype _Nullable)build:(void(^ _Nonnull)(id<IADebuggerBuilder> _Nonnull builder))buildBlock;

@end
