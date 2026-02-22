class-pool .
*"* class pool for class ZCL_BASE_DEP

*"* local type definitions
include ZCL_BASE_DEP==================ccdef.

*"* class ZCL_BASE_DEP definition
*"* public declarations
  include ZCL_BASE_DEP==================cu.
*"* protected declarations
  include ZCL_BASE_DEP==================co.
*"* private declarations
  include ZCL_BASE_DEP==================ci.
endclass. "ZCL_BASE_DEP definition

*"* macro definitions
include ZCL_BASE_DEP==================ccmac.
*"* local class implementation
include ZCL_BASE_DEP==================ccimp.

*"* test class
include ZCL_BASE_DEP==================ccau.

class ZCL_BASE_DEP implementation.
*"* method's implementations
  include methods.
endclass. "ZCL_BASE_DEP implementation
