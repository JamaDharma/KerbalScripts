RUNONCEPATH("0:/lib/Surface").

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
