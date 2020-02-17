//
// MLCURLAuthorizationManager.h
// Pods
//
// Created by ITAY BRENNER WERTHEIN on 2/15/17.
//
//

#import <Foundation/Foundation.h>

@protocol MLCURLAuthorizationDomainProvider;

NS_ASSUME_NONNULL_BEGIN

@interface MLCURLAuthorizationManager : NSObject

/**
 *  Configure this manager with a domain provider.
 *
 *  @param domainProvider is used to search all domains supported on the host app.
 */
+ (void)configure:(id <MLCURLAuthorizationDomainProvider>)domainProvider;

/**
 *  Check if the provided URL is approved by the config file
 *
 *  @return YES if the url was approved
 *  @param url URL to check
 */
+ (BOOL)isURLAuthorized:(NSURL *)url;

/**
 *  Check if the provided URL is approved by the config file
 *
 *  @return YES if the url was approved
 *  @param urlString URL as a string
 */
+ (BOOL)isURLStringAuthorized:(NSString *)urlString;

@end

NS_ASSUME_NONNULL_END
