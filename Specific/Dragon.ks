switch to 0.
//RUNONCEPATH("Targeting").
RUNONCEPATH("Ascend").
RUNONCEPATH("Orbit").

function ProgradeOr{
	parameter limit.
	RETURN MAX(90 - VANG(UP:VECTOR, SRFPROGRADE:VECTOR) - 1, limit).
}


IF SHIP:ALTITUDE > 1000 {
	HUDTEXT("Not on runaway. Breaking.", 5, 2, 50, green, true).
	PRINT 1/0.
}

BRAKES ON.


set thrustLevel to 1.
set pitchLock to ProgradeOr(1).

LOCK STEERING TO HEADING(90, pitchLock).

STAGE.
HUDTEXT("Ignition!", 5, 2, 50, red, true).

WAIT 2.
BRAKES OFF.
HUDTEXT("Runaway!", 5, 2, 50, green, true).

UNTIL GROUNDSPEED > 110 {
	set pitchLock to 90 - VANG(UP:VECTOR, SHIP:FACING:VECTOR).
}
set pitchLock to 8.

WAIT UNTIL ALT:RADAR > 10.
GEAR OFF.
HUDTEXT("Takeoff!", 5, 2, 50, blue, true).
WAIT UNTIL GROUNDSPEED > 150.

set pitchLock to 5.
WAIT UNTIL GROUNDSPEED > 400.
UNTIL GROUNDSPEED > 600 {
	set pitchLock to 5 + 15*(GROUNDSPEED-400)/200.
	WAIT 0.
}

WAIT UNTIL SHIP:ALTITUDE > 8000.

UNTIL SHIP:GROUNDSPEED > 1400 {
	set pitchLock to ProgradeOr(5).
	WAIT 0.
}

ON (SHIP:ALTITUDE > 20000) {
	HUDTEXT("Nuclear engines - ignition!", 5, 2, 50, red, true).
	STAGE.
}

UNTIL GROUNDSPEED > 1550 {
	set pitchLock to 5 + 7.5*(GROUNDSPEED-1400)/150.
	WAIT 0.
}

UNTIL SHIP:ALTITUDE > 45000 {
	set pitchLock to 12.5 + 5*(SHIP:ALTITUDE-20000)/25000.
	WAIT 0.
}

RiseFromAtmosphere(75000).

CircularizeOrbit().