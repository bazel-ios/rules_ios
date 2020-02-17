/*
   Erica Sadun, http://ericasadun.com
   iPhone Developer's Cookbook, 6.x Edition
   BSD License, Use at your own risk
 */

#import <UIKit/UIKit.h>

#include <sys/socket.h> // Per msqr
#include <sys/sysctl.h>
#include <net/if.h>
#include <arpa/inet.h>

typedef NS_ENUM (NSInteger, UIDeviceFamily) {
	UIDeviceFamilyiPhone,
	UIDeviceFamilyiPod,
	UIDeviceFamilyiPad,
	UIDeviceFamilyAppleTV,
	UIDeviceFamilyUnknown,
};

@interface UIDevice (Hardware)

- (NSString *)platform;
- (NSString *)hwmodel;
- (NSString *)platformString;

- (NSUInteger)cpuFrequency;
- (NSUInteger)busFrequency;
- (NSUInteger)cpuCount;
- (NSUInteger)totalMemory;
- (NSUInteger)userMemory;

- (NSNumber *)totalDiskSpace;
- (NSNumber *)freeDiskSpace;

- (NSString *)getIPAddress;

- (BOOL)hasRetinaDisplay;
- (UIDeviceFamily)deviceFamily;

- (NSString *)deviceID;
- (NSDictionary *)fingerPrint;

@end
