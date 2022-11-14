enum WithDefinesSwift {
  func foo() {
#if !MACRO_H
 #error("MACRO_H is not defined")
#endif
#if !MACRO_I
 #error("MACRO_I is not defined")
#endif
#if MACRO_J
 #error("MACRO_J is defined")
#endif
#if !MACRO_K
 #error("MACRO_K is not defined")
#endif
#if !MACRO_L
 #error("MACRO_L is not defined")
#endif
#if MACRO_M
 #error("MACRO_M is defined")
#endif
  }
}
