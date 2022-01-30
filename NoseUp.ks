RUNONCEPATH("0:/lib/Debug").
RUNONCEPATH("0:/lib/Ship/Engines").
local bounds_box is ship:bounds.
local bkv is -ship:FACING:VECTOR.
local bkvH is bounds_box:FURTHESTCORNER(bkv)*bkv.
local btm is -ship:FACING:UPVECTOR.
local btmH is bounds_box:FURTHESTCORNER(btm)*btm.
local fH is SQRT(bkvH*bkvH+btmH*btmH).
local grv is BODY:MU/BODY:RADIUS^2.

local function CoMH{
	return ALT:RADAR-UP:VECTOR*SHIP:ROOTPART:POSITION.
}

local function EnergyDeficit{
	local energyReq is (fH - CoMH())*grv*MASS.
	local kE is AIRSPEED*AIRSPEED*MASS/2.
	local rE is ABS(ANGULARMOMENTUM:MAG*ANGULARVEL:MAG/2).
	local d is energyReq - kE - rE.
	NPrintL(lexicon("d",d,"energyReq",energyReq,"kE",kE,"rE",rE)).
	return d.
}

local function MakeThrustControl{
	parameter timeFactor is 16. //aiming to finishing burn in 1/timeFactor seconds
	local engArm is 0.
	local engThrust is 0.
	for eng in ListActiveEngines(){
		local et is ship:FACING:UPVECTOR*eng:FACING:VECTOR*eng:MAXTHRUST.
		set engArm to engArm + ship:FACING:VECTOR*eng:POSITION*et.
		set engThrust to engThrust + et.
	}
	set engArm to engArm/engThrust.
	
	return {
		parameter energy.
		local rotSpd is ANGULARVEL:MAG*engArm.
		local linSpd is ship:FACING:UPVECTOR*ship:VELOCITY:SURFACE.
		local engSpd is rotSpd+linSpd.
		if false NPrintL(lexicon(
			"energy",energy,"rotSpd",rotSpd,"linSpd",linSpd,"engSpd",engSpd)).
		if engSpd < 0.1 return energy.	
		return energy*timeFactor/(engSpd*engThrust).
	}.
}

SET SHIP:CONTROL:PILOTMAINTHROTTLE TO 0.
BRAKES ON.
AG2 ON.

local ed is EnergyDeficit().
local tc is MakeThrustControl().
UNTIL  ed <= 0 {
	set ed to EnergyDeficit().
	SET SHIP:CONTROL:PILOTMAINTHROTTLE TO tc(ed)+0.01.
	WAIT 0.
}
SET SHIP:CONTROL:PILOTMAINTHROTTLE TO 0.

WAIT UNTIL VANG(ship:FACING:VECTOR,UP:VECTOR) < 30.
SAS ON.
WAIT 0.1.
set SASMODE to "RADIALOUT".

