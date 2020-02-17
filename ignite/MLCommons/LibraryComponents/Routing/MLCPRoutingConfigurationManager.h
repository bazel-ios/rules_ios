//
// MLCPRoutingConfigurationManager.h
// MLCommons
//
// Created by LEANDRO FURYK on 31/1/19.
//

@protocol MLCPRoutingConfigurationManager

- (void)prepareViewController:(UIViewController *)viewController withURL:(NSURL *)url;

- (NSDictionary *)parseExtraParametersFromURL:(NSURL *)url;

- (void)viewControllerForURL:(NSURL *)targetUrl isPublic:(BOOL)isPublic;

- (void)validateViewController:(Class)viewController;

@end
