parameter landingSpeed is 1.
parameter margin is 4.

SET SHIP:CONTROL:PILOTMAINTHROTTLE TO 0.
SAS OFF.
GEAR ON.
BRAKES ON.

RUNONCEPATH("0:/lib/Landing/Landing").

local thrustLevel is 0.
function SetThrust{
	parameter t.
	set thrustLevel to t.
}

LOCK  THROTTLE TO thrustLevel.
LOCK  STEERING TO SRFRETROGRADE.
SetUpTrigger(1).

OImpactBurn(landingSpeed,SetThrust@,{RETURN RealAltitude()-margin.}).

LOCK  STEERING TO UP.
WAIT 5.
SAS ON.
