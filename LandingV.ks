parameter landingSpeed is 1.

SET SHIP:CONTROL:PILOTMAINTHROTTLE TO 0.
SAS OFF.
GEAR ON.
BRAKES ON.

RUNONCEPATH("0:/lib/Landing").

local thrustLevel is 0.
function SetThrust{
	parameter t.
	set thrustLevel to t.
}

LOCK  THROTTLE TO thrustLevel.
LOCK  STEERING TO SRFRETROGRADE.

//DoubleBurn(1.5,200,landingSpeed,SetThrust@).
ImpactBurn(landingSpeed,SetThrust@).

LOCK  STEERING TO UP.
WAIT 5.
SAS ON.
