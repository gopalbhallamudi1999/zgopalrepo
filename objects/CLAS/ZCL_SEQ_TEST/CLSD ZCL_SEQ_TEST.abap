class-pool .
*"* class pool for class ZCL_SEQ_TEST

*"* local type definitions
include ZCL_SEQ_TEST==================ccdef.

*"* class ZCL_SEQ_TEST definition
*"* public declarations
  include ZCL_SEQ_TEST==================cu.
*"* protected declarations
  include ZCL_SEQ_TEST==================co.
*"* private declarations
  include ZCL_SEQ_TEST==================ci.
endclass. "ZCL_SEQ_TEST definition

*"* macro definitions
include ZCL_SEQ_TEST==================ccmac.
*"* local class implementation
include ZCL_SEQ_TEST==================ccimp.

*"* test class
include ZCL_SEQ_TEST==================ccau.

class ZCL_SEQ_TEST implementation.
*"* method's implementations
  include methods.
endclass. "ZCL_SEQ_TEST implementation
