RUNONCEPATH("0:/lib/Debug").
RUNONCEPATH("0:/lib/Ship/Engines").

local function CoMH{
	return ALT:RADAR-UP:VECTOR*SHIP:ROOTPART:POSITION.
}
local function FinalOrientation{
	local ld is VXCL(UP:VECTOR,ship:FACING:VECTOR-ship:FACING:UPVECTOR).
	return LOOKDIRUP(ld, UP:VECTOR).
}
local function EnergySurplus{
	local gE is (CoMH()-fh)*grv*MASS.
	local kE is AIRSPEED*AIRSPEED*MASS/2.
	local rE is ABS(ANGULARMOMENTUM*ANGULARVEL/2).
	local s is gE + kE + rE.
	//NPrintL(lexicon("s",s,"gE",gE,"kE",kE,"rE",rE)).
	return s.
}

local function MakeThrustControl{
	local startBracking is false.
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
		local linSpd is -ship:FACING:UPVECTOR*ship:VELOCITY:SURFACE.
		local engSpd is rotSpd+linSpd.
		if true NPrintL(lexicon(
			"energy",energy,
			"rotSpd",rotSpd,
			"linSpd",linSpd,
			"engSpd",engSpd)).

		if engSpd < 1 return 0.
		
		local stopTime is energy*2/(engSpd*engThrust).
		local ang is (90-VANG(UP:VECTOR, ship:FACING:VECTOR))*CONSTANT:DegToRad.
		local horTime is ang*2/ANGULARVEL:MAG.
		
		if stopTime*4 >= horTime*3 set startBracking to true.
		
		if startBracking return stopTime/horTime.
		return 0.
	}.
}

SET SHIP:CONTROL:PILOTMAINTHROTTLE TO 0.
BRAKES ON.

STAGE.
WAIT 0.

local bounds_box is ship:bounds.
local btm is -ship:FACING:UPVECTOR.
local fH is bounds_box:FURTHESTCORNER(btm)*btm.
local grv is BODY:MU/BODY:RADIUS^2.

local str is FinalOrientation().
LOCK STEERING to str.

local ed is EnergySurplus().
local tc is MakeThrustControl().
UNTIL AIRSPEED < 1 and (90-VANG(UP:VECTOR, ship:FACING:VECTOR)) < 10 {
	set ed to EnergySurplus().
	SET SHIP:CONTROL:PILOTMAINTHROTTLE TO tc(ed).
	PRINT SHIP:CONTROL:PILOTMAINTHROTTLE.
	WAIT 0.
}
SET SHIP:CONTROL:PILOTMAINTHROTTLE TO 0.
