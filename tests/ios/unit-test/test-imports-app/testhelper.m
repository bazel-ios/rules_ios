#import "testhelper.h"
#import <TestImports-App/Header2.h>

@implementation ObjCTestHelper

+ (NSString *)createString {
    return [NSString stringWithFormat:@"ObjcTestHelperString_EnumValue=%ld", AppErrorCodeUnknown];
}

@end
