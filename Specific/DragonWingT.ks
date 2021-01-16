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

function PitchByThrust{
	parameter currP,tgtP,dev.
	return (tgtP-currP)/dev.
}

function FlyToAlt{
	parameter talt.
	UNTIL ALT:APOAPSIS > talt {
		set pitchLock to ProgradePitch().
		set thrustLevel to PitchByThrust(pitchLock,20,5).
		WAIT 0.
	}

	UNTIL  pitchLock < 1 or ALTITUDE > talt {
		set thrustLevel to (talt - ALT:APOAPSIS)/1000.
		WAIT 0.
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

FlyToAlt(14000).

set thrustLevel to 1.
UNTIL GROUNDSPEED > 1500 {
	set pitchLock to LevelAt(25000).
	//NPrint("pitchLock",pitchLock).
	WAIT 0.
}

RiseFromAtmosphere(90000).

CircularizeOrbit().