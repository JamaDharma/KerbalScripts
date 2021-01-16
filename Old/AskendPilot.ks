WAIT 3.

SET SHIP:CONTROL:PILOTMAINTHROTTLE TO 0.
CORE:PART:GETMODULE("kOSProcessor"):DOEVENT("Open Terminal").

set thrustLevel to 1.
set pitchLock to 0.

LOCK  THROTTLE TO thrustLevel.
LOCK STEERING TO HEADING(90, 90 - pitchLock).

STAGE.

CLEARSCREEN.

function SteerTo{
	parameter startAlt.
	parameter startAngle.
	parameter targetAlt.
	parameter targetAngle.
	
	until (SHIP:ALTITUDE > targetAlt or ALT:APOAPSIS > 80000)
	{
		set pitchLock to startAngle + (SHIP:ALTITUDE - startAlt)/(targetAlt - startAlt)*(targetAngle - startAngle).
		WAIT 0.
	}
}

//Ascend
SteerTo(0, 0, 10000, 20).
PRINT "10K passed".
SteerTo(10000, 20, 20000, 60).
PRINT "20K passed".
SteerTo(20000, 60, 40000, 90).
PRINT "40K passed".

LOCK STEERING TO SRFPROGRADE.
until ALT:APOAPSIS > 80000
{
	WAIT 0.
}
set thrustLevel to 0.
PRINT "Ascend burn completed".

//Coast with drag compensation
UNTIL SHIP:ALTITUDE > 70000{
	until ALT:APOAPSIS > 80000
	{
		set thrustLevel to 0.1.
		WAIT 0.
	}
	set thrustLevel to 0.
	WAIT 0.
}

//Coast
LOCK STEERING TO PROGRADE.
WAIT UNTIL SHIP:ALTITUDE > 79500.

//Circularization
set thrustLevel to 1.
until ALT:PERIAPSIS > 70000
{
	WAIT 0.
}