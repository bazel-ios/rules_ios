enum WithDefinesSwift {
  func foo() {
#if !MACRO_H
 thisShouldNotBeCompiled
#endif
#if !MACRO_I
 thisShouldNotBeCompiled
#endif
#if MACRO_J
 thisShouldNotBeCompiled
#endif
#if !MACRO_K
 thisShouldNotBeCompiled
#endif
#if !MACRO_L
 thisShouldNotBeCompiled
#endif
#if MACRO_M
 thisShouldNotBeCompiled
#endif
  }
}
