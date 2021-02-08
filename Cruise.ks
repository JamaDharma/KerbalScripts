RUNONCEPATH("0:/lib/Debug").
RUNONCEPATH("0:/lib/Surface").
RUNONCEPATH("0:/lib/Ship/RoverCruiseInfo").

parameter spd is 20.
PRINT "Cruise speed: " + spd.

local pitchCorrection is ReadCruiseCorrection().

CLEARSCREEN.

set motor to 1.
set steerLock to SRFPROGRADE.
BRAKES OFF.
SAS OFF.

set STEERINGMANAGER:ROLLCONTROLANGLERANGE to 180.

LOCK WHEELTHROTTLE TO motor.
LOCK STEERING to steerLock.

WHEN terminal:input:haschar THEN {
	local ch is terminal:input:getchar().
	if ch = "w" {
		set spd to spd+1.
	} else if ch = "s" {
		set spd to spd-1.
	} else if ch = "c" {
		WriteCruiseCorrection().
		set pitchCorrection to ReadCruiseCorrection().
		NPrint("CruiseCorrection updated",pitchCorrection).
	}
	NPrint("Speed",spd).
	return true.
}

set exit to false.
function SafeMode{
	set exit to true.
	UNLOCK WHEELTHROTTLE.
	SAS OFF.
	GEAR ON.
	PANELS OFF.
	SHIP:PARTSTAGGED("UpFacingControlPoint")[0]:CONTROLFROM().
	LOCK STEERING to UP.
	WAIT UNTIL AIRSPEED < 1.
}

function LookDir {
	if airspeed < 3 { return ship:FACING. }
	return SRFPROGRADE.
}

UNTIL exit {

	if not BRAKES { 
		set motor to MAX(0,MIN(1, spd - AIRSPEED)). 
	}
	else { 
		set motor to 0. 
	}

	local ld is LookDir().
	local sn is SurfaceNormal(ship, ld, 5, 10).
	local correction is ANGLEAXIS(-pitchCorrection,ld:STARVECTOR).
	set steerLock to correction*LOOKDIRUP(VXCL(sn,ld:VECTOR), sn).
	
	WAIT 0.
}

SAS ON.
BRAKES ON.
CORE:PART:CONTROLFROM().
