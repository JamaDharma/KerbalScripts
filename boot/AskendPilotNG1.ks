IF SHIP:ALTITUDE > 10000 {
	HUDTEXT("Not on runaway. Shutting down.", 5, 2, 50, green, true).
	BREAK.
}

WAIT 3.
switch to 0.
run Orbit.
HUDTEXT("Asckend pilot NG engaged!", 5, 2, 50, red, true).

SET SHIP:CONTROL:PILOTMAINTHROTTLE TO 1.
CORE:PART:GETMODULE("kOSProcessor"):DOEVENT("Open Terminal").

set thrustLevel to 1.
set pitchLock to 0.

LOCK STEERING TO HEADING(90, 90 - pitchLock).

//WAIT UNTIL SHIP:LONGITUDE - TARGET:LONGITUDE > 10.
//SET WARP TO 0.
//WAIT UNTIL SHIP:LONGITUDE - TARGET:LONGITUDE < 23.
//SET WARP TO 0.
//HUDTEXT("Starting ascend at delta: " + (SHIP:LONGITUDE - TARGET:LONGITUDE), 5, 2, 50, red, true).

STAGE.

CLEARSCREEN.

function AscendByProfile{
	parameter trgtApoapsis is 80000.
	local altList is list(0, 1000, 3000, 10000, 20000, 40000):ITERATOR.
	local angList is list(1,   20,  30,    45,    60,    80):ITERATOR.
	altList:NEXT.
	angList:NEXT.
	SteerTo(trgtApoapsis, altList, angList).
}

function SteerTo{
	parameter trgtApoapsis.
	parameter startAltPointer.
	parameter startAnglePointer.
	
	local startAlt is startAltPointer:VALUE.
	local startAngle is startAnglePointer:VALUE.
	
	if ((not startAltPointer:NEXT) or (not startAnglePointer:NEXT)) { return. }
	
	local targetAlt is startAltPointer:VALUE.
	local targetAngle is startAnglePointer:VALUE.
	
	PRINT "Target altitude " + targetAlt.
	PRINT "Target angle " + targetAngle.
	until (SHIP:ALTITUDE > targetAlt or ALT:APOAPSIS > trgtApoapsis)
	{
		set pitchLock to startAngle + (SHIP:ALTITUDE - startAlt)/(targetAlt - startAlt)*(targetAngle - startAngle).
		WAIT 0.
	}
	PRINT targetAlt + " passed".
	SteerTo(trgtApoapsis, startAltPointer, startAnglePointer).
}

function KK{
	parameter minVal is 250.
	parameter maxVal is 350.
	parameter val is 300.
	
	local result is (maxVal - val)/(maxVal - minVal).
	
	RETURN MAX(0, MIN(1, result)).
}

WHEN TRUE THEN {
	IF SHIP:ALTITUDE < 10000 { 
		set thrustLevel to KK(250, 350, VELOCITY:SURFACE:MAG*KK(5000, 20000, SHIP:ALTITUDE)).
		RETURN TRUE.
	}  ELSE { 
		set thrustLevel to 1.
		RETURN FALSE.
	}.
}

//Ascend
AscendByProfile(80000).

RiseFromAtmosphere(80000).

StabilizeOrbit().