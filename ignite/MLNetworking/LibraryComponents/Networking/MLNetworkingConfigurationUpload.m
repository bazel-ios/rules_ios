//
// MLNetworkingConfigurationUpload.m
// MLNetworking
//
// Created by Fabian Celdeiro on 12/5/14.
// Copyright (c) 2014 MercadoLibre. All rights reserved.
//

#import "MLNetworkingConfigurationUpload.h"

static NSString *MLNetWorkingCreateMultipartFormBoundary()
{
	return [NSString stringWithFormat:@"Boundary+%08X%08X", arc4random(), arc4random()];
}

@interface MLNetworkingConfigurationUpload ()

@property (nonatomic, strong) NSString *boundary;

@end

@implementation MLNetworkingConfigurationUpload

- (instancetype)init
{
	self = [super init];
	if (self) {
		self.requestType = MLNetworkingRequestTypeUpload;
		self.boundary = MLNetWorkingCreateMultipartFormBoundary();
	}
	return self;
}

- (uint64_t)contentLength
{
	return [self.uploadData length];
}

- (NSMutableURLRequest *)createRequestWithtError:(NSError *__autoreleasing *)outError
{
	NSError *error = nil;
	NSMutableURLRequest *request = [super createRequestWithtError:&error];

	if (request && !error && self.uploadData) {
		[request setValue:[NSString stringWithFormat:@"multipart/form-data; boundary=%@", self.boundary] forHTTPHeaderField:@"Content-Type"];
	}

	if (error && outError) {
		*outError = error;
	}

	return request;
}

- (void)setUploadData:(NSData *)data
                 name:(NSString *)name
             fileName:(NSString *)fileName
             mimeType:(NSString *)mimeType
{
	if (data && name && fileName && mimeType && self.boundary) {
		NSMutableData *bodyData = [NSMutableData data];

		[bodyData appendData:[[NSString stringWithFormat:@"\r\n--%@\r\n", self.boundary] dataUsingEncoding:NSASCIIStringEncoding]];
		[bodyData appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"; filename=\"%@\"\r\n", name, fileName] dataUsingEncoding:NSASCIIStringEncoding]];
		[bodyData appendData:[[NSString stringWithFormat:@"Content-Type: %@\r\n\r\n", mimeType] dataUsingEncoding:NSASCIIStringEncoding]];
		[bodyData appendData:data];
		[bodyData appendData:[[NSString stringWithFormat:@"\r\n--%@--\r\n", self.boundary] dataUsingEncoding:NSASCIIStringEncoding]];

		self.uploadData = bodyData;
	}
}

#pragma mark - NSCopying

- (instancetype)copyWithZone:(NSZone *)zone
{
	MLNetworkingConfigurationUpload *copyConfiguration = [super copyWithZone:zone];
	copyConfiguration.uploadData = self.uploadData;
	copyConfiguration.boundary = self.boundary;

	return copyConfiguration;
}

@end
