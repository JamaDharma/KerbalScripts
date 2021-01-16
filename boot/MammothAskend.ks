WAIT 3.

SET SHIP:CONTROL:PILOTMAINTHROTTLE TO 1.

set thrustLevel to 1.
set pitchLock to 1.

LOCK  THROTTLE TO thrustLevel.
LOCK STEERING TO HEADING(90, 90 - pitchLock).

STAGE.

CLEARSCREEN.

function AscendByProfile{
	parameter trgtApoapsis is 80000.
	local altList is list(0, 3000, 10000, 20000, 40000):ITERATOR.
	local angList is list(1,   20,    45,    60,    80):ITERATOR.
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

//Ascend
AscendByProfile(80000).

PRINT "Finalising ascend".
LOCK STEERING TO SRFPROGRADE.
until ALT:APOAPSIS > 80000
{
	WAIT 0.
}
set thrustLevel to 0.
PRINT "Ascend burn completed".

//Coast with drag compensation
SET SHIP:CONTROL:PILOTMAINTHROTTLE TO 0.
UNTIL SHIP:ALTITUDE > 70000{
	UNTIL ALT:APOAPSIS > 80000
	{
		set thrustLevel to 0.1.
		WAIT 0.
	}
	set thrustLevel to 0.
	WAIT 0.
}

//Circularization

set circularization TO NODE(TIME:SECONDS+ETA:APOAPSIS, 0, 0, 1).
ADD circularization.
LOCK STEERING TO circularization:DELTAV.

UNTIL (circularization:ORBIT:APOAPSIS - circularization:ORBIT:PERIAPSIS) < 1000 {
	SET circularization:PROGRADE to circularization:PROGRADE + 1.
}

LOCK STEERING TO circularization:DELTAV.
local dv is circularization:DELTAV:MAG.
local butnTime is dv*MASS/MAXTHRUST.

WAIT circularization:ETA - butnTime/2.

set thrustLevel to 1.
WAIT UNTIL ALT:PERIAPSIS > 70000.

set thrustLevel to 0.
REMOVE circularization.