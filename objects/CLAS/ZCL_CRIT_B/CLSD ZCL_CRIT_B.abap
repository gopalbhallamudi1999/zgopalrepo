class-pool .
*"* class pool for class ZCL_CRIT_B

*"* local type definitions
include ZCL_CRIT_B====================ccdef.

*"* class ZCL_CRIT_B definition
*"* public declarations
  include ZCL_CRIT_B====================cu.
*"* protected declarations
  include ZCL_CRIT_B====================co.
*"* private declarations
  include ZCL_CRIT_B====================ci.
endclass. "ZCL_CRIT_B definition

*"* macro definitions
include ZCL_CRIT_B====================ccmac.
*"* local class implementation
include ZCL_CRIT_B====================ccimp.

*"* test class
include ZCL_CRIT_B====================ccau.

class ZCL_CRIT_B implementation.
*"* method's implementations
  include methods.
endclass. "ZCL_CRIT_B implementation
