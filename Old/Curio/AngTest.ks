RUNONCEPATH("0:/lib/Debug").
RUNONCEPATH("0:/lib/Ship/Engines").

local function Energy{
	local rW is ANGULARVEL.
	local rM is ANGULARMOMENTUM.
	local rE is ABS(ANGULARMOMENTUM*ANGULARVEL/2).
	NPrintL(lexicon("rW",rW:MAG,"rM",rM:MAG,"rE",rE)).
}

local function MakeThrustControl{
	parameter timeFactor is 4. //aiming to finishing burn in 1/timeFactor seconds
	local engArm is 0.
	local engThrust is 0.
	for eng in ListActiveEngines(){
		local et is ship:FACING:UPVECTOR*eng:FACING:VECTOR*eng:MAXTHRUST.
		set engArm to engArm + ship:FACING:VECTOR*eng:POSITION*et.
		set engThrust to engThrust + et.
	}
	set engArm to engArm/engThrust.
	NPrint("engArm",engArm).
	NPrint("engThrust",engThrust).
	NPrint("Momentum",engArm*engThrust).

}

SET SHIP:CONTROL:PILOTMAINTHROTTLE TO 0.
STAGE.
//SAS ON.
WAIT 0.5.

Energy().
MakeThrustControl().
WAIT 0.
local et is time+1.
SET SHIP:CONTROL:PILOTMAINTHROTTLE TO 1.
wait until et<time.
SET SHIP:CONTROL:PILOTMAINTHROTTLE TO 0.
Energy().