switch to 0.
RUNONCEPATH("Targeting").
RUNONCEPATH("Ascend").
RUNONCEPATH("Orbit").

function ProgradeOr{
	parameter limit.
	RETURN MAX(90 - VANG(UP:VECTOR, SRFPROGRADE:VECTOR) - 1, limit).
}

//CORE:PART:GETMODULE("kOSProcessor"):DOEVENT("Open Terminal").
//CLEARSCREEN.

IF SHIP:ALTITUDE > 1000 {
	HUDTEXT("Not on runaway. Breaking.", 5, 2, 50, green, true).
	PRINT 1/0.
}

BRAKES ON.

SetDefaultTarget().
WAIT UNTIL TargetSet().

HUDTEXT("Waiting for launch window!", 5, 2, 50, green, true).
WaitForIt(35).

set thrustLevel to 1.
set pitchLock to 2.

LOCK STEERING TO HEADING(90, pitchLock).

SET lfTransfer TO TRANSFERALL("liquidfuel", SHIP:PARTSDUBBED("LfSrc"), SHIP:PARTSDUBBED("LfDst")).

SET startingDiff TO LongitudeDelta().
HUDTEXT("Starting longitude difference: " + startingDiff, 5, 2, 50, green, true).

STAGE.
HUDTEXT("Ignition!", 5, 2, 50, red, true).

WAIT 5.
BRAKES OFF.
HUDTEXT("Runaway!", 5, 2, 50, green, true).

UNTIL GROUNDSPEED > 110 {
	set pitchLock to 90 - VANG(UP:VECTOR, SHIP:FACING:VECTOR).
}
set pitchLock to 10.

WAIT UNTIL ALT:RADAR > 10.
GEAR OFF.
HUDTEXT("Takeoff!", 5, 2, 50, blue, true).
WAIT UNTIL GROUNDSPEED > 200.

set pitchLock to 5.
WAIT UNTIL GROUNDSPEED > 400.

set pitchLock to 10.
WAIT UNTIL SHIP:ALTITUDE > 8000.

UNTIL SHIP:ALTITUDE > 20000 {
	set pitchLock to ProgradeOr(5).
	WAIT 0.
}

HUDTEXT("Nuclear engines - ignition!", 5, 2, 50, red, true).
STAGE.
SET lfTransfer:ACTIVE to TRUE.

set pitchLock to 9.
WAIT UNTIL VANG(UP:VECTOR, SRFPROGRADE:VECTOR) > (90 - 3).

HUDTEXT("Closed cycle mode!", 5, 2, 50, red, true).
TOGGLE AG3.
WAIT UNTIL ALT:APOAPSIS > 45000.

TOGGLE AG1.
SET lfTransfer:ACTIVE to TRUE.

RiseFromAtmosphere(75000).

CircularizeOrbit().

SET endingDiff TO SHIP:LONGITUDE - TARGET:LONGITUDE.
HUDTEXT("Ending longitude difference: " + endingDiff, 5, 2, 50, green, true).

HUDTEXT("Longitude delta: " + (startingDiff - endingDiff), 5, 2, 50, green, true).