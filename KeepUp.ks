//keeping vertical while preserving orientation
SAS OFF.
local str is LOOKDIRUP(UP:VECTOR,ship:FACING:VECTOR+ship:FACING:UPVECTOR).
LOCK STEERING to str.
WAIT UNTIL false.