RUNONCEPATH("0:/lib/Surface").

parameter spd is 20.
PRINT "Cruise speed: " + spd.

CLEARSCREEN.

set motor to 1.
set steerLock to SRFPROGRADE.
BRAKES OFF.
SAS OFF.

set STEERINGMANAGER:ROLLCONTROLANGLERANGE to 180.

LOCK WHEELTHROTTLE TO motor.
LOCK STEERING to steerLock.

function NPrint {
	parameter s,n.
	PRINT s + ": " + ROUND(n,2).
}
WHEN terminal:input:haschar THEN {
	local ch is terminal:input:getchar().
	if ch = "w" {
		set spd to spd+1.
	} else if ch = "s" {
		set spd to spd-1.
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
	
	
	//set steerLock to AdjDirByRoll(LookDir(),SurfaceRollVector(ship)).
	set steerLock to HEADING(heading_of_vector(LookDir():VECTOR), SurfacePitch(ship),SurfaceRoll(ship)).
	
	WAIT 0.1.
}

SAS ON.
BRAKES ON.
CORE:PART:CONTROLFROM().
