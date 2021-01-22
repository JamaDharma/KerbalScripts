RUNONCEPATH("0:/lib/Defaults").
RUNONCEPATH("0:/lib/Landing").

parameter landingSpeed is 1.

GEAR ON.
BRAKES ON.

LOCK  STEERING TO SRFRETROGRADE.

//DoubleBurn(1.5,200,landingSpeed,SetThrust@).
ImpactBurn(landingSpeed,SetThrust@).

LOCK  STEERING TO UP.
WAIT 5.
SAS ON.
