RUNONCEPATH("0:/lib/Debug").
RUNONCEPATH("0:/lib/Targeting").
RUNONCEPATH("0:/lib/SurfaceAt").
RUNONCEPATH("0:/lib/Math/Rotations").
RUNONCEPATH("0:/lib/Search/TragectoryImpactSearch").

local function MakeManeuver{//does not work
	parameter bVec.
	local pg is ship:VELOCITY:ORBIT:NORMALIZED.
	local nm is VCRS(pg,UP:VECTOR):NORMALIZED.
	local rd is VCRS(nm,pg).
	return NODE(time,bVec*rd,bVec*nm,bVec*pg).
}
local function IdealDV{
	parameter ang.
	local sa is SIN(ang).
	return SQRT(2*BODY:MU*sa/(BODY:RADIUS*(1+sa))).
}
local function IdealTime{
	parameter ang.
	local sa is SIN(ang).
	local ca is COS(ang).
	
	local m1 is ((1+sa)/2)^(3/2).
	local m2 is ARCSIN(SQRT(2*sa/(1+sa)))*CONSTANT:DegToRad.
	local s1 is ca*SQRT(sa)/2.
	local k1 is 2*SQRT(BODY:RADIUS^3/BODY:MU).
	
 	return k1*(s1 + m1*m2).
}
function MakeSteeringControl{
	parameter tgt.
	local tgtAlt is tgt:TERRAINHEIGHT.
	
	local br is body:radius.
	local bg is body:mu/body:radius^2.//body gravity
	local bov is SQRT(body:mu/body:radius).//orbtal velocity for body
	
	local ite is time+FlightTimeEstimate().//impact time estimate (low!)
	
	local this is lexicon(
		"UpdateSteering", StartingSteering@
	).
	
	local function FlightTimeEstimate{
		local tV is (tgt:ALTITUDEPOSITION(tgtAlt)-BODY:POSITION):NORMALIZED.
		local ang is VANG(tV, UP:VECTOR)/2.
		NPrint("Globe angle",ang*2).
		local dv is IdealDV(ang).
		NPrint("Ideal delta-v",dv).
		local t is IdealTime(ang).
		NPrint("Estimated flight time",t).
		return t.
	}
	local function SteeringByGrav{
		parameter posVec.
		
		local upv is UP:VECTOR.
		
		local desiredAcc is (posVec:NORMALIZED+upv):NORMALIZED.
		local twr is MAXTHRUST/(bg*MASS).
		local sinA is upv*desiredAcc.
		
		local mlt is SQRT(twr*twr+sinA*sinA-1) - sinA.
		return desiredAcc*mlt+upv.
	}
	//steering mode functions
	local function StartingSteering{
		parameter impactTime, impErrV.
		if impactTime > ite {
			set this["UpdateSteering"] to TuneSteering@.
			PRINT "Switching to TuneSteering mode".
		}
		local tgtP is BodyPositionAt(tgt:ALTITUDEPOSITION(tgtAlt), ite).
		return SteeringByGrav(tgtP).
	}
	local function TuneSteering{
		parameter impactTime, impErrV.
		local tUp is tgt:ALTITUDEPOSITION(tgtAlt) - BODY:POSITION.
		local rot is MakeFromToRot(tUp,SRFPROGRADE:TOPVECTOR).
		return rot*impErrV.
	}
	return this.
}
function MakeImpactControl{
	parameter tgt, draw is false.
	local tgtAlt is tgt:TERRAINHEIGHT.
	local impactTime is TragectoryAltitudeTime(tgtAlt).
	local impErrV is ImpactErrorVector().
	local steerControl is MakeSteeringControl(tgt).
	local steerV is steerControl:UpdateSteering(impactTime,impErrV).
	
	local function ImpactErrorVector{
		local impP is GeopositionAt(ship,impactTime):ALTITUDEPOSITION(tgtAlt).
		local tgtP is tgt:ALTITUDEPOSITION(tgtAlt).
		local errV is tgtP-impP.
		return errV.
	}
	
	local function BurnLeft{
		return impErrV:MAG/(impactTime-time):seconds/4.
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
		if (impactTime-time)<10 set impactTime to time+10.
		set impErrV to ImpactErrorVector().
		set steerV to steerControl:UpdateSteering(impactTime,impErrV).
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
	set SHIP:CONTROL:PILOTMAINTHROTTLE to 1.
	
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