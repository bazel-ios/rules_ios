//
// MLNetworkingMultipartBodyStream.m
// MLNetworking
//
// Created by Nicolas Andres Suarez on 1/3/16.
// Copyright © 2016 MercadoLibre. All rights reserved.
//

#import "MLNetworkingMultipartBodyStream.h"

static NSString *MLCreateMultipartFormBoundary()
{
	return [NSString stringWithFormat:@"Boundary+%08X%08X", arc4random(), arc4random()];
}

@interface NSStream ()

@property (readwrite) NSStreamStatus streamStatus;
@property (readwrite, copy) NSError *streamError;

@end

@interface MLNetworkingMultipartBodyStream ()

@property (nonatomic, strong) MLNetworkingBodyPart *currentBodyPart;
@property (nonatomic, strong) NSEnumerator *bodyPartEnumerator;

@end

@implementation MLNetworkingMultipartBodyStream

@synthesize streamStatus;
@synthesize streamError;

- (id)init
{
	self = [super init];
	if (self) {
		self.bodyParts = [[NSMutableArray alloc] init];
		self.boundary = MLCreateMultipartFormBoundary();
	}
	return self;
}

- (void)addBodyPart:(MLNetworkingBodyPart *)bodyPart
{
	NSParameterAssert(bodyPart);
	bodyPart.boundary = self.boundary;
	[self.bodyParts addObject:bodyPart];
}

- (void)setFirstAndLastParts
{
	if ([self.bodyParts count] > 0) {
		for (MLNetworkingBodyPart *bodyPart in self.bodyParts) {
			bodyPart.isFirstPart = NO;
			bodyPart.isLastPart = NO;
		}

		[self.bodyParts firstObject].isFirstPart = YES;
		[self.bodyParts lastObject].isLastPart = YES;
	}
}

- (uint64_t)contentLength
{
	[self setFirstAndLastParts];
	uint64_t length = 0;
	for (MLNetworkingBodyPart *bodyPart in self.bodyParts) {
		length += [bodyPart contentLength];
	}
	return length;
}

#pragma mark - NSInputStream

- (NSInteger)read:(uint8_t *)buffer
        maxLength:(NSUInteger)length
{
	if ([self streamStatus] == NSStreamStatusClosed) {
		return 0;
	}

	NSInteger totalNumberOfBytesRead = 0;

	while ((NSUInteger)totalNumberOfBytesRead < length) {
		if (![self.currentBodyPart hasBytesAvailable]) {
			if (!(self.currentBodyPart = [self.bodyPartEnumerator nextObject])) {
				break;
			}
		} else {
			NSUInteger maxLength = length - (NSUInteger)totalNumberOfBytesRead;
			NSInteger numberOfBytesRead = [self.currentBodyPart read:&buffer[totalNumberOfBytesRead] maxLength:maxLength];
			if (numberOfBytesRead == -1) {
				self.streamError = self.currentBodyPart.inputStream.streamError;
				break;
			} else {
				totalNumberOfBytesRead += numberOfBytesRead;
			}
		}
	}

	return totalNumberOfBytesRead;
}

- (BOOL)getBuffer:(__unused uint8_t **)buffer
           length:(__unused NSUInteger *)len
{
	return NO;
}

- (BOOL)hasBytesAvailable
{
	return [self streamStatus] == NSStreamStatusOpen;
}

#pragma mark - NSStream

- (void)open
{
	if (self.streamStatus == NSStreamStatusOpen) {
		return;
	}

	self.streamStatus = NSStreamStatusOpen;

	[self setFirstAndLastParts];
	self.bodyPartEnumerator = [self.bodyParts objectEnumerator];
}

- (void)close
{
	self.streamStatus = NSStreamStatusClosed;
}

- (void)scheduleInRunLoop:(NSRunLoop *)aRunLoop forMode:(NSString *)mode
{
}

- (void)removeFromRunLoop:(NSRunLoop *)aRunLoop forMode:(NSString *)mode
{
}

#pragma mark - Undocumented CFReadStream Bridged Methods

- (void)_scheduleInCFRunLoop:(__unused CFRunLoopRef)aRunLoop
                     forMode:(__unused CFStringRef)aMode
{
}

- (void)_unscheduleFromCFRunLoop:(__unused CFRunLoopRef)aRunLoop
                         forMode:(__unused CFStringRef)aMode
{
}

- (BOOL)_setCFClientFlags:(__unused CFOptionFlags)inFlags
                 callback:(__unused CFReadStreamClientCallBack)inCallback
                  context:(__unused CFStreamClientContext *)inContext
{
	return NO;
}

#pragma mark - NSCopying

- (instancetype)copyWithZone:(NSZone *)zone
{
	MLNetworkingMultipartBodyStream *bodyStreamCopy = [[[self class] allocWithZone:zone] init];

	for (MLNetworkingBodyPart *bodyPart in self.bodyParts) {
		[bodyStreamCopy addBodyPart:[bodyPart copy]];
	}

	[bodyStreamCopy setFirstAndLastParts];

	return bodyStreamCopy;
}

@end
