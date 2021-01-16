RUNONCEPATH("0:/lib/Defaults").

function AscendByProfile{
	parameter trgtApoapsis, pitchSetter.
	parameter altList is list( 0,	160,243,518,1054,1722,3638,6470,10460,16052,24335,39955).
	parameter angList is list(0,		1,2,5,10,15,25,35,45,55,65,75).
	local altIterator is altList:ITERATOR.
	local angIterator is angList:ITERATOR.
	altIterator:NEXT.
	angIterator:NEXT.
	
	SteerTo(trgtApoapsis, pitchSetter@, altIterator, angIterator).
}

function SteerTo{
	parameter trgtApoapsis, pitchSetter.
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
		pitchSetter@:call(startAngle + (SHIP:ALTITUDE - startAlt)/(targetAlt - startAlt)*(targetAngle - startAngle)).
		WAIT 0.
	}
	PRINT targetAlt + " passed".
	SteerTo(trgtApoapsis, pitchSetter@, startAltPointer, startAnglePointer).
}

function RiseApoapsis{
	parameter desiredApoapsis.
	HUDTEXT("Rising apoapsis.", 5, 2, 50, green, true).
	LOCK STEERING TO SRFPROGRADE.
	WAIT UNTIL ALT:APOAPSIS > desiredApoapsis.
	set thrustLevel to 0.
}

function Coast{
	parameter desiredApoapsis.

	HUDTEXT("Coasting out of the atmosphere.", 5, 2, 50, green, true).

	//Coast with drag compensation
	UNTIL SHIP:ALTITUDE > BODY:ATM:HEIGHT {
		UNTIL ALT:APOAPSIS > desiredApoapsis
		{
			set thrustLevel to 0.1.
			WAIT 0.1.
		}
		set thrustLevel to 0.
		WAIT 0.1.
	}
	HUDTEXT("Space.", 5, 2, 50, green, true).
}

function RiseFromAtmosphere{
	parameter desiredApoapsis is 80000.
	RiseApoapsis(desiredApoapsis).
	SET WARPMODE TO "PHYSICS".
	SET WARP TO 3.
	Coast(desiredApoapsis).
	SET WARP TO 0.
	SET WARPMODE TO "RAILS".
}