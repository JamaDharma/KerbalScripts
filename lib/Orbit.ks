RUNONCEPATH("0:/lib/Defaults").
RUNONCEPATH("0:/lib/BurnExecutor").

function SetPeriapsis{
	parameter desiredPeriapsis.
	
	local rds is Body:radius.
	local aSpeed0 is SQRT(Body:mu*(2/(rds+ALT:APOAPSIS) - 2/(2*rds+ALT:APOAPSIS+ALT:PERIAPSIS))).
	local aSpeed1 is SQRT(Body:mu*(2/(rds+ALT:APOAPSIS) - 2/(2*rds+ALT:APOAPSIS+desiredPeriapsis))).
	local burn is aSpeed1 - aSpeed0.
	
	set maneuverNode TO NODE(TIME:SECONDS+ETA:APOAPSIS, 0, 0, burn).
	ADD maneuverNode.
	ExecuteBurn(maneuverNode).
	REMOVE maneuverNode.
}

function SetApoapsis{
	parameter desiredApoapsis.

	local bRds is Body:radius.
	
	local cV is VELOCITY:ORBIT:MAG.
	local cAlt is bRds + ALTITUDE.
	local pAlt is bRds + ALT:PERIAPSIS.
	local dAAlt is bRds + desiredApoapsis.
	local dSMA is (pAlt + dAAlt)/2.

	local v0 is SQRT(cV^2 + 2*Body:mu*(1/pAlt - 1/cAlt)).
	local v1 is SQRT(Body:mu*(2/pAlt - 1/dSMA)).
	local burn is v1 - v0.
	
	HUDTEXT("v0: "+ ROUND(v0), 5, 2, 50, red, true).
	
	set maneuverNode TO NODE(TIME:SECONDS+ETA:PERIAPSIS, 0, 0, burn).
	ADD maneuverNode.
	ExecuteBurn(maneuverNode).
	REMOVE maneuverNode.
}

function ExecuteBurn{
	parameter burn.
	
	BurnExecutor(NodeBurnControl(burn)).
}

function ManeuverInAP{
	parameter dA.
	parameter dP.
	IF ETA:PERIAPSIS > ETA:APOAPSIS AND ETA:APOAPSIS > 10 {
		SetPeriapsis(dP).
	} ELSE {
		SetApoapsis(dA).
	}
}

function CircularizeOrbit{
	ManeuverInAP(ALT:PERIAPSIS + 500, ALT:APOAPSIS - 500).
	HUDTEXT("Circular orbit.", 5, 2, 50, green, true).
}

function StabilizeOrbit{
	ManeuverInAP(Body:RADIUS*5, Body:ATM:HEIGHT + 2500).
	HUDTEXT("Stable orbit.", 5, 2, 50, green, true).
}