class-pool .
*"* class pool for class ZCLS_1

*"* local type definitions
include ZCLS_1========================ccdef.

*"* class ZCLS_1 definition
*"* public declarations
  include ZCLS_1========================cu.
*"* protected declarations
  include ZCLS_1========================co.
*"* private declarations
  include ZCLS_1========================ci.
endclass. "ZCLS_1 definition

*"* macro definitions
include ZCLS_1========================ccmac.
*"* local class implementation
include ZCLS_1========================ccimp.

*"* test class
include ZCLS_1========================ccau.

class ZCLS_1 implementation.
*"* method's implementations
  include methods.
endclass. "ZCLS_1 implementation
