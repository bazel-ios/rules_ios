// Based on https://github.com/ios-bazel-users/ios-bazel-users/blob/d99366f5bb0b8e945a1a758f832e1b65fb42044f/jump_to_test_failure.md
// Enables jumping to test failures when using Bazel Xcode projects in Xcode 12+,
// by expanding relative file URLs to be relative to the
// SOURCE_ROOT environment variable, which is already set for all tests / schemes.

#import <objc/message.h>
#import <objc/runtime.h>

#import <Foundation/Foundation.h>
#import <XCTest/XCTest.h>

static NSURL *remapURL(NSURL *fileURL, NSString *srcroot)
{
    if ([fileURL.path hasPrefix:srcroot]) {
        return fileURL;
    }

    return [NSURL fileURLWithPath:[NSString stringWithFormat:@"%@/%@", srcroot, fileURL.relativePath]];
}

static NSURL *parentGitRepoOfURL(NSURL *searchURL)
{
    NSCParameterAssert(searchURL);
    NSURL *url = [[searchURL URLByResolvingSymlinksInPath] absoluteURL];

    NSURL *homeDirectory = [[NSURL fileURLWithPath:NSHomeDirectory()] absoluteURL];
    NSURL *rootDirectory = [[NSURL fileURLWithPath:NSOpenStepRootDirectory()] absoluteURL];
    while (!([url isEqual:homeDirectory] || [url isEqual:rootDirectory])) {
        NSURL *gitPath = [url URLByAppendingPathComponent:@".git"];
        if ([gitPath checkResourceIsReachableAndReturnError:nil]) {
            return url;
        }
        url = [url URLByDeletingLastPathComponent];
    }
    NSCAssert(NO, @"Did not find repo root, home directory or root directory from %@", [searchURL path]);
    return nil;
}


@interface XCTestAbsoluteSourceLocationsSwizzlingLoader : NSObject
@end


@implementation XCTestAbsoluteSourceLocationsSwizzlingLoader

+ (void)load
{
    NSString *srcroot = [[[NSProcessInfo processInfo] environment] objectForKey:@"SOURCE_ROOT"];

    NSAssert(srcroot, @"Expected to find a SOURCE_ROOT environment variable.");
    NSAssert((![srcroot isEqualToString:@"${SRCROOT}"] && ![srcroot isEqualToString:@"$(SRCROOT)"]), @"Got unsubstituted SRCROOT (%@) in SOURCE_ROOT environment variable.", srcroot);
    srcroot = parentGitRepoOfURL([NSURL fileURLWithPath:srcroot]).path;

    if (!srcroot) {
        return;
    }

    SEL initSelector = @selector(initWithFileURL:lineNumber:);
    Method initMethod = class_getInstanceMethod([XCTSourceCodeLocation class], initSelector);

    NSAssert(initMethod, @"Failed to find instance method `%@`", NSStringFromSelector(initSelector));

    __block IMP originalInit = method_setImplementation(initMethod, imp_implementationWithBlock(^(__unsafe_unretained id s, NSURL *URL, NSInteger lineNumber) {
                                                            return ((XCTSourceCodeLocation * (*)(id, SEL, NSURL *, NSInteger)) originalInit)(s, initSelector, remapURL(URL, srcroot), lineNumber);
                                                        }));
}

@end
