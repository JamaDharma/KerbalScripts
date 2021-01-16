switch to 0.
RUNONCEPATH("Defaults").

SET SHIP:CONTROL:PILOTMAINTHROTTLE TO 0.
SAS OFF.
GEAR ON.
BRAKES ON.

LOCK  STEERING TO HEADING(TARGET:HEADING, 45).
WAIT 5.
set rdsq to body:radius^2.
set grv to body:mu/rdsq.
function Travel {
	local curv is SQRT(rdsq+TARGET:DISTANCE^2) - body:radius.
	local fall is VERTICALSPEED^2 + 2*grv*(SHIP:ALTITUDE - TARGET:ALTITUDE + curv).
	IF fall <= 0 { return 0. } 
	return GROUNDSPEED*(VERTICALSPEED + SQRT(fall))/grv.
}

set thrustLevel to 1.
UNTIL Travel() > TARGET:DISTANCE {
	WAIT 0.
}

set thrustLevel to 0.