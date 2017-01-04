#ifndef metamacro_concat
#define metamacro_concat(A, B) A ## B
#endif

#ifndef weakify
#define weakify(VAR) \
  autoreleasepool {} \
  __weak __typeof__(VAR) metamacro_concat(VAR, _weak_) = (VAR);
#endif

#ifndef strongify
#define strongify(VAR) \
  autoreleasepool {} \
  _Pragma("clang diagnostic push") \
  _Pragma("clang diagnostic ignored \"-Wshadow\"") \
  __strong __typeof__(VAR) VAR = metamacro_concat(VAR, _weak_);\
  _Pragma("clang diagnostic pop")
#endif
