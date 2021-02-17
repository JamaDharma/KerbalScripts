RUNONCEPATH("0:/lib/Targeting").
RUNONCEPATH("0:/lib/SurfaceAt").
RUNONCEPATH("0:/lib/Search/TragectoryImpactSearch").

function MakeImpactControl{
	parameter tgt.
	local impactTime is TragectoryImpactTime().
	local impErrV is ImpactErrorVector().
	
	local function ImpactErrorVector{
		local impP is GeopositionAt(ship,impactTime):POSITION.
		local tgtP is tgt:POSITION.
		local errV is tgtP-impP.
		return errV.
	}
	
	local function SteeringVector{
		if impErrV:MAG < tgt:DISTANCE/64
			return VXCL(UP:VECTOR,impErrV).
		return impErrV:NORMALIZED + UP:VECTOR.
	}
	
	local function BurnLeft{
		return impErrV:MAG/(impactTime-time):seconds/4.
	}
	
	local function UpdateImpactState{
		set impactTime to TragectoryImpactTime(impactTime).
		if (impactTime-time)<10 set impactTime to time+10.
		set impErrV to ImpactErrorVector().
		return ship:FACING:VECTOR*SteeringVector() <= 0.
	}
	
	return lexicon(
		"StateControl", UpdateImpactState@,
		"SteerControl", SteeringVector@,
		"ErrorVector", { return impErrV.},
		"BurnLeft", BurnLeft@
	).
}


local function BurnControl{
	parameter tgt.
	local steeringLock is HEADING(tgt:HEADING,45):VECTOR.
	set SHIP:CONTROL:PILOTMAINTHROTTLE to 1.
	SAS OFF.
	LOCK STEERING TO steeringLock.
	WAIT UNTIL VERTICALSPEED > 10.
	
	local impactControl is MakeImpactControl(tgt).
	
	WAIT UNTIL VANG(steeringLock, SHIP:FACING:VECTOR) < 15.
	
	until impactControl:StateControl() {
		set steeringLock to  impactControl:SteerControl().
		set SHIP:CONTROL:PILOTMAINTHROTTLE to 
			impactControl:BurnLeft()*MASS/MAXTHRUST.
		WAIT 0.
	}
	
	set SHIP:CONTROL:PILOTMAINTHROTTLE to 0.
	impactControl:StateControl().
	PRINT "Expected error: " + impactControl:ErrorVector():MAG.

	UNLOCK STEERING.
}

parameter lat is 0, lng is 0.
if lat<>0 and lng<>0{
	BurnControl(BODY:GEOPOSITIONLATLNG(lat,lng)).
}else {
	BurnControl(GetTargetGeo()).
}