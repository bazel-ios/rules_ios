//
// MLCSiteManager.h
// MLCommons
//
// Created by ITAY BRENNER WERTHEIN on 14/6/18.
//

#import <Foundation/Foundation.h>
#import "MLCSiteDataSource.h"

NS_ASSUME_NONNULL_BEGIN

@interface MLCSiteManager : NSObject

+ (instancetype)sharedManager;

- (NSString *)siteId;

- (void)setDataSource:(id <MLCSiteDataSource>)dataSource;

@end

NS_ASSUME_NONNULL_END
