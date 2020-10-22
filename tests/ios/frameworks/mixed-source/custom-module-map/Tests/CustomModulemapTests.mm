@import CustomModuleMap;
#include <vector>

@interface BTests: NSObject
@property B *b;
@end

@implementation BTests
- (void)doThing {
    self.b.ints.push_back(1);
}
@end