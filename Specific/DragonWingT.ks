RUNONCEPATH("0:/lib/Debug").
RUNONCEPATH("0:/lib/Ascend").
RUNONCEPATH("0:/lib/Orbit").
RUNONCEPATH("0:/lib/Plane").

function ProgradePitch{
	return 90-VANG(UP:VECTOR,SRFPROGRADE:VECTOR).
}

function LevelAt{
	parameter h.
	if ALTITUDE > h return 0.
	return ProgradePitch*(h-ALTITUDE)/h.
}

function NuclearEngineTrigger{
	WHEN (SHIP:ALTITUDE > 24000) THEN {
		HUDTEXT("Nuclear engines - ignition!", 5, 2, 50, red, true).
		STAGE.
	}
}


function FlyToAlt{
	parameter talt.
	local vspid is PIDLOOP(0.05,0,1).
	set vspid:SETPOINT to 150.
	UNTIL ALT:APOAPSIS > talt {
		set pitchLock to MAX(0,MIN(20,ProgradePitch())).
		set thrustLevel to vspid:UPDATE(TIME:SECONDS,VERTICALSPEED).
		WAIT 0.
		CLEARSCREEN.
		NPrint("pitchLock",pitchLock).
		NPrint("thrustLevel",thrustLevel).		
	}
}

IF AIRSPEED > 10 {
	HUDTEXT("Not on runaway. Breaking.", 5, 2, 50, green, true).
	PRINT 1/0.
}

BRAKES ON.
set thrustLevel to 1.
set pitchLock to 3.
LOCK STEERING TO HEADING(90, pitchLock).

RetractGearTrigger().
NuclearEngineTrigger().

WAIT 1.

STAGE.
HUDTEXT("Ignition!", 5, 2, 50, red, true).

WAIT 2.
BRAKES OFF.
HUDTEXT("Runaway!", 5, 2, 50, green, true).

set pitchLock to 90 - VANG(UP:VECTOR, SHIP:FACING:VECTOR)+2.
WAIT UNTIL GROUNDSPEED > 110.

set pitchLock to 5.

WAIT UNTIL GROUNDSPEED > 150.

FlyToAlt(16000).

set thrustLevel to 1.
UNTIL GROUNDSPEED > 1500 {
	set pitchLock to LevelAt(25000).
	//NPrint("pitchLock",pitchLock).
	WAIT 0.
}

RiseFromAtmosphere(90000).

CircularizeOrbit().