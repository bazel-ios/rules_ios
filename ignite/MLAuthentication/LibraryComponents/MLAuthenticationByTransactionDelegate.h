//
// MLAuthenticationByTransactionDelegate.h
// Authentication
//
// Created by Cristian Perez Biancucci on 2/26/15.
// Copyright (c) 2015 MercadoLibre S.A. All rights reserved.
//

#import <Foundation/Foundation.h>

@class RBAWebViewController;

@protocol MLAuthenticationByTransactionDelegate <NSObject>

- (void)authenticationByTransactionWebViewDidFinish:(RBAWebViewController *)authenticationByTransactionWebView;

@end
