//
// MLCSiteManager.m
// MLCommons
//
// Created by ITAY BRENNER WERTHEIN on 14/6/18.
//

#import "MLCSiteManager.h"

@interface MLCSiteManager ()
@property (nonatomic, strong) id <MLCSiteDataSource> dataSource;
@end

@implementation MLCSiteManager

+ (instancetype)sharedManager
{
	static id sharedManager;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		sharedManager = [[self alloc] init];
	});
	return sharedManager;
}

- (NSString *)siteId
{
	NSAssert(self.dataSource, @"DataSource not set");
	return [self.dataSource siteId];
}

@end
