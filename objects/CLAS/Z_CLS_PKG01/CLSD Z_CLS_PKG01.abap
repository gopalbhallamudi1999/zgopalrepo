class-pool .
*"* class pool for class Z_CLS_PKG01

*"* local type definitions
include Z_CLS_PKG01===================ccdef.

*"* class Z_CLS_PKG01 definition
*"* public declarations
  include Z_CLS_PKG01===================cu.
*"* protected declarations
  include Z_CLS_PKG01===================co.
*"* private declarations
  include Z_CLS_PKG01===================ci.
endclass. "Z_CLS_PKG01 definition

*"* macro definitions
include Z_CLS_PKG01===================ccmac.
*"* local class implementation
include Z_CLS_PKG01===================ccimp.

*"* test class
include Z_CLS_PKG01===================ccau.

class Z_CLS_PKG01 implementation.
*"* method's implementations
  include methods.
endclass. "Z_CLS_PKG01 implementation
