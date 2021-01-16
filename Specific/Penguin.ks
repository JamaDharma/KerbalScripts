RUNONCEPATH("0:/lib/Debug").
RUNONCEPATH("0:/lib/Ascend").
RUNONCEPATH("0:/lib/Orbit").
RUNONCEPATH("0:/lib/Plane").

function ProgradePitch{
	return 90-VANG(UP:VECTOR,SRFPROGRADE:VECTOR).
}
function LimitedPrograde{
	parameter minP, maxP.
	return MAX(minP,MIN(maxP, ProgradePitch())).
}
function ActualPitch{
	return 90-VANG(UP:VECTOR,FACING:VECTOR).
}
function LevelAt{
	parameter h.
	if ALTITUDE > h return 0.
	return ProgradePitch*(h-ALTITUDE)/h.
}

function PitchByThrust{
	parameter currP,tgtP,dev.
	return (tgtP-currP)/dev.
}

function FlyToAlt{
	parameter talt.
	local downBound is talt*0.8.
	UNTIL ALT:APOAPSIS > downBound {
		set pitchLock to LimitedPrograde(0,20).
		set thrustLevel to 1.
		WAIT 0.
	}
	UNTIL ALTITUDE > downBound {
		set pitchLock to LimitedPrograde(0,20).
		set thrustLevel to (talt - ALT:APOAPSIS)/(talt-downBound).
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

WAIT 1.

STAGE.
HUDTEXT("Ignition!", 5, 2, 50, red, true).

WAIT 2.
BRAKES OFF.
HUDTEXT("Runaway!", 5, 2, 50, green, true).

set pitchLock to 90 - VANG(UP:VECTOR, SHIP:FACING:VECTOR)+1.
WAIT UNTIL GROUNDSPEED > 110.

set pitchLock to 5.

WAIT UNTIL GROUNDSPEED > 150.

FlyToAlt(18000).

set thrustLevel to 1.
UNTIL AIRSPEED > 1450 {
	set pitchLock to LevelAt(25000).
	WAIT 0.
}
UNTIL AIRSPEED > 1650 {
	set pitchLock to ProgradePitch().
	WAIT 0.
}
UNTIL ALTITUDE > 25000 {
	set pitchLock to ProgradePitch().
	WAIT 0.
}
RCS ON.
RiseFromAtmosphere(75000).

CircularizeOrbit().