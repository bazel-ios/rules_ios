//
// MLCommonRouter.m
// MLCommons
//
// Created by William Mora on 24/2/15.
// Copyright (c) 2015 MercadoLibre. All rights reserved.
//

#import "MLCommonRouter.h"
#import "MLCommonRouteHandler.h"

@interface MLCommonRouter ()

@property (strong, nonatomic) NSMutableDictionary *handlers;

@end

@implementation MLCommonRouter

+ (instancetype)router
{
	static MLCommonRouter *_router;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		_router = [[self alloc] initPrivate];
	});
	return _router;
}

- (instancetype)initPrivate
{
	return [super init];
}

- (void)registerHandler:(Class)handler forHost:(NSString *)host
{
	if (![handler isSubclassOfClass:[MLCommonRouteHandler class]]) {
		NSAssert(NO, ([NSString stringWithFormat:@"handler %@ must be subclass of MLCommonRouteHandler", handler]));
		return;
	}

	if (self.handlers == nil) {
		self.handlers = [[NSMutableDictionary alloc] init];
	}

	if ([self.handlers objectForKey:host] != nil) {
		NSAssert(NO, ([NSString stringWithFormat:@"host '%@' already registered", host]));
		return;
	}

	NSMutableDictionary *handlerInfo = [[NSMutableDictionary alloc] initWithDictionary:@{@"class" : handler, @"handler" : [NSNull null]}];

	[self.handlers setObject:handlerInfo forKey:host];
}

- (nullable __kindof UIViewController *)viewControllerForURL:(NSURL *)url isPublic:(BOOL)isPublic
{
    return [self viewControllerForURL:url isPublic:isPublic additionalInfo:nil];
}

- (MLCommonRouteHandler *)handlerForHandlerInfo:(NSMutableDictionary *)handlerInfo {
    MLCommonRouteHandler *handler;

    if (handlerInfo[@"handler"] != [NSNull null]) {
        handler = handlerInfo[@"handler"];
	} else {
        Class handlerCls = handlerInfo[@"class"];
        handler = [[handlerCls alloc] init];
        [handlerInfo setObject:handler forKey:@"handler"];
	}
    return handler;
}

- (nullable __kindof UIViewController *)viewControllerForURL:(NSURL *)url isPublic:(BOOL)isPublic additionalInfo:(id)additionalInfo
{
    NSMutableDictionary *handlerInfo = self.handlers[url.host];

    if (handlerInfo == nil) {
        return nil;
	}

    MLCommonRouteHandler *handler = [self handlerForHandlerInfo:handlerInfo];

    return [handler viewControllerForURL:url isPublic:isPublic additionalInfo:additionalInfo];
}

- (BOOL)existsViewControllerForURL:(NSURL *)url isPublic:(BOOL)isPublic {
    NSMutableDictionary *handlerInfo = self.handlers[url.host];

    if (handlerInfo == nil) {
        return NO;
	}

    MLCommonRouteHandler *handler = [self handlerForHandlerInfo:handlerInfo];

    return [handler existsViewControllerForURL:url isPublic:isPublic];
}

@end
