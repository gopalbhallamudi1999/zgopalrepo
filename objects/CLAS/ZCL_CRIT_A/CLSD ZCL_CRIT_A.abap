class-pool .
*"* class pool for class ZCL_CRIT_A

*"* local type definitions
include ZCL_CRIT_A====================ccdef.

*"* class ZCL_CRIT_A definition
*"* public declarations
  include ZCL_CRIT_A====================cu.
*"* protected declarations
  include ZCL_CRIT_A====================co.
*"* private declarations
  include ZCL_CRIT_A====================ci.
endclass. "ZCL_CRIT_A definition

*"* macro definitions
include ZCL_CRIT_A====================ccmac.
*"* local class implementation
include ZCL_CRIT_A====================ccimp.

*"* test class
include ZCL_CRIT_A====================ccau.

class ZCL_CRIT_A implementation.
*"* method's implementations
  include methods.
endclass. "ZCL_CRIT_A implementation
