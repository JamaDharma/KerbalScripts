switch to 0.
RUNONCEPATH("Unwieldy").
RUNONCEPATH("Ascend").
RUNONCEPATH("Orbit").

set thrustLevel to 1.
set pitchLock to 0.
LOCK STEERING TO HEADING(90, 90 - pitchLock).
//780

function AscendByProfile{
	parameter trgtApoapsis is 800000.
	local altList is list( 0,		958,1291,2022,3000,3907,5749,7724,9974):ITERATOR.
	local angList is list(0,		1,2,5,10,15,25,35,45):ITERATOR.
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

local apo is 80000.
STAGE.

//Ascend
AscendByProfile(apo).
LOCK STEERING TO SHIP:PROGRADE.
SAS ON.
SET SASMODE TO PROGRADE.
SET SHIP:CONTROL:PILOTMAINTHROTTLE TO 1.
WAIT 10.