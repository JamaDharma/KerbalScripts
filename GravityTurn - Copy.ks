switch to 0.
RUNONCEPATH("0:/lib/Unwieldy").
RUNONCEPATH("0:/lib/Ascend").
RUNONCEPATH("0:/lib/Orbit").

set thrustLevel to 1.
set pitchLock to 0.
LOCK STEERING TO HEADING(90, 90 - pitchLock).
//780

function AscendByProfile{
	parameter trgtApoapsis is 80000.
	//local altList is list( 0,	160,243,518,1054,1722,3638,6470,10460,16052,24335,39955):ITERATOR.
	//local angList is list(0,		1,2,5,10,15,25,35,45,55,65,75):ITERATOR.
	local altList is list( 0,	87,100,168,370,681,1677,3314,5899,10173,19364,40000):ITERATOR.
	local angList is list(0,		1,2,5,10,15,25,35,45,55,65,70):ITERATOR.	

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

RiseFromAtmosphere(apo).

if (ALT:PERIAPSIS < 70000) { CircularizeOrbit(). }