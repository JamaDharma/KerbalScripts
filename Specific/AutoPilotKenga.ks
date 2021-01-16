function Compas {
	//parameter trgtV is FACING:VECTOR.
	parameter trgtV is SRFPROGRADE:VECTOR.
	local upV is UP:VECTOR.
	local northV is NORTH:VECTOR.
	
	local compasV is trgtV - VDOT(trgtV, upV)*upV.
	return VANG(northV, compasV).
}
WAIT UNTIL ABS(TARGET:HEADING - Compas()) < 0.2.

SAS OFF.
BRAKES OFF.
CLEARSCREEN.

set compasLock to 1.
set pitchLock to 0.

PRINT "Compas: " + compasLock.

LOCK STEERING TO HEADING(TARGET:HEADING, pitchLock).
//LOCK STEERING TO HEADING(Compas(), pitchLock).

WHEN ALT:RADAR > 20 THEN {
  GEAR OFF.
}

local ascendAlt is 22000.
local askendAngle is 30.
until SHIP:ALTITUDE > ascendAlt
{
	set pitchLock to askendAngle * (1 - SHIP:ALTITUDE/ascendAlt).
	WAIT 0.
}.

PRINT "Ascend completed".
set pitchLock to 0.

WAIT UNTIL SHIP:ALTITUDE > 70000.