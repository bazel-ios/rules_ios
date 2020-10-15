#import "NonArcObject.h"

@implementation NonArcObject
#if REQUIRED_DEFINED_FLAG
@end
#endif

#if FLAG_WITH_VALUE_ZERO
Note: Should not produce build error or index error (on xcode) here because
$FLAG_WITH_VALUE_ZERO should set to to zero
#endif
