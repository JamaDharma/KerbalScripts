RUNONCEPATH("0:/lib/Defaults").
RUNONCEPATH("0:/lib/Landing/Landing").

parameter landingSpeed is 1.

SAS OFF.
GEAR ON.
BRAKES ON.

LOCK  STEERING TO SRFRETROGRADE.
WHEN AIRSPEED < 10 THEN{
	local str is SRFRETROGRADE.
	LOCK  STEERING TO str.
}
local ang is VANG(UP:VECTOR, SRFRETROGRADE:VECTOR).
if ang>60{
	OImpactBurn(landingSpeed,SetThrust@).
} else {
	ImpactBurn(landingSpeed,SetThrust@).
}
SAS ON.
