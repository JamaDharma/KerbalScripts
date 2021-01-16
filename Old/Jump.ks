switch to 0.
RUNONCEPATH("Defaults").

SET SHIP:CONTROL:PILOTMAINTHROTTLE TO 0.
SAS OFF.
GEAR ON.
BRAKES ON.

LOCK  STEERING TO HEADING(TARGET:HEADING, 45).
WAIT 5.
set rdsq to BODY:RADIUS^2.
set grv to BODY:MU/rdsq.
function Travel {
	local altDiff is SHIP:ALTITUDE - TARGET:ALTITUDE.
	local dst is SQRT(TARGET:DISTANCE^2 - altDiff^2).
	local grvAdj is grv - GROUNDSPEED^2/BODY:RADIUS.
	local fall is VERTICALSPEED^2 + 2*grvAdj*altDiff.
	IF fall <= 0 { return 0. } 
	return GROUNDSPEED*(VERTICALSPEED + SQRT(fall))/grvAdj.
}
function TargetDistance {
	local altDiff is SHIP:ALTITUDE - TARGET:ALTITUDE.
	RETURN SQRT(TARGET:DISTANCE^2 - altDiff^2).
}

set thrustLevel to 1.
UNTIL Travel() > TargetDistance() {
	WAIT 0.
}

set thrustLevel to 0.