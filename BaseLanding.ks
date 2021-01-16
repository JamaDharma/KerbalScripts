RUNONCEPATH("0:/lib/Landing").
RUNONCEPATH("0:/lib/Unwieldy").

parameter landingSpeed is 5.

set STEERINGMANAGER:ROLLCONTROLANGLERANGE to 5.
set STEERINGMANAGER:ROLLPID:KD to 10.
SET SHIP:CONTROL:PILOTMAINTHROTTLE TO 0.
SAS OFF.

local thrustLevel is 0.
function SetThrust{
	parameter t.
	set thrustLevel to t.
}

LOCK  THROTTLE TO thrustLevel.
local roofDir is VCRS(UP:VECTOR, SRFRETROGRADE:VECTOR).
LOCK  STEERING TO LookDirUp(SRFRETROGRADE:VECTOR,roofDir).

//DoubleBurn(1.5,200,landingSpeed,SetThrust@).
ImpactBurn(landingSpeed,SetThrust@).

LOCK  STEERING TO UP.
WAIT 5.
SAS ON.
