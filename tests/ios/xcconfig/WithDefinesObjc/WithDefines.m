@import Foundation;

@interface WithDefinesObjc : NSObject
@end

@implementation WithDefinesObjc

#if !MACRO_A
 #error "MACRO_A is not defined"
#endif
#if !MACRO_B
 #error "MACRO_B is not defined"
#endif
#if MACRO_C
 #error "MACRO_C is defined"
#endif
#if !MACRO_D
 #error "MACRO_D is not defined"
#endif
#if !MACRO_E
 #error "MACRO_E is not defined"
#endif
#if MACRO_F
 #error "MACRO_F is defined"
#endif
#ifndef MACRO_G
 #error "MACRO_G is not defined"
#endif

@end
