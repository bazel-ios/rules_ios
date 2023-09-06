// Enables jumping to test failures under Bazel Xcode projects
// 12+, by expanding relative file URLs to be relative to the WORKSPACE.
// Originally inspired by https://github.com/ios-bazel-users/ios-bazel-users/blob/d99366f5bb0b8e945a1a758f832e1b65fb42044f/jump_to_test_failure.md
#import <objc/message.h>
#import <objc/runtime.h>

#import <Foundation/Foundation.h>
#import <XCTest/XCTest.h>

// returns the WorkspacePath for a test bundle by reading the corresponding info.plist
// @testBundle a string with the path:
// e.g. "/Users/some/Library/Developer/Xcode/DerivedData/bazel-project-*/Build/Products/Debug-iphonesimulator/Some.xctest";
// Note: this code is effectively a noop on other test runners than Xcode's GUI
static NSURL *getWorkspacePath(NSString *testBundle)
{
    NSArray *components = testBundle.pathComponents;
    if (components.count < 4) {
        return nil;
    }
    // Get the plist for the .xctest bundle
    NSArray *plistComponents = [[components subarrayWithRange:NSMakeRange(0, components.count - 4)] arrayByAddingObject:@"info.plist"];
    NSURL *plistURL = [NSURL fileURLWithPathComponents:plistComponents];
    NSDictionary *dict = [[NSDictionary alloc] initWithContentsOfURL:plistURL];
    NSString *workspacePath = dict[@"WorkspacePath"];
    if (workspacePath == nil || workspacePath.pathComponents.count < 1) {
        return nil;
    }
    NSArray *workspaceComponents = workspacePath.pathComponents;
    return [NSURL fileURLWithPathComponents:[workspaceComponents subarrayWithRange:NSMakeRange(0, workspaceComponents.count - 1)]];
}

static NSURL *projectRelativeURLforURL(NSURL *fileURL)
{
    NSString *testBundlePath = [NSProcessInfo processInfo].environment[@"XCTestBundlePath"];
    if (testBundlePath != nil && [testBundlePath hasPrefix:@"/tmp/test_runner_work_dir"]) {
        return fileURL;
    }

    NSURL *workspaceURL = getWorkspacePath(testBundlePath);
    if (workspaceURL == nil) {
        return fileURL;
    }
    // Inject the workspace path for the bundle if it doesn't already have the
    // prefix
    NSString *prefix = workspaceURL.path;
    NSURL *localDevURL = [fileURL URLByResolvingSymlinksInPath];
    if ([localDevURL.relativePath hasPrefix:prefix]) {
        return localDevURL;
    }
    return [NSURL fileURLWithPathComponents:@[prefix, fileURL.relativeString]];
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
