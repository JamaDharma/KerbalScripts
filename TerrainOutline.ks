function DrawAxes {

	set drawRoll to VECDRAW(
		V(0,0,0),
		{ return (ship:FACING:STARVECTOR)*5. },
		WHITE,"",0.5,true).
	set drawPitch to VECDRAW(
		V(0,0,0),
		{ return (ship:FACING:FOREVECTOR)*15. },
		WHITE,"",0.5,true).
		
	set drawPitchSteer to VECDRAW(
		V(0,0,0),
		{ return (steerLock:FOREVECTOR)*15. },
		RED,"",0.5,true).
		
	set drawRollSteer to VECDRAW(
		V(0,0,0),
		{ return (steerLock:STARVECTOR)*5. },
		RED,"",0.5,true).	
		
	set drawPV to VECDRAW(
		V(0,0,0),
		{ return (VXCL(GetUpVec(SHIP),SHIP:FACING:FOREVECTOR):NORMALIZED)*7. },
		BLUE,"",1,true).
	set drawRV to VECDRAW(
		V(0,0,0),
		{ return (SurfacePitchVector(ship)). },
		BLUE,"",0.5,true).
}

LOCAL localBody IS ship:BODY.
LOCAL basePos IS ship:POSITION.

LOCAL upVec IS GetUpVec(ship).
local forVec is VXCL(upVec,ship:FACING:FOREVECTOR):NORMALIZED.
local offset is -20.

set mylist to list().


UNTIL offset > 20 {
	local start is (localBody:GEOPOSITIONOF(basePos-forVec*(offset-1)):POSITION-basePos).
	local vector is (localBody:GEOPOSITIONOF(basePos-forVec*offset):POSITION-basePos) -start.
	mylist:ADD(VECDRAW(
		start,
		vector,
		RED,"",0.5,true)).

	set offset to offset + 1.
}