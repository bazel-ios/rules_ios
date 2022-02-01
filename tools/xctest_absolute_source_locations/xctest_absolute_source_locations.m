// Enables jumping to test failures under Bazel Xcode projects
// 12+, by expanding relative file URLs to be relative to the WORKSPACE.
// Originally inspired by https://github.com/ios-bazel-users/ios-bazel-users/blob/d99366f5bb0b8e945a1a758f832e1b65fb42044f/jump_to_test_failure.md
#import <objc/message.h>
#import <objc/runtime.h>

#import <Foundation/Foundation.h>
#import <XCTest/XCTest.h>

static NSURL *projectRelativeURLforURL(NSURL *fileURL)
{
    // Detect when running _outside_ Xcode e.g. in Bazel's runner. This way, it
    // retains a execroot path when running outside of it.
    NSString *testBundlePath = [NSProcessInfo processInfo].environment[@"XCTestBundlePath"];
    if (testBundlePath != nil && [testBundlePath hasPrefix:@"/tmp/test_runner_work_dir"]) {
        return fileURL;
    }
    NSArray *components = [fileURL pathComponents];
    if (components.count < 7) {
        return fileURL;
    }
    // Get WORKSPACE from DO_NOT_BUILD_HERE
    // https://github.com/bazelbuild/bazel/blob/0537837897ae70de3e13ab53827961bdae50f6dc/src/main/java/com/google/devtools/build/lib/runtime/BlazeWorkspace.java#L304
    NSArray *doNotBuildHereComponents = [[components subarrayWithRange:NSMakeRange(0, 6)] arrayByAddingObject:@"DO_NOT_BUILD_HERE"];
    NSURL *doNotBuildHereURL = [NSURL fileURLWithPathComponents:doNotBuildHereComponents];
    NSError *error;
    NSString *workspace = [NSString stringWithContentsOfURL:doNotBuildHereURL encoding:NSUTF8StringEncoding error:&error];
    if (error != nil) {
        return fileURL;
    }
    // Because bazel links the first level directories of the WORKSPACE under
    // the execroot, just expanding the path will get it to the right
    // directory.
    NSURL *localDevURL = [fileURL URLByResolvingSymlinksInPath];
    if ([localDevURL.relativePath hasPrefix:workspace]) {
        return localDevURL;
    }
    return fileURL;
}

@interface XCTestAbsoluteSourceLocationsSwizzlingLoader : NSObject
@end


@implementation XCTestAbsoluteSourceLocationsSwizzlingLoader

+ (void)load
{
    SEL initSelector = @selector(initWithFileURL:lineNumber:);
    Method initMethod = class_getInstanceMethod([XCTSourceCodeLocation class], initSelector);

    NSAssert(initMethod, @"Failed to find instance method `%@`", NSStringFromSelector(initSelector));

    __block IMP originalInit = method_setImplementation(initMethod, imp_implementationWithBlock(^(__unsafe_unretained id s, NSURL *URL, NSInteger lineNumber) {
                                                            return ((XCTSourceCodeLocation * (*)(id, SEL, NSURL *, NSInteger)) originalInit)(s, initSelector, projectRelativeURLforURL(URL), lineNumber);
                                                        }));
}

@end
