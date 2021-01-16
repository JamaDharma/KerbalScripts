function Compas {
	parameter trgtV is FACING:VECTOR.
	local upV is UP:VECTOR.
	local northV is NORTH:VECTOR.
	
	local compasV is trgtV - VDOT(trgtV, upV)*upV.
	return VANG(northV, compasV).
}

CLEARSCREEN.

set compasLock to Compas.
set pitchLock to 10.

LOCK STEERING TO HEADING(compasLock,pitchLock).

local ascendAlt is 20000.
local askendAngle is 30.
until SHIP:ALTITUDE > ascendAlt
{
	set pitchLock to askendAngle * (1 - SHIP:ALTITUDE/ascendAlt).
	WAIT 0.
}.

PRINT "Ascend completed".
set pitchLock to 0.

WAIT UNTIL SHIP:ALTITUDE > 70000.