class-pool .
*"* class pool for class Z_CLS3_PKG1

*"* local type definitions
include Z_CLS3_PKG1===================ccdef.

*"* class Z_CLS3_PKG1 definition
*"* public declarations
  include Z_CLS3_PKG1===================cu.
*"* protected declarations
  include Z_CLS3_PKG1===================co.
*"* private declarations
  include Z_CLS3_PKG1===================ci.
endclass. "Z_CLS3_PKG1 definition

*"* macro definitions
include Z_CLS3_PKG1===================ccmac.
*"* local class implementation
include Z_CLS3_PKG1===================ccimp.

*"* test class
include Z_CLS3_PKG1===================ccau.

class Z_CLS3_PKG1 implementation.
*"* method's implementations
  include methods.
endclass. "Z_CLS3_PKG1 implementation
