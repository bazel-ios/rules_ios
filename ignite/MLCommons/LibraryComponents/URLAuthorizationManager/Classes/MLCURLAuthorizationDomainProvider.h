//
// MLCURLAuthorizationProvider.h
// MLCommonsUnitTests
//
// Created by amargalef on 11/7/18.
// Copyright © 2018 MercadoLibre. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@protocol MLCURLAuthorizationDomainProvider <NSObject>

- (NSArray <NSString *> *)domains;

@end

NS_ASSUME_NONNULL_END
