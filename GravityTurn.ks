RUNONCEPATH("0:/lib/Defaults").
RUNONCEPATH("0:/lib/Debug").
RUNONCEPATH("0:/lib/Orbit").
RUNONCEPATH("0:/lib/Ship/Engines").
RUNONCEPATH("0:/lib/Search/GoldenSearch").
RUNONCEPATH("0:/lib/Search/BinarySearch").
RUNONCEPATH("0:/lib/GravityTurnSimulation").

function ProgradePitch{
	return VANG(UP:VECTOR,SRFPROGRADE:VECTOR).
}
function TurnAngle100{
	parameter tAlt is 10000.
	local ang100 is 10.
	local engLst is ListStageEngines(stage:NUMBER-1).
	local gts is MakeGravTSim(Check@,engLst,-EnginesThrust(engLst)).	
	
	function Check {
		parameter vx,vz,cml.
		if vx < vz return true.
		return -cml[2] > tAlt.
	}
	
	local count is 0.
	function Metric{
		PRINT "Trying angle:" + ang100.
		if ang100 < 0 return 1.
		set count to count+1.
		local result is gts(1,100,-90-ang100).
		if result["VX"] > result["VZ"] {
			PRINT "Too steep".
			return -1.
		}
		PRINT "45 at " +(-result["Z"]).
		return tAlt+result["Z"].
	}
	
	BSearch(	Metric@,
		MakeSearchComponent( 1, 1/32, {parameter dA. set ang100 to ang100 + dA.})).
	print count.
	return ang100.
}



set pitchLock to 0.
CORE:PART:CONTROLFROM().
//10000 283
//8000 328
//6000 388
//5000 413
//4000 454 - but partial burnup 
local tAng is TurnAngle100(5000).

WaitKey().

set thrustLevel to 1.
LOCK STEERING TO HEADING(90, 90 - pitchLock).

STAGE.

UNTIL AIRSPEED > 100 {
	set pitchLock to tAng*AIRSPEED/100.
	WAIT 0.
}
UNTIL ALT:APOAPSIS > 75000 {
	set pitchLock to ProgradePitch().
	WAIT 0.
}
set thrustLevel to 0.
SAS ON.
WAIT 1.
set SASMODE to "PROGRADE".
SetPeriapsis(71000,true).
WAIT 1.