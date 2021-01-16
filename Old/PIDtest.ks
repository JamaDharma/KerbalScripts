switch to 0.
RUNONCEPATH("Ascend").
RUNONCEPATH("Orbit").
RUNONCEPATH("Losses").

set thrustLevel to 1.
set pitchLock to 16.
LOCK STEERING TO HEADING(90, 90 - pitchLock).

SET PID TO PIDLOOP(1, 0.2, 0.1, 0, 90).

WAIT 15.

UNTIL (SHIP:ALTITUDE > 12000) {
	FROM {local x is 25.} UNTIL x = 0 STEP {set x to x-1.} DO {
		set pidInput to VANG(UP:VECTOR, SRFPROGRADE:VECTOR)-45.
		set pitchLock to PID:UPDATE(TIME:SECONDS, pidInput).
	}
	PRINT "Input: " + round(pidInput) + "   Output: " + round(pitchLock).
}

function AscendByProfile{
	parameter trgtApoapsis is 80000.
	local altList is list( 12000, 20000, 40000):ITERATOR.
	local angList is list(45, 65, 90):ITERATOR.
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


ON round(TIME:SECONDS){
	PRINT "G: " + round(GravLoss()) + " D: " + round(DragLoss()) + " S: " + round(SteerLoss()).
	return false.
}

//5608 197
//5646 176
WHEN(SHIP:ALTITUDE > 12000) THEN{
	HUDTEXT("Fuel: " + ROUND(STAGE:LIQUIDFUEL) + " Speed: " + ROUND(SHIP:AIRSPEED), 10, 2, 50, green, true).
	}
//Ascend
AscendByProfile(60000).
	
RiseFromAtmosphere(60000).

CircularizeOrbit().