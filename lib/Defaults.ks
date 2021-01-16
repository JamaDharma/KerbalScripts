SET SHIP:CONTROL:PILOTMAINTHROTTLE TO 0.

set thrustLevel to 0.
LOCK  THROTTLE TO thrustLevel.

function SetThrust{
	parameter t.
	set thrustLevel to t.
}

function FreeControlLock{
	SET SHIP:CONTROL:NEUTRALIZE to TRUE.
	UNLOCK THROTTLE.
}