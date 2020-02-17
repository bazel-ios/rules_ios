//
// MLNetworkingConfigurationUploadMultipart.m
// MLNetworking
//
// Created by Nicolas Andres Suarez on 1/3/16.
// Copyright © 2016 MercadoLibre. All rights reserved.
//

#import "MLNetworkingConfigurationUploadMultipart.h"
#import "MLNetworkingMultipartBodyStream.h"
#import "MLNetworkingBodyPart.h"
#import "MLNetworkingOperationError.h"

static const NSUInteger kMLNBufferSize = 1024;

@interface MLNetworkingConfigurationUploadMultipart ()

@property (nonatomic, strong) MLNetworkingMultipartBodyStream *HTTPMultipartBodyStream;
@property (nonatomic, strong) NSURL *tempFileURL;
@end

@implementation MLNetworkingConfigurationUploadMultipart

@synthesize httpMethod = _httpMethod;

- (instancetype)init
{
	self = [super init];
	if (self) {
		self.requestType = MLNetworkingRequestTypeUpload;
		self.HTTPMultipartBodyStream = [[MLNetworkingMultipartBodyStream alloc] init];
		self.httpMethod = MLNetworkingHTTPMethodPOST;
	}
	return self;
}

- (void)dealloc
{
	if (self.tempFileURL) {
		[[NSFileManager defaultManager] removeItemAtURL:self.tempFileURL error:nil];
	}
}

- (void)addPartWithStream:(NSInputStream *)inputStream
                   length:(int64_t)length
                     name:(NSString *)name
                 fileName:(NSString *)fileName
                 mimeType:(NSString *)mimeType
{
	NSParameterAssert(inputStream);
	NSParameterAssert(name);
	NSParameterAssert(fileName);
	NSParameterAssert(mimeType);
	NSParameterAssert(length > 0);

	MLNetworkingBodyPart *bodyPart = [[MLNetworkingBodyPart alloc] initWithStream:inputStream
	                                                                       length:length
	                                                                         name:name
	                                                                     fileName:fileName
	                                                                     mimeType:mimeType];
	[self.HTTPMultipartBodyStream addBodyPart:bodyPart];
}

- (BOOL)addPartWithFileURL:(NSURL *)fileUrl
                      name:(NSString *)name
                  fileName:(NSString *)fileName
                  mimeType:(NSString *)mimeType
                     error:(NSError *__autoreleasing *)error
{
	NSParameterAssert(fileUrl);
	NSParameterAssert(name);
	NSParameterAssert(fileName);
	NSParameterAssert(mimeType);

	if (![fileUrl isFileURL]) {
		if (error) {
			NSDictionary *userInfo = @{NSLocalizedFailureReasonErrorKey : NSLocalizedString(@"Expected URL to be a file URL", nil)};
			*error = [[NSError alloc] initWithDomain:MLNetworkingOperationErrorDomain code:NSURLErrorBadURL userInfo:userInfo];
		}
		return NO;
	} else if (![fileUrl checkResourceIsReachableAndReturnError:error]) {
		NSDictionary *userInfo = @{NSLocalizedFailureReasonErrorKey : NSLocalizedString(@"File URL not reachable.", nil)};
		if (error) {
			*error = [[NSError alloc] initWithDomain:MLNetworkingOperationErrorDomain code:NSURLErrorBadURL userInfo:userInfo];
		}
		return NO;
	}

	MLNetworkingBodyPart *bodyPart = [[MLNetworkingBodyPart alloc] initWithFileURL:fileUrl
	                                                                          name:name
	                                                                      fileName:fileName
	                                                                      mimeType:mimeType];
	[self.HTTPMultipartBodyStream addBodyPart:bodyPart];
	return YES;
}

- (void)addPartWithFileData:(NSData *)fileData
                       name:(NSString *)name
                   fileName:(NSString *)fileName
                   mimeType:(NSString *)mimeType
{
	NSParameterAssert(fileData);
	NSParameterAssert(name);
	NSParameterAssert(fileName);
	NSParameterAssert(mimeType);

	MLNetworkingBodyPart *bodyPart = [[MLNetworkingBodyPart alloc] initWithFileData:fileData
	                                                                           name:name
	                                                                       fileName:fileName
	                                                                       mimeType:mimeType];
	[self.HTTPMultipartBodyStream addBodyPart:bodyPart];
}

- (void)addPartWithFormData:(NSData *)data
                       name:(NSString *)name
{
	NSParameterAssert(data);
	NSParameterAssert(name);

	MLNetworkingBodyPart *bodyPart = [[MLNetworkingBodyPart alloc] initWithData:data
	                                                                       name:name];
	[self.HTTPMultipartBodyStream addBodyPart:bodyPart];
}

#pragma mark - MLNetworkingConfiguration

- (void)setHttpMethod:(MLNetworkingHTTPMethod)httpMethod
{
	NSParameterAssert(httpMethod == MLNetworkingHTTPMethodPOST || httpMethod == MLNetworkingHTTPMethodPUT || httpMethod == MLNetworkingHTTPMethodPATCH);
	if (httpMethod == MLNetworkingHTTPMethodPOST || httpMethod == MLNetworkingHTTPMethodPUT || httpMethod == MLNetworkingHTTPMethodPATCH) {
		_httpMethod = httpMethod;
	}
}

- (NSMutableURLRequest *)createRequestWithtError:(NSError *__autoreleasing *)outError
{
	NSError *error = nil;
	NSMutableURLRequest *request = [super createRequestWithtError:&error];

	if (request && !error) {
		[request setValue:[NSString stringWithFormat:@"multipart/form-data; boundary=%@", self.HTTPMultipartBodyStream.boundary] forHTTPHeaderField:@"Content-Type"];

		if (self.sessionType == MLNetworkingSessionTypeForeground) {
			request.HTTPBodyStream = self.HTTPMultipartBodyStream;
		} else {
			self.uploadURL = [self writeBodyStreamIntoTemporatyFileWithError:&error];
		}
	}
	if (error) {
		if (outError) {
			*outError = error;
		}
		return nil;
	}
	return request;
}

- (NSURL *)writeBodyStreamIntoTemporatyFileWithError:(NSError *__autoreleasing *)outError
{
	NSError *error = nil;
	self.tempFileURL = [NSURL fileURLWithPath:[NSTemporaryDirectory() stringByAppendingPathComponent:[[NSProcessInfo processInfo] globallyUniqueString]]];

	NSInputStream *inputStream = self.HTTPMultipartBodyStream;
	NSOutputStream *outputStream = [[NSOutputStream alloc] initWithURL:self.tempFileURL append:NO];

	[inputStream scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
	[outputStream scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];

	[inputStream open];
	[outputStream open];

	while ([inputStream hasBytesAvailable]) {
		if (![outputStream hasSpaceAvailable]) {
			error = [[NSError alloc] initWithDomain:MLNetworkingOperationErrorDomain
			                                   code:MLNetworkingOperationErrorCodeUnableCreateRequest
			                               userInfo:@{NSLocalizedFailureReasonErrorKey : @"Space in disk is insufficient"}];
			break;
		}

		uint8_t buffer[kMLNBufferSize];

		NSInteger bytesRead = [inputStream read:buffer maxLength:kMLNBufferSize];
		if (inputStream.streamError || bytesRead < 0) {
		    error = [[NSError alloc] initWithDomain:MLNetworkingOperationErrorDomain
		                                       code:MLNetworkingOperationErrorCodeUnableCreateRequest
		                                   userInfo:inputStream.streamError.userInfo];
		    break;
		}

		NSInteger bytesWritten = [outputStream write:buffer maxLength:(NSUInteger)bytesRead];
		if (outputStream.streamError || bytesWritten < 0) {
		    error = [[NSError alloc] initWithDomain:MLNetworkingOperationErrorDomain
		                                       code:MLNetworkingOperationErrorCodeUnableCreateRequest
		                                   userInfo:outputStream.streamError.userInfo];
		    break;
		}

		if (bytesRead == 0 && bytesWritten == 0) {
		    break;
		}
	}

	[outputStream close];
	[inputStream close];

	[inputStream removeFromRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
	[outputStream removeFromRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];

	if (error) {
	    if (outError) {
	        *outError = error;
		}
	    return nil;
	}

	return self.tempFileURL;
}

- (uint64_t)contentLength
{
    return [self.HTTPMultipartBodyStream contentLength];
}

#pragma mark - NSCopying

- (instancetype)copyWithZone:(NSZone *)zone
{
    MLNetworkingConfigurationUploadMultipart *copyConfiguration = [super copyWithZone:zone];
    copyConfiguration.HTTPMultipartBodyStream = [self.HTTPMultipartBodyStream copy];
    return copyConfiguration;
}

@end
