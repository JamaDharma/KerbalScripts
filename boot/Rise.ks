RUNONCEPATH("0:/lib/Debug").
RUNONCEPATH("0:/lib/Ascend").
RUNONCEPATH("0:/lib/Orbit").
RUNONCEPATH("0:/lib/Plane").
RUNONCEPATH("0:/lib/Ship/Engines").

function ProgradePitch{
	return 90-VANG(UP:VECTOR,SRFPROGRADE:VECTOR).
}

local tracker is PIDLOOP(0,0,1).
function VAcc{
	return -tracker:UPDATE(time:SECONDS, VERTICALSPEED).
}

function DesiredVAcc{
	parameter currP.
	if currP < 10 return 1.
	return (currP-10)/10.
}

function ThrottleLevel{
	parameter eng, currA, tgtA.
	local currThrustLevel is eng:THRUST/eng:MAXTHRUST.
	local newThrust is currThrustLevel + (tgtA-currA)*0.1.
	CLEARSCREEN.
	NPrint("currA",currA).
	NPrint("tgtA",tgtA).
	NPrint("currThrustLevel",currThrustLevel).
	NPrint("newThrust",newThrust).
	return newThrust.
}

function FlyToAlt{
	parameter talt.
	local eng is ListActiveEngines()[0].
	UNTIL ALT:APOAPSIS > talt {
		set pitchLock to ProgradePitch().
		set thrustLevel to ThrottleLevel(eng,VAcc(),DesiredVAcc(pitchLock)).
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
