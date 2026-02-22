class-pool .
*"* class pool for class ZCL_TEST_CHILD

*"* local type definitions
include ZCL_TEST_CHILD================ccdef.

*"* class ZCL_TEST_CHILD definition
*"* public declarations
  include ZCL_TEST_CHILD================cu.
*"* protected declarations
  include ZCL_TEST_CHILD================co.
*"* private declarations
  include ZCL_TEST_CHILD================ci.
endclass. "ZCL_TEST_CHILD definition

*"* macro definitions
include ZCL_TEST_CHILD================ccmac.
*"* local class implementation
include ZCL_TEST_CHILD================ccimp.

*"* test class
include ZCL_TEST_CHILD================ccau.

class ZCL_TEST_CHILD implementation.
*"* method's implementations
  include methods.
endclass. "ZCL_TEST_CHILD implementation
