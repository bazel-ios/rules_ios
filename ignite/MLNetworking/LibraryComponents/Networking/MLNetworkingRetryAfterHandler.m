//
// MLNetworkingRetryAfterHandler.m
// MLNetworking
//
// Created by Nicolas Andres Suarez on 8/25/17.
//
//

#import "MLNetworkingRetryAfterHandler.h"
#import "MLNetworkingRetryAfterResponse.h"

NSString *const MLRetryAfterHeader = @"Retry-After";

@interface MLNetworkingRetryAfterHandler ()

/**
 * Dictionary used to save the responses
 * Keys are the request's URL (domain + query params).
 * Values are the responses wrapped into an MLNetworkingRetryAfterResponse object.
 */
@property (nonatomic, strong) NSMutableDictionary <NSString *, MLNetworkingRetryAfterResponse *> *cachedResponses;

/**
 * Queue used to synchronize the access to cachedResponses dictionary
 */
@property (nonatomic, strong) dispatch_queue_t cacheQueue;

/**
 * Override access atributes: readwrite
 */
@property (nonatomic, assign, readwrite) NSUInteger cacheSize;

@end

@implementation MLNetworkingRetryAfterHandler

+ (MLNetworkingRetryAfterHandler *)sharedInstance
{
	static MLNetworkingRetryAfterHandler *shared;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		shared = [[MLNetworkingRetryAfterHandler alloc] init];
	});
	return shared;
}

- (void)dealloc
{
	[[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (id)init
{
	if (self = [super init]) {
		self.cachedResponses = [[NSMutableDictionary alloc] init];
		self.cacheQueue = dispatch_queue_create("com.mercadolibre.networking.retryAfter", DISPATCH_QUEUE_CONCURRENT);

		[[NSNotificationCenter defaultCenter] addObserver:self
		                                         selector:@selector(didReceiveMemoryWarningNotification:)
		                                             name:UIApplicationDidReceiveMemoryWarningNotification
		                                           object:nil];
	}
	return self;
}

- (NSString *)cacheKeyForRequest:(NSURLRequest *)request
{
	return request.URL.absoluteString;
}

- (NSTimeInterval)retryAfterHeaderFromResponse:(MLNetworkingOperationResponse *)response
{
	NSString *rawSeconds = nil;
	for (NSString *key in response.headers.allKeys) {
		if ([key compare:MLRetryAfterHeader options:NSCaseInsensitiveSearch] == NSOrderedSame) {
			rawSeconds = response.headers[key];
			break;
		}
	}
	if (rawSeconds == nil || [rawSeconds isEqual:[NSNull null]]) {
		return 0;
	}
	return [rawSeconds doubleValue];
}

- (BOOL)isExpectedHTTPMethod:(NSString *)httpMethod
{
	return [httpMethod isEqualToString:@"GET"];
}

- (BOOL)isExpectedStatusCode:(NSInteger)statusCode
{
	return statusCode == MLRetryAfterStatusCodeTooManyRequest ||
	       statusCode == MLRetryAfterStatusCodeServiceUnavailable;
}

- (BOOL)shouldSaveResponse:(MLNetworkingOperationResponse *)response forRequest:(NSURLRequest *)request
{
	if (![self isExpectedHTTPMethod:request.HTTPMethod]) {
		return NO;
	}

	if (![self isExpectedStatusCode:response.statusCode]) {
		return NO;
	}

	if ([self retryAfterHeaderFromResponse:response] <= 0) {
		return NO;
	}

	return YES;
}

- (void)saveResponse:(MLNetworkingOperationResponse *)response forRequest:(NSURLRequest *)request
{
	if (![self shouldSaveResponse:response forRequest:request]) {
		return;
	}

	NSTimeInterval expireSeconds = [self retryAfterHeaderFromResponse:response];
	MLNetworkingRetryAfterResponse *cachedResponse = [[MLNetworkingRetryAfterResponse alloc] initWithResponse:response
	                                                                                        retryAfterSeconds:expireSeconds];
	NSString *key = [self cacheKeyForRequest:request];
	if (key == nil || key.length == 0) {
		NSAssert(NO, @"Key for request should not be nil nor empty");
		return;
	}

	dispatch_barrier_async(self.cacheQueue, ^{
		self.cachedResponses[key] = cachedResponse;
		self.cacheSize += cachedResponse.byteCount;
	});

	[self trimCache];
}

- (MLNetworkingOperationResponse *)cachedResponseForRequest:(NSURLRequest *)request
{
	NSString *key = [self cacheKeyForRequest:request];
	__block MLNetworkingRetryAfterResponse *cachedResponse = nil;
	dispatch_sync(self.cacheQueue, ^{
		cachedResponse = self.cachedResponses[key];
	});

	if (cachedResponse == nil) {
		return nil;
	}

	if ([cachedResponse isExpired]) {
		dispatch_barrier_async(self.cacheQueue, ^{
			[self.cachedResponses removeObjectForKey:key];
			self.cacheSize -= cachedResponse.byteCount;
		});
		return nil;
	}

	return cachedResponse.response;
}

- (void)trimCache
{
	if (self.cacheSizeLimit == 0) {
		return;
	}

	dispatch_barrier_async(self.cacheQueue, ^{
		if (self.cacheSize <= self.cacheSizeLimit) {
		    return;
		}

		// Remove first those that are about to expire
		NSArray <NSString *> *keys = [self.cachedResponses keysSortedByValueUsingSelector:@selector(compareByExpireTime:)];
		for (NSString *key in keys) {
		    MLNetworkingRetryAfterResponse *cachedResponse = self.cachedResponses[key];
		    self.cacheSize -= cachedResponse.byteCount;
		    [self.cachedResponses removeObjectForKey:key];

		    if (self.cacheSize <= self.cacheSizeLimit) {
		        break;
			}
		}
	});
}

- (void)clearCache
{
	dispatch_barrier_async(self.cacheQueue, ^{
		[self.cachedResponses removeAllObjects];
		self.cacheSize = 0;
	});
}

- (void)didReceiveMemoryWarningNotification:(__unused NSNotification *)notification
{
	[self clearCache];
}

@end
