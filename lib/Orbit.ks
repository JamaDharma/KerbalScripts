RUNONCEPATH("0:/lib/Defaults").
RUNONCEPATH("0:/lib/BurnExecutor").

function BurnForPeriapsis{
	parameter desiredPeriapsis.
	
	local rds is Body:radius.
	local aSpeed0 is SQRT(Body:mu*(2/(rds+ALT:APOAPSIS) - 2/(2*rds+ALT:APOAPSIS+ALT:PERIAPSIS))).
	local aSpeed1 is SQRT(Body:mu*(2/(rds+ALT:APOAPSIS) - 2/(2*rds+ALT:APOAPSIS+desiredPeriapsis))).
	local burn is aSpeed1 - aSpeed0.
	
	return burn.
}
local function PeriapsisBurnControl{
	parameter desiredPeriapsis.
	
	local rising is BurnForPeriapsis(desiredPeriapsis)>0.
	return {
		if rising {if ship:ORBIT:PERIAPSIS >= desiredPeriapsis  return -1.}	
		else {if ship:ORBIT:PERIAPSIS <= desiredPeriapsis return -1.}	
		
		return ABS(BurnForPeriapsis(desiredPeriapsis))+0.01.
	}.
}
function SetPeriapsis{
	parameter desiredPeriapsis.
	parameter skipBurn is false.
	
	local burn is BurnForPeriapsis(desiredPeriapsis).
	
	set maneuverNode TO NODE(TIME+ETA:APOAPSIS, 0, 0, burn).
	ADD maneuverNode.
	if skipBurn return.
	
	BurnExecutor(GradeBurnControl(maneuverNode,PeriapsisBurnControl(desiredPeriapsis))).
		
	REMOVE maneuverNode.
}

function BurnForApoapsis{
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
	
	return burn.
}
function ApoapsisBurnControl{
	parameter desiredApoapsis.
	local rising is BurnForApoapsis(desiredApoapsis)>0.
	return {
		if not ship:ORBIT:HASNEXTPATCH {
			if rising {if ship:ORBIT:APOAPSIS >= desiredApoapsis  return -1.}	
			else {if ship:ORBIT:APOAPSIS <= desiredApoapsis return -1.}	
		}
		return ABS(BurnForApoapsis(desiredApoapsis))+0.01.
	}.
}
function SetApoapsis{
	parameter desiredApoapsis.
	parameter skipBurn is false.
		
	local burn is BurnForApoapsis(desiredApoapsis).

	set maneuverNode TO NODE(TIME+ETA:PERIAPSIS, 0, 0, burn).
	ADD maneuverNode.
	if skipBurn return.
	
	BurnExecutor(GradeBurnControl(maneuverNode,ApoapsisBurnControl(desiredApoapsis))).
	
	REMOVE maneuverNode.
}

function SetPeriodByApoapsis{
	parameter desiredPeriod.
	parameter skipBurn is false.
		
	local sma is (BODY:MU*desiredPeriod^2/4/CONSTANT:PI^2)^(1/3).
	local ap is sma - BODY:RADIUS + (sma - BODY:RADIUS - ship:ORBIT:PERIAPSIS).
	print "Setting apoapsis to " + ap.
	
	SetApoapsis(ap,skipBurn).
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