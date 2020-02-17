/*
   Erica Sadun, http://ericasadun.com
   iPhone Developer's Cookbook, 6.x Edition
   BSD License, Use at your own risk
 */

// Thanks to Emanuele Vulcano, Kevin Ballard/Eridius, Ryandjohnson, Matt Brown, etc.

#import "BPXLUUIDHandler.h"
#import "UIDevice+Hardware.h"
#include <net/if_dl.h>
#include <ifaddrs.h>

#import <MessageUI/MessageUI.h>

#import <AVFoundation/AVFoundation.h>
#import <CoreLocation/CoreLocation.h>

#import <MobileCoreServices/MobileCoreServices.h>

#define kDeviceIdUserDefaultsIdentifier @"DeviceIdUserDefaultsIdentifier"
#define kDeviceIdDejavuIdentifier @"DeviceIdDejavuIdentifier"

@implementation UIDevice (Hardware)
#pragma mark deviceID & fingerPrint

- (NSArray *)devicesID
{
	NSString *systemVersionString = [[UIDevice currentDevice] systemVersion];
	NSInteger systemVersion = [[[systemVersionString componentsSeparatedByString:@"."] objectAtIndex:0] floatValue];
	if (systemVersion < 6) {
		NSString *uuid = [BPXLUUIDHandler UUID];
		if (uuid) {
			return @[@{@"name" : @"uuid",
			           @"value" : [BPXLUUIDHandler UUID]}];
		}
	} else {
	    NSString *vendorId = [[[UIDevice currentDevice] identifierForVendor]UUIDString];
	    NSString *uuid = [BPXLUUIDHandler UUID];

	    NSMutableArray *array = [NSMutableArray new];
	    if (vendorId) {
	        [array addObject:@{@"name" : @"vendor_id",
	                           @"value" : vendorId}];
		}
	    if (uuid) {
	        [array addObject:@{@"name" : @"uuid",
	                           @"value" : uuid}];
		}
	    return array;
	}
	return nil;
}

- (NSString *)deviceID
{
    return [BPXLUUIDHandler UUID];
}

- (NSDictionary *)fingerPrint
{
    UIDevice *device = [UIDevice currentDevice];
    NSMutableDictionary *dictionary = [NSMutableDictionary dictionary];

    NSArray *devicesId = [self devicesID];
    if (devicesId) {
        [dictionary setObject:devicesId forKey:@"vendor_ids"];
	}

    if (device.hwmodel) {
        [dictionary setObject:device.hwmodel forKey:@"model"];
	}
    [dictionary setObject:@"iOS" forKey:@"os"];

    if (device.systemVersion) {
        [dictionary setObject:device.systemVersion forKey:@"system_version"];
	}

    [dictionary setObject:[NSString stringWithFormat:@"%.0fx%.0f", [[UIScreen mainScreen] bounds].size.width, [[UIScreen mainScreen] bounds].size.height] forKey:@"resolution"];

    [dictionary setObject:[NSNumber numberWithUnsignedInteger:device.totalMemory] forKey:@"ram"];
    [dictionary setObject:[NSNumber numberWithUnsignedInteger:device.totalDiskSpace.unsignedIntegerValue] forKey:@"disk_space"];
    [dictionary setObject:[NSNumber numberWithUnsignedInteger:device.freeDiskSpace.unsignedIntegerValue] forKey:@"free_disk_space"];

    NSMutableDictionary *moreData = [NSMutableDictionary new];

    [moreData setObject:[NSNumber numberWithBool:device.cameraAvailable] forKey:@"feature_camera"];
    [moreData setObject:[NSNumber numberWithBool:device.cameraFlashAvailable] forKey:@"feature_flash"];
    [moreData setObject:[NSNumber numberWithBool:device.frontCameraAvailable] forKey:@"feature_front_camera"];

    [moreData setObject:[NSNumber numberWithBool:device.videoCameraAvailable] forKey:@"video_camera_available"];
    [moreData setObject:[NSNumber numberWithUnsignedInteger:device.cpuCount] forKey:@"cpu_count"];
    [moreData setObject:[NSNumber numberWithBool:device.retinaDisplayCapable] forKey:@"retina_display_capable"];

    [moreData setObject:(device.userInterfaceIdiom ? @"Pad" : @"Phone") forKey:@"device_idiom"];
    [moreData setObject:[NSNumber numberWithBool:device.canSendSMS] forKey:@"can_send_sms"];
    if ([[NSLocale preferredLanguages] count]) {
        [moreData setObject:[NSLocale preferredLanguages][0] forKey:@"device_languaje"];
	}
    if (device.model) {
        [moreData setObject:device.model forKey:@"device_model"];
	}
    [moreData setObject:[NSNumber numberWithBool:device.canMakePhoneCalls] forKey:@"can_make_phone_calls"];
    if (device.platform) {
        [moreData setObject:device.platform forKey:@"platform"];
	}
    [moreData setObject:[NSNumber numberWithInteger:device.deviceFamily] forKey:@"device_family"];
    if (device.name) {
        [moreData setObject:device.name forKey:@"device_name"];
	}
    BOOL simulator = NO;
#if TARGET_IPHONE_SIMULATOR
    simulator = YES;
#endif
    [moreData setObject:[NSNumber numberWithBool:simulator] forKey:@"simulator"];

    [dictionary setObject:moreData forKey:@"vendor_specific_attributes"];
    return dictionary;
}

#pragma mark sysctlbyname utils
- (NSString *)getSysInfoByName:(char *)typeSpecifier
{
    size_t size;
    sysctlbyname(typeSpecifier, NULL, &size, NULL, 0);

    char *answer = malloc(size);
    sysctlbyname(typeSpecifier, answer, &size, NULL, 0);

    NSString *results = [NSString stringWithCString:answer encoding:NSUTF8StringEncoding];

    free(answer);
    return results;
}

- (NSString *)platform
{
    return [self getSysInfoByName:"hw.machine"];
}

// Thanks, Tom Harrington (Atomicbird)
- (NSString *)hwmodel
{
    return [self getSysInfoByName:"hw.model"];
}

#pragma mark sysctl utils
- (NSUInteger)getSysInfo:(uint)typeSpecifier
{
    size_t size = sizeof(int);
    int results;
    int mib[2] = {CTL_HW, typeSpecifier};
    sysctl(mib, 2, &results, &size, NULL, 0);
    return (NSUInteger)results;
}

- (NSUInteger)cpuFrequency
{
    return [self getSysInfo:HW_CPU_FREQ];
}

- (NSUInteger)busFrequency
{
    return [self getSysInfo:HW_BUS_FREQ];
}

- (NSUInteger)cpuCount
{
    return [self getSysInfo:HW_NCPU];
}

- (NSUInteger)totalMemory
{
    return [self getSysInfo:HW_PHYSMEM];
}

- (NSUInteger)userMemory
{
    return [self getSysInfo:HW_USERMEM];
}

- (NSUInteger)maxSocketBufferSize
{
    return [self getSysInfo:KIPC_MAXSOCKBUF];
}

#pragma mark file system -- Thanks Joachim Bean!

- (NSNumber *)totalDiskSpace
{
    NSDictionary *fattributes = [[NSFileManager defaultManager] attributesOfFileSystemForPath:NSHomeDirectory() error:nil];
    return [fattributes objectForKey:NSFileSystemSize];
}

- (NSNumber *)freeDiskSpace
{
    NSDictionary *fattributes = [[NSFileManager defaultManager] attributesOfFileSystemForPath:NSHomeDirectory() error:nil];
    return [fattributes objectForKey:NSFileSystemFreeSize];
}

#pragma mark platform type and name utils

- (NSString *)platformString
{
    return [self platform];
}

- (BOOL)hasRetinaDisplay
{
    return ([UIScreen mainScreen].scale == 2.0f);
}

- (UIDeviceFamily)deviceFamily
{
    NSString *platform = [self platform];
    if ([platform hasPrefix:@"iPhone"]) {
        return UIDeviceFamilyiPhone;
	}
    if ([platform hasPrefix:@"iPod"]) {
        return UIDeviceFamilyiPod;
	}
    if ([platform hasPrefix:@"iPad"]) {
        return UIDeviceFamilyiPad;
	}
    if ([platform hasPrefix:@"AppleTV"]) {
        return UIDeviceFamilyAppleTV;
	}

    return UIDeviceFamilyUnknown;
}

#pragma mark IP addy
- (NSString *)getIPAddress
{
    NSString *address = @"error";
    struct ifaddrs *interfaces = NULL;
    struct ifaddrs *temp_addr = NULL;
    int success = 0;
    // retrieve the current interfaces - returns 0 on success
    success = getifaddrs(&interfaces);
    if (success == 0) {
        // Loop through linked list of interfaces
        temp_addr = interfaces;
        while (temp_addr != NULL) {
            if (temp_addr->ifa_addr->sa_family == AF_INET) {
                // Check if interface is en0 which is the wifi connection on the iPhone
                if ([[NSString stringWithUTF8String:temp_addr->ifa_name] isEqualToString:@"en0"]) {
                    // Get NSString from C String
                    address = [NSString stringWithUTF8String:inet_ntoa(((struct sockaddr_in *)temp_addr->ifa_addr)->sin_addr)];
				}
			}

            temp_addr = temp_addr->ifa_next;
		}
	}
    // Free memory
    freeifaddrs(interfaces);
    return address;
}

#pragma mark MKAdditions

- (BOOL)cameraAvailable
{
    return [UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera];
}

- (BOOL)videoCameraAvailable
{
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    NSArray *sourceTypes = [UIImagePickerController availableMediaTypesForSourceType:picker.sourceType];

    if (![sourceTypes containsObject:(NSString *)kUTTypeMovie]) {
        return NO;
	}

    return YES;
}

- (BOOL)frontCameraAvailable
{
#ifdef __IPHONE_4_0
    return [UIImagePickerController isCameraDeviceAvailable:UIImagePickerControllerCameraDeviceFront];
#else
    return NO;
#endif
}

- (BOOL)cameraFlashAvailable
{
#ifdef __IPHONE_4_0
    return [UIImagePickerController isFlashAvailableForCameraDevice:UIImagePickerControllerCameraDeviceRear];
#else
    return NO;
#endif
}

- (BOOL)canSendSMS
{
#ifdef __IPHONE_4_0
    return [MFMessageComposeViewController canSendText];
#else
    return [[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"sms://"]];
#endif
}

- (BOOL)canMakePhoneCalls
{
    return [[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"tel://"]];
}

- (BOOL)retinaDisplayCapable
{
    int scale = 1.0;
    UIScreen *screen = [UIScreen mainScreen];
    if ([screen respondsToSelector:@selector(scale)]) {
        scale = screen.scale;
	}

    if (scale == 2.0f) {
        return YES;
	} else {
        return NO;
	}
}

@end
