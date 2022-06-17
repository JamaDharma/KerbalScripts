//makes craft impact point close to launchpad
RUNONCEPATH("0:/lib/Debug").
RUNONCEPATH("0:/lib/Targeting").
RUNONCEPATH("0:/lib/Surface/SurfaceAt").
RUNONCEPATH("0:/lib/Math/Rotations").
RUNONCEPATH("0:/lib/Search/TragectoryImpactSearch").

function MakeImpactControl{
	parameter tgt, draw is false.
	local tgtAlt is tgt:TERRAINHEIGHT.
	local impactTime is TragectoryAltitudeTime(tgtAlt).
	local impErrV is ImpactErrorVector().
    local steerV is VXCL(UP:VECTOR,impErrV).
	
	local function ImpactErrorVector{
		local impP is GeopositionAt(ship,impactTime):ALTITUDEPOSITION(tgtAlt).
		local tgtP is tgt:ALTITUDEPOSITION(tgtAlt).
		local errV is tgtP-impP.
		return errV.
	}
	
	local function BurnLeft{//why 4? prob hack
		return impErrV:MAG/(impactTime-time):seconds.
	}

	set drawSteer to VECDRAW(
		V(0,0,0),
		{ return steerV:NORMALIZED*50. },
		GREEN,"",0.5,draw).
	set drawErr to VECDRAW(
		V(0,0,0),
		{ return impErrV. },
		RED,"",0.5,draw).
	local function UpdateImpactState{
		set impactTime to TragectoryAltitudeTime(tgtAlt,impactTime).
		set impErrV to ImpactErrorVector().
		set steerV to VXCL(UP:VECTOR,impErrV).
		return ship:FACING:VECTOR*steerV <= 0.
	}
	
	return lexicon(
		"StateControl", UpdateImpactState@,
		"SteerControl", { return steerV.},
		"ErrorVector", { return impErrV.},
		"BurnLeft", BurnLeft@
	).
}

local function BurnControl{
	parameter tgt.
	local impactControl is MakeImpactControl(tgt).
	local steeringLock is impactControl:SteerControl().
	SAS OFF.
	LOCK STEERING TO steeringLock.
	set SHIP:CONTROL:PILOTMAINTHROTTLE to 0.
	WAIT UNTIL VANG(steeringLock,SHIP:FACING:VECTOR) < 1.
	until impactControl:StateControl() {
		set steeringLock to  impactControl:SteerControl().
		set SHIP:CONTROL:PILOTMAINTHROTTLE to 
			impactControl:BurnLeft()*MASS/MAXTHRUST+0.001.
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