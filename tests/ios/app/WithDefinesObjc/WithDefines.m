@import Foundation;

@interface WithDefinesObjc : NSObject
@end

@implementation WithDefinesObjc

#if !MACRO_A
 thisShouldNotBeCompiled
#endif
#if !MACRO_B
 thisShouldNotBeCompiled
#endif
#if MACRO_C
 thisShouldNotBeCompiled
#endif
#if !MACRO_D
 thisShouldNotBeCompiled
#endif
#if !MACRO_E
 thisShouldNotBeCompiled
#endif
#if MACRO_F
 thisShouldNotBeCompiled
#endif
#ifndef MACRO_G
 thisShouldNotBeCompiled
#endif

@end
