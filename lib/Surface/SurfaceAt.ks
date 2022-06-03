RUNONCEPATH("0:/lib/Surface/Surface").

LOCAL rotationalDir IS VDOT(SHIP:BODY:NORTH:FOREVECTOR,SHIP:BODY:ANGULARVEL). //the number of radians the body will rotate in one second
FUNCTION ground_track {  //returns the geocoordinates of the ship at a given time(UTs) adjusting for planetary rotation over time
  PARAMETER posTime,pos.
  LOCAL localBody IS SHIP:BODY.
  LOCAL posLATLNG IS localBody:GEOPOSITIONOF(pos).
  LOCAL timeDif IS posTime - TIME:SECONDS.
  LOCAL longitudeShift IS rotationalDir * timeDif * CONSTANT:RADTODEG.
  LOCAL newLNG IS MOD(posLATLNG:LNG + longitudeShift ,360).
  IF newLNG < - 180 { SET newLNG TO newLNG + 360. }
  IF newLNG > 180 { SET newLNG TO newLNG - 360. }
  RETURN LATLNG(posLATLNG:LAT,newLNG).
}

function BodyPositionAt {  //returns the new position of point  at a given time(UTs) due to planetary rotation over time
  parameter pos,posTime.
  LOCAL localBody IS SHIP:BODY.
  LOCAL posLATLNG IS localBody:GEOPOSITIONOF(pos).
  LOCAL timeDif IS posTime - TIME:SECONDS.
  LOCAL longitudeShift IS rotationalDir * timeDif:SECONDS * CONSTANT:RADTODEG.
  LOCAL newLNG IS MOD(posLATLNG:LNG + longitudeShift ,360).
  IF newLNG < - 180 { SET newLNG TO newLNG + 360. }
  IF newLNG > 180 { SET newLNG TO newLNG - 360. }
  RETURN LATLNG(posLATLNG:LAT,newLNG):POSITION.
}

function GeopositionAt{
	PARAMETER obj, objTime.
	return ground_track(objTime:SECONDS, positionAt(obj, objTime)).
}

function AltitudeAt{
	parameter t.
	local p is POSITIONAT(ship, t).
	local bp is BODY:POSITION.
	return (p-bp):MAG-BODY:RADIUS.
}

function HorVelAt{
	parameter t.
	local p is POSITIONAT(ship, t).
	local vel is VelocityAt(ship, t).
	local upV is (p - ship:BODY:POSITION).
	return list(VXCL(upV,vel:ORBIT),VXCL(upV,vel:SURFACE)).
}

function NewSurfaceAtCalculator{
	parameter shipBody is ship:BODY.
	
	local bodyRadius is shipBody:RADIUS.
	local bodyAngVelDEG is 360/shipBody:ROTATIONPERIOD.
	local distPerDeg is constant:DegToRad*bodyRadius.

	local function SurfacePositionAt{
		parameter pos.
		parameter t.
		local bp is shipBody:POSITION.
		return AngleAxis(bodyAngVelDEG*t,shipBody:ANGULARVEL)*(pos-bp)+bp.
	}
	//distance along sea level between projections
	local function GlobeDistanceP{
		parameter pos1,pos2.
		local bp is shipBody:POSITION.
		return distPerDeg*VANG(pos1-bp,pos2-bp).
	}
	//distance from position to set surface target at set time
	local function MakeDistToTimeTargetCalculator{
		parameter tOnTgt.
		parameter tgt.
		
		return { parameter pos.
			local bp is shipBody:POSITION.
			local rot is AngleAxis(
				bodyAngVelDEG*(tOnTgt-TIME):SECONDS,
				shipBody:ANGULARVEL).
			return distPerDeg*VANG(pos-bp,rot*(tgt:POSITION-bp)).
		}.
	}
	
	return lexicon(
		"MakeDistToTimeTargetCalculator", MakeDistToTimeTargetCalculator@
	).
}