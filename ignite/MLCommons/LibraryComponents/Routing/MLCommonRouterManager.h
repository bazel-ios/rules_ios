//
// MLCommonRouterManager.h
// MLCommons
//
// Created by LEANDRO FURYK on 31/1/19.
//

#import <Foundation/Foundation.h>
#import "MLCPRoutingConfigurationManager.h"

@interface MLCommonRouterManager : NSObject

/**
 *  Configure this manager with a provider.
 *
 *  @param provider with the applications config
 */
+ (void)configure:(id <MLCPRoutingConfigurationManager>)provider;

+ (void)prepareViewController:(UIViewController *)viewController withURL:(NSURL *)url;

+ (NSDictionary *)parseExtraParametersFromURL:(NSURL *)url;

+ (void)viewControllerForURL:(NSURL *)targetUrl isPublic:(BOOL)isPublic;

+ (void)validateViewController:(Class)viewController;

@end
