@import Foundation;
#import "A.h"
#include <vector>

@interface B: NSObject
@property std::vector<int> ints;
@property A *a;
@end
