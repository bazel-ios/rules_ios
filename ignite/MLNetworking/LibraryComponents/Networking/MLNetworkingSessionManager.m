//
// MLNetworkingSessionManager.m
// MLNetworking
//
// Created by Fabian Celdeiro on 12/9/14.
// Copyright (c) 2014 MercadoLibre. All rights reserved.
//

#import "MLNetworkingSessionManager.h"
#import "MLNetworkingConfiguration.h"

#define kMLNetworkingSessionDelegateMapDefaultSize 5u

@interface MLNetworkingSessionManager () <NSURLSessionDelegate, NSURLSessionTaskDelegate, NSURLSessionDataDelegate, NSURLSessionDownloadDelegate>

@property (nonatomic, strong) NSURLSession *foregroundDataSession;
@property (nonatomic, strong) NSURLSession *foregroundUpDownloadSession;
@property (nonatomic, strong) NSURLSession *backgroundSession;
@property (nonatomic, strong) NSMapTable <NSString *, id <MLNetworkingSessionManagerDelegate> > *sessionDelegates;
@property (nonatomic, strong) dispatch_queue_t delegateQueue;
@property (nonatomic, strong) dispatch_queue_t interceptorsQueue;
@property (nonatomic, strong) NSMutableArray *requestInterceptors;

@end

@implementation MLNetworkingSessionManager

+ (MLNetworkingSessionManager *)sharedInstance
{
	static MLNetworkingSessionManager *shared;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		shared = [[MLNetworkingSessionManager alloc] init];
	});
	return shared;
}

- (id)init
{
	if (self = [super init]) {
		self.delegateQueue = dispatch_queue_create("com.mercadolibre.networking.sessionManager.delegateQueue", DISPATCH_QUEUE_CONCURRENT);
		self.interceptorsQueue = dispatch_queue_create("com.mercadolibre.networking.sessionManager.interceptorQueue", DISPATCH_QUEUE_CONCURRENT);

		// Creation of foreground sessions
		[self configureForegroundSessionWithConfiguration:[self foregroundSessionConfiguration]];
		[self configureForegroundUpDownloadSessionWithConfiguration:[self foregroundSessionConfiguration]];
		[self configureBackgroundSessionWithConfiguration:[self backgroundSessionConfiguration]];

		self.sessionDelegates = [[NSMapTable alloc] initWithKeyOptions:NSMapTableCopyIn
		                                                  valueOptions:NSMapTableWeakMemory
		                                                      capacity:kMLNetworkingSessionDelegateMapDefaultSize];

		self.requestInterceptors = [NSMutableArray array];
	}
	return self;
}

- (NSURLSessionConfiguration *)foregroundSessionConfiguration
{
	NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
	configuration.HTTPMaximumConnectionsPerHost = kMLNetworkingSessionDelegateMapDefaultSize;
	return configuration;
}

- (NSURLSessionConfiguration *)backgroundSessionConfiguration
{
	NSURLSessionConfiguration *configuration;
	NSString *configIdentifier = [[NSUUID UUID] UUIDString];
	if ([[NSURLSessionConfiguration class] respondsToSelector:@selector(backgroundSessionConfigurationWithIdentifier:)]) {
		configuration = [NSURLSessionConfiguration backgroundSessionConfigurationWithIdentifier:configIdentifier];
	} else {
		configuration = [NSURLSessionConfiguration backgroundSessionConfiguration:configIdentifier];
	}
	configuration.HTTPMaximumConnectionsPerHost = kMLNetworkingSessionDelegateMapDefaultSize;
	return configuration;
}

- (void)configureForegroundSessionWithConfiguration:(NSURLSessionConfiguration *)configuration
{
	self.foregroundDataSession = [NSURLSession sessionWithConfiguration:configuration
	                                                           delegate:self
	                                                      delegateQueue:[[NSOperationQueue alloc] init]];
}

- (void)configureForegroundUpDownloadSessionWithConfiguration:(NSURLSessionConfiguration *)configuration
{
	self.foregroundUpDownloadSession = [NSURLSession sessionWithConfiguration:configuration
	                                                                 delegate:self
	                                                            delegateQueue:[[NSOperationQueue alloc] init]];
}

- (void)configureBackgroundSessionWithConfiguration:(NSURLSessionConfiguration *)configuration
{
	self.backgroundSession = [NSURLSession sessionWithConfiguration:configuration
	                                                       delegate:self
	                                                  delegateQueue:[[NSOperationQueue alloc] init]];
}

- (void)setGenericHeaders:(NSDictionary *)genericHeader
{
	[self.foregroundDataSession configuration].HTTPAdditionalHeaders = genericHeader;
	[self.foregroundUpDownloadSession configuration].HTTPAdditionalHeaders = genericHeader;
	[self.backgroundSession configuration].HTTPAdditionalHeaders = genericHeader;
}

- (NSURLSession *)sessionForConfiguration:(MLNetworkingConfiguration *)configuration
{
	switch (configuration.sessionType) {
		case MLNetworkingSessionTypeForeground: {
			if (configuration.requestType == MLNetworkingRequestTypeData) {
				return self.foregroundDataSession;
			} else {
				return self.foregroundUpDownloadSession;
			}
		}

		case MLNetworkingSessionTypeBackground: {
			return self.backgroundSession;
		}

		default: {
			return self.foregroundDataSession;
		}
	}
}

- (NSString *)identifierForSession:(NSURLSession *)session
                              task:(NSURLSessionTask *)task
{
	return [NSString stringWithFormat:@"%p-%lu", session, (unsigned long)task.taskIdentifier];
}

- (id <MLNetworkingSessionManagerDelegate>)delegateForSession:(NSURLSession *)session
                                                         task:(NSURLSessionTask *)task
{
	NSString *identifier = [self identifierForSession:session
	                                             task:task];
	return [self delegateForIdentifier:identifier];
}

- (id <MLNetworkingSessionManagerDelegate>)delegateForIdentifier:(nonnull NSString *)identifier
{
	__block id <MLNetworkingSessionManagerDelegate> delegate = nil;
	__weak typeof(self) weakSelf = self;

	dispatch_sync(self.delegateQueue, ^() {
		delegate = [weakSelf.sessionDelegates objectForKey:identifier];
	});

	return delegate;
}

// We need to create the session task  and set the delegate atomically, to avoid the task start before delegate was set.
- (void)setDelegate:(id <MLNetworkingSessionManagerDelegate>)delegate
     withKeyBuilder:(NSString * (^)(void))builder
{
	if (!delegate) {
		return;
	}

	__weak typeof(self) weakSelf = self;

	dispatch_barrier_sync(self.delegateQueue, ^{
		NSString *identifier = builder();
		[weakSelf.sessionDelegates setObject:delegate forKey:identifier];
	});
}

- (void)removeDelegateWithIdentifier:(NSString *)identifier
{
	__weak typeof(self) weakSelf = self;

	dispatch_barrier_sync(self.delegateQueue, ^{
		[weakSelf.sessionDelegates removeObjectForKey:identifier];
	});
}

- (NSURLSessionDataTask *)dataTaskFromConfiguration:(MLNetworkingConfiguration *)configuration
                                       withDelegate:(id <MLNetworkingSessionManagerDelegate>)delegate
                                              error:(NSError *__autoreleasing *)error
{
	NSURLSession *sessionToUse = [self sessionForConfiguration:configuration];
	NSURLRequest *urlRequest = [self requestFromConfiguration:configuration error:error];
	__weak typeof(self) weakSelf = self;

	__block NSURLSessionDataTask *task = nil;
	[self setDelegate:delegate withKeyBuilder: ^NSString * {
	    typeof(weakSelf) strongSelf = weakSelf;
	    task = [sessionToUse dataTaskWithRequest:urlRequest];
	    return [strongSelf identifierForSession:sessionToUse task:task];
	}];

	return task;
}

- (NSURLSessionDownloadTask *)downloadTaskFromConfiguration:(MLNetworkingConfiguration *)configuration
                                               withDelegate:(id <MLNetworkingSessionManagerDelegate>)delegate
                                                      error:(NSError *__autoreleasing *)error
{
	NSURLSession *sessionToUse = [self sessionForConfiguration:configuration];

	__block NSURLSessionDownloadTask *task = nil;
	__weak typeof(self) weakSelf = self;

	[self setDelegate:delegate withKeyBuilder: ^NSString * {
	    typeof(weakSelf) strongSelf = weakSelf;
	    if (configuration.resumeData) {
	        task = [sessionToUse downloadTaskWithResumeData:configuration.resumeData];
		} else {
	        task = [sessionToUse downloadTaskWithRequest:[strongSelf requestFromConfiguration:configuration error:error]];
		}
	    return [strongSelf identifierForSession:sessionToUse task:task];
	}];

	return task;
}

- (NSURLSessionUploadTask *)uploadTaskFromConfiguration:(MLNetworkingConfiguration *)configuration
                                           withDelegate:(id <MLNetworkingSessionManagerDelegate>)delegate
                                                  error:(NSError *__autoreleasing *)error
{
	__block NSURLSessionUploadTask *task = nil;
	__weak typeof(self) weakSelf = self;

	NSURLSession *sessionToUse = [self sessionForConfiguration:configuration];
	NSURLRequest *request = [self requestFromConfiguration:configuration error:error];

	if (!(*error)) {
		[self setDelegate:delegate withKeyBuilder: ^NSString * {
		    typeof(weakSelf) strongSelf = weakSelf;
		    if (configuration.uploadData) {
		        task = [sessionToUse uploadTaskWithRequest:request
		                                          fromData:configuration.uploadData];
			} else if (configuration.uploadURL) {
		        task = [sessionToUse uploadTaskWithRequest:request
		                                          fromFile:configuration.uploadURL];
			} else if (request.HTTPBodyStream) {
		        task = [sessionToUse uploadTaskWithStreamedRequest:request];
			}
		    return [strongSelf identifierForSession:sessionToUse task:task];
		}];
	}

	return task;
}

- (NSURLSessionTask *)taskFromConfiguration:(MLNetworkingConfiguration *)configuration
                               withDelegate:(id <MLNetworkingSessionManagerDelegate>)delegate
                                      error:(NSError *__autoreleasing *)error
{
	NSURLSessionTask *taskToReturn = nil;

	switch (configuration.requestType) {
		case MLNetworkingRequestTypeData:
		default: {
			taskToReturn = [self dataTaskFromConfiguration:configuration
			                                  withDelegate:delegate
			                                         error:error];
			break;
		}

		case MLNetworkingRequestTypeDownload: {
			taskToReturn = [self downloadTaskFromConfiguration:configuration
			                                      withDelegate:delegate
			                                             error:error];
			break;
		}

		case MLNetworkingRequestTypeUpload: {
			taskToReturn = [self uploadTaskFromConfiguration:configuration
			                                    withDelegate:delegate
			                                           error:error];
			break;
		}
	}

	return taskToReturn;
}

- (NSURLRequest *)requestFromConfiguration:(MLNetworkingConfiguration *)configuration error:(NSError *__autoreleasing *)outError
{
	NSError *error = nil;
	__block NSURLRequest *request = [configuration createRequestWithtError:&error];

	if (request && !error) {
		dispatch_sync(self.interceptorsQueue, ^{
			if (self.requestInterceptors.count > 0) {
			    NSMutableURLRequest *mutableRequest = [request mutableCopy];
			    for (void (^interceptor)(NSMutableURLRequest *request) in self.requestInterceptors) {
			        interceptor(mutableRequest);
				}
			    request = mutableRequest;
			}
		});
	}

	if (error && outError) {
		*outError = error;
	}

	return request;
}

- (void)addInterceptor:(void (^)(NSMutableURLRequest *request))interceptor
{
	dispatch_barrier_async(self.interceptorsQueue, ^{
		[self.requestInterceptors addObject:interceptor];
	});
}

- (void)removeInterceptor:(void (^)(NSMutableURLRequest *request))interceptor
{
	dispatch_barrier_async(self.interceptorsQueue, ^{
		[self.requestInterceptors removeObject:interceptor];
	});
}

- (void)removeAllInterceptors
{
	dispatch_barrier_async(self.interceptorsQueue, ^{
		[self.requestInterceptors removeAllObjects];
	});
}

/*
 * Messages related to the URL session as a whole
 */
#pragma mark - NSURLSessionDelegate

/* The last message a session receives.  A session will only become
 * invalid because of a systemic error or when it has been
 * explicitly invalidated, in which case the error parameter will be nil.
 */
- (void)URLSession:(NSURLSession *)session didBecomeInvalidWithError:(NSError *)error
{
}

- (void)   URLSession:(NSURLSession *)session
                 task:(NSURLSessionTask *)task
    needNewBodyStream:(void (^)(NSInputStream *bodyStream))completionHandler
{
	NSInputStream *inputStream = nil;

	if (task.originalRequest.HTTPBodyStream && [task.originalRequest.HTTPBodyStream conformsToProtocol:@protocol(NSCopying)]) {
		inputStream = [task.originalRequest.HTTPBodyStream copy];
	}

	if (completionHandler) {
		completionHandler(inputStream);
	}
}

/*
 * Messages related to the operation of a specific task.
 */
#pragma mark - NSURLSessionTaskDelegate

/* Sent periodically to notify the delegate of upload progress.  This
 * information is also available as properties of the task.
 */
- (void)          URLSession:(NSURLSession *)session
                        task:(NSURLSessionTask *)task
             didSendBodyData:(int64_t)bytesSent
              totalBytesSent:(int64_t)totalBytesSent
    totalBytesExpectedToSend:(int64_t)totalBytesExpectedToSend
{
	id <MLNetworkingSessionManagerDelegate> delegate = [self delegateForSession:session task:task];

	SEL selectorToUse = @selector(mlNetworkingSessionManager:task:didSendBodyData:totalBytesSent:totalBytesExpectedToSend:);
	if ([delegate respondsToSelector:selectorToUse]) {
		[delegate mlNetworkingSessionManager:self task:task didSendBodyData:bytesSent totalBytesSent:totalBytesSent totalBytesExpectedToSend:totalBytesExpectedToSend];
	}
}

/* Sent as the last message related to a specific task.  Error may be
 * nil, which implies that no error occurred and this task is complete.
 */
- (void)      URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task
    didCompleteWithError:(NSError *)error
{
	id <MLNetworkingSessionManagerDelegate> delegate = [self delegateForSession:session task:task];

	SEL selectorToUse = @selector(mlNetworkingSessionManager:task:didCompleteWithError:);

	if ([delegate respondsToSelector:selectorToUse]) {
		[delegate mlNetworkingSessionManager:self task:task didCompleteWithError:error];
	}
}

/*
 * Messages related to the operation of a task that delivers data
 * directly to the delegate.
 */
#pragma mark - NSURLSessionDataDelegate

/* Sent when data is available for the delegate to consume.  It is
 * assumed that the delegate will retain and not copy the data.  As
 * the data may be discontiguous, you should use
 * [NSData enumerateByteRangesUsingBlock:] to access it.
 */
- (void)URLSession:(NSURLSession *)session
          dataTask:(NSURLSessionDataTask *)dataTask
    didReceiveData:(NSData *)data
{
	id <MLNetworkingSessionManagerDelegate> delegate = [self delegateForSession:session task:dataTask];

	SEL selectorToUse = @selector(mlNetworkingSessionManager:dataTask:didReceiveData:);
	if ([delegate respondsToSelector:selectorToUse]) {
		[delegate mlNetworkingSessionManager:self dataTask:dataTask didReceiveData:data];
	}
}

/* Notification that a data task has become a download task.  No
 * future messages will be sent to the data task.
 */
- (void)       URLSession:(NSURLSession *)session
                 dataTask:(NSURLSessionDataTask *)dataTask
    didBecomeDownloadTask:(NSURLSessionDownloadTask *)downloadTask
{
	NSString *taskIdentifier = [self identifierForSession:session task:dataTask];

	id <MLNetworkingSessionManagerDelegate> delegate = [self delegateForIdentifier:taskIdentifier];

	[self removeDelegateWithIdentifier:taskIdentifier];
	__weak typeof(self) weakSelf = self;

	// Cambio el delegate en el dictionary ya que cambia el task
	if (delegate) {
		[self setDelegate:delegate withKeyBuilder: ^NSString * {
		    return [weakSelf identifierForSession:session task:downloadTask];
		}];

		SEL selectorToUse = @selector(mlNetworkingSessionManager:dataTask:didBecomeDownloadTask:);
		if ([delegate respondsToSelector:selectorToUse]) {
			[delegate mlNetworkingSessionManager:self dataTask:dataTask didBecomeDownloadTask:downloadTask];
		}
	}
}

/*
 * Messages related to the operation of a task that writes data to a
 * file and notifies the delegate upon completion.
 */
#pragma mark - NSURLSessionDownloadDelegate

/* Sent when a download task that has completed a download.  The delegate should
 * copy or move the file at the given location to a new location as it will be
 * removed when the delegate message returns. URLSession:task:didCompleteWithError: will
 * still be called.
 */
- (void)           URLSession:(NSURLSession *)session
                 downloadTask:(NSURLSessionDownloadTask *)downloadTask
    didFinishDownloadingToURL:(NSURL *)location
{
	id <MLNetworkingSessionManagerDelegate> delegate = [self delegateForSession:session task:downloadTask];

	SEL selectorToUse = @selector(mlNetworkingSessionManager:downloadTask:didFinishDownloadingToURL:);
	if ([delegate respondsToSelector:selectorToUse]) {
		[delegate mlNetworkingSessionManager:self downloadTask:downloadTask didFinishDownloadingToURL:location];
	}
}

/* Sent periodically to notify the delegate of download progress. */
- (void)           URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask
                 didWriteData:(int64_t)bytesWritten
            totalBytesWritten:(int64_t)totalBytesWritten
    totalBytesExpectedToWrite:(int64_t)totalBytesExpectedToWrite
{
	id <MLNetworkingSessionManagerDelegate> delegate = [self delegateForSession:session task:downloadTask];

	SEL selectorToUse = @selector(mlNetworkingSessionManager:downloadTask:didWriteData:totalBytesWritten:totalBytesExpectedToWrite:);
	if ([delegate respondsToSelector:selectorToUse]) {
		[delegate mlNetworkingSessionManager:self downloadTask:downloadTask didWriteData:bytesWritten totalBytesWritten:totalBytesWritten totalBytesExpectedToWrite:totalBytesExpectedToWrite];
	}
}

/* Sent when a download has been resumed. If a download failed with an
 * error, the -userInfo dictionary of the error will contain an
 * NSURLSessionDownloadTaskResumeData key, whose value is the resume
 * data.
 */
- (void)    URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask
     didResumeAtOffset:(int64_t)fileOffset
    expectedTotalBytes:(int64_t)expectedTotalBytes
{
	id <MLNetworkingSessionManagerDelegate> delegate = [self delegateForSession:session task:downloadTask];

	SEL selectorToUse = @selector(mlNetworkingSessionManager:downloadTask:didResumeAtOffset:expectedTotalBytes:);
	if ([delegate respondsToSelector:selectorToUse]) {
		[delegate mlNetworkingSessionManager:self downloadTask:downloadTask didResumeAtOffset:fileOffset expectedTotalBytes:expectedTotalBytes];
	}
}

@end
