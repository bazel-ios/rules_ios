//
// MLNetworkingSessionManager.h
// MLNetworking
//
// Created by Fabian Celdeiro on 12/9/14.
// Copyright (c) 2014 MercadoLibre. All rights reserved.
//

#import <Foundation/Foundation.h>

@class MLNetworkingConfiguration;
@class MLNetworkingSessionManager;

@protocol MLNetworkingSessionManagerDelegate <NSObject>

/* Sent when data is available for the delegate to consume.  It is
 * assumed that the delegate will retain and not copy the data.  As
 * the data may be discontiguous, you should use
 * [NSData enumerateByteRangesUsingBlock:] to access it.
 */
- (void)mlNetworkingSessionManager:(MLNetworkingSessionManager *)manager
                          dataTask:(NSURLSessionDataTask *)dataTask
                    didReceiveData:(NSData *)data;

/* Sent as the last message related to a specific task.  Error may be
 * nil, which implies that no error occurred and this task is complete.
 */
- (void)mlNetworkingSessionManager:(MLNetworkingSessionManager *)sessionManager
                              task:(NSURLSessionTask *)task
              didCompleteWithError:(NSError *)error;

- (void)mlNetworkingSessionManager:(MLNetworkingSessionManager *)sessionManager
                          dataTask:(NSURLSessionDataTask *)dataTask
             didBecomeDownloadTask:(NSURLSessionDownloadTask *)downloadTask;

/* Sent when a download task that has completed a download.  The delegate should
 * copy or move the file at the given location to a new location as it will be
 * removed when the delegate message returns. URLSession:task:didCompleteWithError: will
 * still be called.
 */
- (void)mlNetworkingSessionManager:(MLNetworkingSessionManager *)sessionManager
                      downloadTask:(NSURLSessionDownloadTask *)downloadTask
         didFinishDownloadingToURL:(NSURL *)location;

@optional

/* Sent periodically to notify the delegate of upload progress.  This
 * information is also available as properties of the task.
 */
- (void)mlNetworkingSessionManager:(MLNetworkingSessionManager *)sessionManager
                              task:(NSURLSessionTask *)task
                   didSendBodyData:(int64_t)bytesSent
                    totalBytesSent:(int64_t)totalBytesSent
          totalBytesExpectedToSend:(int64_t)totalBytesExpectedToSend;

/* Sent periodically to notify the delegate of download progress. */
- (void)mlNetworkingSessionManager:(MLNetworkingSessionManager *)sessionManager
                      downloadTask:(NSURLSessionDownloadTask *)downloadTask
                      didWriteData:(int64_t)bytesWritten
                 totalBytesWritten:(int64_t)totalBytesWritten
         totalBytesExpectedToWrite:(int64_t)totalBytesExpectedToWrite;

/* Sent when a download has been resumed. If a download failed with an
 * error, the -userInfo dictionary of the error will contain an
 * NSURLSessionDownloadTaskResumeData key, whose value is the resume
 * data.
 */
- (void)mlNetworkingSessionManager:(MLNetworkingSessionManager *)sessionManager
                      downloadTask:(NSURLSessionDownloadTask *)downloadTask
                 didResumeAtOffset:(int64_t)fileOffset
                expectedTotalBytes:(int64_t)expectedTotalBytes;

@end

/**
 *  Class that is responsible for creating tasks and manage his callbacks.
 *
 */
@interface MLNetworkingSessionManager : NSObject

/**
 *  Returns the shared instance of MLRestClientManager.
 *
 */
+ (MLNetworkingSessionManager *)sharedInstance;

/**
 *  Creates an instance of NSURLSessionConfiguration for foreground session.
 *
 *  @return NSURLSessionConfiguration.
 */
- (NSURLSessionConfiguration *)foregroundSessionConfiguration;

/**
 *  Creates an instance of NSURLSessionConfiguration for background session.
 *
 *  @return NSURLSessionConfiguration.
 */
- (NSURLSessionConfiguration *)backgroundSessionConfiguration;

/**
 *  Create and config foreground NSURLSession with configuration.
 *
 *  @param configuration Session configuration
 */
- (void)configureForegroundSessionWithConfiguration:(NSURLSessionConfiguration *)configuration;

/**
 *  Create and config foreground up NSURLSession with configuration.
 *
 *  @param configuration Session configuration
 */
- (void)configureForegroundUpDownloadSessionWithConfiguration:(NSURLSessionConfiguration *)configuration;

/**
 *  Create and config background NSURLSession with configuration.
 *
 *  @param configuration Session configuration
 */
- (void)configureBackgroundSessionWithConfiguration:(NSURLSessionConfiguration *)configuration;

/**
 *  Creates a NSURLSessionDataTask in base a configuration and save a reference to delegate.
 *
 *  @param configuration Configuration used to create the data task.
 *  @param delegate      Object that will receive the events from the data task.
 *
 *  @return Instance of NSURLSessionDataTask.
 */
- (NSURLSessionDataTask *)dataTaskFromConfiguration:(MLNetworkingConfiguration *)configuration
                                       withDelegate:(id <MLNetworkingSessionManagerDelegate>)delegate
                                              error:(NSError *__autoreleasing *)error;

/**
 *  Creates a NSURLSessionDownloadTask in base a configuration and save a reference to delegate.
 *
 *  @param configuration Configuration used to create the task.
 *  @param delegate      Object that will receive the events from the task.
 *
 *  @return Instance of NSURLSessionDownloadTask.
 */
- (NSURLSessionDownloadTask *)downloadTaskFromConfiguration:(MLNetworkingConfiguration *)configuration
                                               withDelegate:(id <MLNetworkingSessionManagerDelegate>)delegate
                                                      error:(NSError *__autoreleasing *)error;

/**
 *  Creates a NSURLSessionUploadTask in base a configuration and save a reference to delegate.
 *
 *  @param configuration Configuration used to create the task.
 *  @param delegate      Object that will receive the events from the task.
 *
 *  @return Instance of NSURLSessionUploadTask.
 */
- (NSURLSessionUploadTask *)uploadTaskFromConfiguration:(MLNetworkingConfiguration *)configuration
                                           withDelegate:(id <MLNetworkingSessionManagerDelegate>)delegate
                                                  error:(NSError *__autoreleasing *)error;

/**
 *  Creates an instance of NSURLSessionTask (NSURLSessionDataTask, NSURLSessionDownloadTask or NSURLSessionUploadTask) based on configuration and keeps a reference to the delegate.
 *  The kind of session task depends on configuration's requestType (data, upload or download).
 *
 *  @param configuration Configuration used to create the task.
 *  @param delegate      Object that will receive the events from the task.
 *
 *  @return A concrete instance of NSURLSessionTask (NSURLSessionDataTask, NSURLSessionDownloadTask or NSURLSessionUploadTask)
 */
- (NSURLSessionTask *)taskFromConfiguration:(MLNetworkingConfiguration *)configuration
                               withDelegate:(id <MLNetworkingSessionManagerDelegate>)delegate
                                      error:(NSError *__autoreleasing *)error;

/**
 *  Adds headers for all requests.
 *
 *  @param genericHeaders Dictionary whose keys and values are the names and values of headers respectively.
 */
- (void)setGenericHeaders:(NSDictionary *)genericHeaders;

/**
 *  Adds an interceptors to the collections of request interceptors.
 *  Interceptors are invoked after the creation of NSURLRequest, they receive an mutable copy of it to set custom values, for example add a header.
 *  @param interceptor Code block that receives an NSMutableURLRequest as paramenter.
 */
- (void)addInterceptor:(void (^)(NSMutableURLRequest *request))interceptor;

/**
 *  Removes an interceptor from the collections of request interceptors.
 *
 *  @param interceptor Interceptor to be removed.
 */
- (void)removeInterceptor:(void (^)(NSMutableURLRequest *request))interceptor;

/**
 *  Removes all request interceptors.
 */
- (void)removeAllInterceptors;

@end
