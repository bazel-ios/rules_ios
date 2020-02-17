//
// MLNetworkingBodyPart.m
// MLNetworking
//
// Created by Nicolas Andres Suarez on 1/3/16.
// Copyright © 2016 MercadoLibre. All rights reserved.
//

#import "MLNetworkingBodyPart.h"

static NSString *const kMLMultipartFormCRLF = @"\r\n";

static inline NSString *MLMultipartFormInitialBoundary(
	NSString *boundary)
{
	return [NSString stringWithFormat:@"--%@%@", boundary, kMLMultipartFormCRLF];
}

static inline NSString *MLMultipartFormEncapsulationBoundary(
	NSString *boundary)
{
	return [NSString stringWithFormat:@"%@--%@%@", kMLMultipartFormCRLF, boundary, kMLMultipartFormCRLF];
}

static inline NSString *MLMultipartFormFinalBoundary(
	NSString *boundary)
{
	return [NSString stringWithFormat:@"%@--%@--%@", kMLMultipartFormCRLF, boundary, kMLMultipartFormCRLF];
}

typedef NS_ENUM (NSUInteger, MLBodyPartReadSection) {
	MLInitialBoundarySection,
	MLHeaderSection,
	MLBodySection,
	MLFinalBoundarySection
};

@interface MLNetworkingBodyPart ()
{
	MLBodyPartReadSection _currentReadSection;
	NSUInteger _sectionReadOffset;
}

@end

@implementation MLNetworkingBodyPart

- (instancetype)initWithStream:(NSInputStream *)inputStream
                        length:(int64_t)length
                          name:(NSString *)name
                      fileName:(NSString *)fileName
                      mimeType:(NSString *)mimeType
{
	self = [super init];
	if (self) {
		NSString *contentDisposition = [NSString stringWithFormat:@"form-data; name=\"%@\"; fileName=\"%@\"", name, fileName];
		self.headers = @{@"Content-Disposition" : contentDisposition,
		                 @"Content-Type" : mimeType};
		self.inputStream = inputStream;
		self.bodyLength = length;
	}
	return self;
}

- (instancetype)initWithFileURL:(NSURL *)fileUrl
                           name:(NSString *)name
                       fileName:(NSString *)fileName
                       mimeType:(NSString *)mimeType
{
	self = [super init];
	if (self) {
		NSString *contentDisposition = [NSString stringWithFormat:@"form-data; name=\"%@\"; fileName=\"%@\"", name, fileName];
		self.headers = @{@"Content-Disposition" : contentDisposition,
		                 @"Content-Type" : mimeType};
		self.inputStream = [[NSInputStream alloc] initWithURL:fileUrl];

		NSError *error;
		NSDictionary *fileAttributes = [[NSFileManager defaultManager] attributesOfItemAtPath:[fileUrl path] error:&error];
		if (!error && fileAttributes) {
			self.bodyLength = [fileAttributes[NSFileSize] unsignedLongLongValue];
		}
	}
	return self;
}

- (instancetype)initWithFileData:(NSData *)fileData
                            name:(NSString *)name
                        fileName:(NSString *)fileName
                        mimeType:(NSString *)mimeType
{
	self = [super init];
	if (self) {
		NSString *contentDisposition = [NSString stringWithFormat:@"form-data; name=\"%@\"; fileName=\"%@\"", name, fileName];
		self.headers = @{@"Content-Disposition" : contentDisposition,
		                 @"Content-Type" : mimeType};
		self.inputStream = [[NSInputStream alloc] initWithData:fileData];
		self.bodyLength = [fileData length];
	}
	return self;
}

- (instancetype)initWithData:(NSData *)data
                        name:(NSString *)name
{
	self = [super init];
	if (self) {
		NSString *contentDisposition = [NSString stringWithFormat:@"form-data; name=\"%@\"", name];
		self.headers = @{@"Content-Disposition" : contentDisposition};
		self.inputStream = [[NSInputStream alloc] initWithData:data];
		self.bodyLength = [data length];
	}
	return self;
}

- (void)dealloc
{
	if (self.inputStream) {
		[self.inputStream close];
		self.inputStream = nil;
	}
}

- (NSString *)stringHeaders
{
	NSMutableString *headers = [[NSMutableString alloc] init];
	for (NSString *key in [self.headers allKeys]) {
		NSString *value = self.headers[key];
		[headers appendFormat:@"%@: %@%@", key, value, kMLMultipartFormCRLF];
	}
	[headers appendString:kMLMultipartFormCRLF];
	return headers;
}

- (NSString *)initialBoundary
{
	return self.isFirstPart ? MLMultipartFormInitialBoundary(self.boundary) : MLMultipartFormEncapsulationBoundary(self.boundary);
}

- (NSString *)finalBoundary
{
	return self.isLastPart ? MLMultipartFormFinalBoundary(self.boundary) : @"";
}

- (BOOL)hasBytesAvailable
{
	// Allows `read:maxLength:` to be called again if `MLBodyPartFinalBoundary` doesn't fit into the available buffer
	if (_currentReadSection == MLFinalBoundarySection) {
		return YES;
	}

	switch (self.inputStream.streamStatus) {
		case NSStreamStatusNotOpen:
		case NSStreamStatusOpening:
		case NSStreamStatusOpen:
		case NSStreamStatusReading:
		case NSStreamStatusWriting: {
			return YES;
		}

		case NSStreamStatusAtEnd:
		case NSStreamStatusClosed:
		case NSStreamStatusError:
		default:
			return NO;
	}
}

- (NSInteger)read:(uint8_t *)buffer
        maxLength:(NSUInteger)length
{
	NSInteger totalNumberOfBytesRead = 0;

	if (_currentReadSection == MLInitialBoundarySection) {
		NSData *encapsulationBoundaryData = [[self initialBoundary] dataUsingEncoding:NSUTF8StringEncoding];
		totalNumberOfBytesRead += [self readData:encapsulationBoundaryData intoBuffer:&buffer[totalNumberOfBytesRead] maxLength:(length - (NSUInteger)totalNumberOfBytesRead)];
	}

	if (_currentReadSection == MLHeaderSection) {
		NSData *headersData = [[self stringHeaders] dataUsingEncoding:NSUTF8StringEncoding];
		totalNumberOfBytesRead += [self readData:headersData intoBuffer:&buffer[totalNumberOfBytesRead] maxLength:(length - (NSUInteger)totalNumberOfBytesRead)];
	}

	if (_currentReadSection == MLBodySection) {
		NSInteger numberOfBytesRead = 0;

		numberOfBytesRead = [self.inputStream read:&buffer[totalNumberOfBytesRead] maxLength:(length - (NSUInteger)totalNumberOfBytesRead)];
		if (numberOfBytesRead == -1) {
			return -1;
		} else {
			totalNumberOfBytesRead += numberOfBytesRead;

			if ([self.inputStream streamStatus] >= NSStreamStatusAtEnd) {
				[self transitionToNextPhase];
			}
		}
	}

	if (_currentReadSection == MLFinalBoundarySection) {
		NSData *closingBoundaryData = [[self finalBoundary] dataUsingEncoding:NSUTF8StringEncoding];
		totalNumberOfBytesRead += [self readData:closingBoundaryData
		                              intoBuffer:&buffer[totalNumberOfBytesRead]
		                               maxLength:(length - (NSUInteger)totalNumberOfBytesRead)];
	}

	return totalNumberOfBytesRead;
}

- (NSInteger)readData:(NSData *)data
           intoBuffer:(uint8_t *)buffer
            maxLength:(NSUInteger)length
{
	NSRange range = NSMakeRange(_sectionReadOffset, MIN([data length] - _sectionReadOffset, length));
	[data getBytes:buffer range:range];

	_sectionReadOffset += range.length;

	if (((NSUInteger)_sectionReadOffset) >= [data length]) {
		[self transitionToNextPhase];
	}

	return (NSInteger)range.length;
}

- (BOOL)transitionToNextPhase
{
	switch (_currentReadSection) {
		case MLInitialBoundarySection: {
			_currentReadSection = MLHeaderSection;
			break;
		}

		case MLHeaderSection: {
			[self.inputStream scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSRunLoopCommonModes];
			[self.inputStream open];
			_currentReadSection = MLBodySection;
			break;
		}

		case MLBodySection: {
			[self.inputStream close];
			[self.inputStream removeFromRunLoop:[NSRunLoop currentRunLoop] forMode:NSRunLoopCommonModes];
			_currentReadSection = MLFinalBoundarySection;
			break;
		}

		case MLFinalBoundarySection:
		default: {
			_currentReadSection = MLInitialBoundarySection;
			break;
		}
	}
	_sectionReadOffset = 0;

	return YES;
}

- (uint64_t)contentLength
{
	uint64_t length = [[[self initialBoundary] dataUsingEncoding:NSUTF8StringEncoding] length];
	length += [[[self stringHeaders] dataUsingEncoding:NSUTF8StringEncoding] length];
	length += self.bodyLength;
	length += [[[self finalBoundary] dataUsingEncoding:NSUTF8StringEncoding] length];
	return length;
}

- (instancetype)copyWithZone:(NSZone *)zone
{
	MLNetworkingBodyPart *copyBodyPart = [[[self class] allocWithZone:zone] init];

	copyBodyPart.boundary = self.boundary;
	copyBodyPart.headers = self.headers;
	copyBodyPart.inputStream = self.inputStream;
	copyBodyPart.bodyLength = self.bodyLength;
	copyBodyPart.isFirstPart = self.isFirstPart;
	copyBodyPart.isLastPart = self.isLastPart;

	return copyBodyPart;
}

@end
