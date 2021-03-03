RUNONCEPATH("0:/lib/Debug").
RUNONCEPATH("0:/lib/Ship/Engines").
RUNONCEPATH("0:/lib/Search/BinarySearch").
RUNONCEPATH("0:/lib/GravityTurnSimulation").

function CalculateAscentProfile{
	parameter tAlt is 10000.
	
	local engLst is ListStageEngines(stage:NUMBER-1).

	local gts is MakeGravTSim(EnginesConsumption(engLst),EnginesThrust(engLst)).	
	
	function SpeedCheck{
		parameter spd.
		
		return {
			parameter vx,vz,cml.
			return vz > spd.
		}.
	}	
	local startAng is 10.
	local startState is gts:VelAng(SpeedCheck(100),0.1,1,90).
	local startSpd is startState["VZ"].
	local startTime is startState["T"].
	local startHeight is startState["Z"].
	NPrintL(lexicon("Start speed",startSpd,"time",startTime,"height",startHeight)).
	
	
	function Check {
		parameter vx,vz,cml.
		if vx >= vz return true.
		return cml[2] > tAlt.
	}
	function Metric{
		PRINT "Trying angle:" + startAng.
		if startAng < 0 return 1.
		if startAng > 30 return -1.
		local result is gts:VelAng(Check@,1,startSpd,90-startAng,
			list(startTime,0,startHeight)).
		if result["VX"] < result["VZ"] {
			PRINT "Too steep".
			return -1.
		}
		PRINT "45 at " +result["Z"].
		return tAlt-result["Z"].
	}
	set startAng to startAng + BSearch(Metric@,MakeSearchComponent( 
		1, 1/32, {parameter dA. set startAng to startAng + dA.})).
	NPrint("Final angle",startAng).
	
	local endState is gts:VelAng(SpeedCheck(200),1,startSpd,90-startAng,
		list(startTime,0,startHeight)).
	
	local points is list(5,10,15,20,30,40,50,65,80,100,125,150,175,200).
	local itr is points:REVERSEITERATOR.
	itr:NEXT().
	local profile is stack().
	
	function ProfileHarvester{
		parameter vx,vz,cml.
		if vx*vx + vz*vz <= itr:VALUE*itr:VALUE {
			profile:PUSH(list(SQRT(vx*vx + vz*vz),ARCTAN2(vx,vz))).
			return not itr:NEXT().
		}
		
		return false.
	}
	gts["State"](ProfileHarvester@,-0.1,endState).
	profile:PUSH(list(0,0)).
	return profile.
}