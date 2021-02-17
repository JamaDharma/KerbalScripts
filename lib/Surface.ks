function GetRoll{
	return 90 - vectorangle(up:vector,ship:facing:starvector).
}
function GetPitch{
	return 90 - vectorangle(up:vector,ship:facing:FOREVECTOR).
}
function GetUpVec {
	PARAMETER p1.
	return (p1:POSITION - p1:BODY:POSITION):NORMALIZED.
}

function GlobeDistance{
	parameter gp1, gp2.
	local lb is gp1:BODY.
	local ang is VANG(gp1:POSITION-lb:POSITION,gp2:POSITION-lb:POSITION).
	return lb:RADIUS*CONSTANT:DegToRad*ang.
}
function NormalizeGP{
	parameter gp.
	return (gp:POSITION - BODY:POSITION):NORMALIZED*BODY:RADIUS.
}

function AdjDirByRoll{
	PARAMETER dir.
	PARAMETER rollVec.
	
	local fVec is dir:FOREVECTOR.
	
	return LOOKDIRUP(fVec, VCRS(fVec, rollVec)).
}

FUNCTION slope_calculation {//returns the slope of p1 in degrees
	PARAMETER p1.
	LOCAL upVec IS GetUpVec(p1).
	RETURN VANG(upVec,surface_normal(p1)).
}

FUNCTION surface_normal {
	PARAMETER p1.
	LOCAL localBody IS p1:BODY.
	LOCAL basePos IS p1:POSITION.

	LOCAL upVec IS GetUpVec(p1).
	LOCAL northVec IS VXCL(upVec,LATLNG(90,0):POSITION - basePos):NORMALIZED * 3.
	LOCAL sideVec IS VCRS(upVec,northVec):NORMALIZED * 3.//is east

	LOCAL aPos IS localBody:GEOPOSITIONOF(basePos - northVec + sideVec):POSITION - basePos.
	LOCAL bPos IS localBody:GEOPOSITIONOF(basePos - northVec - sideVec):POSITION - basePos.
	LOCAL cPos IS localBody:GEOPOSITIONOF(basePos + northVec):POSITION - basePos.
	RETURN VCRS((aPos - cPos),(bPos - cPos)):NORMALIZED.
}

FUNCTION heading_of_vector { // heading_of_vector returns the heading of the vector (number range 0 to 360)
	PARAMETER vecT.

	LOCAL east IS VCRS(SHIP:UP:VECTOR, SHIP:NORTH:VECTOR).

	LOCAL trig_x IS VDOT(SHIP:NORTH:VECTOR, vecT).
	LOCAL trig_y IS VDOT(east, vecT).

	LOCAL result IS ARCTAN2(trig_y, trig_x).

	IF result < 0 {RETURN 360 + result.} ELSE {RETURN result.}
}

function SurfacePitchVector {
	PARAMETER p1.
	LOCAL localBody IS p1:BODY.
	LOCAL basePos IS p1:POSITION.

	LOCAL upVec IS GetUpVec(p1).
	local forVec is VXCL(upVec,p1:FACING:FOREVECTOR):NORMALIZED.
	//local forVec is p1:FACING:FOREVECTOR*3.

	LOCAL bPos IS localBody:GEOPOSITIONOF(basePos-forVec*2):POSITION.
	LOCAL fPos IS localBody:GEOPOSITIONOF(basePos+forVec*9):POSITION.
	return fPos-bPos.
}
function SurfacePitch {
	PARAMETER p1.
	RETURN 90 -VANG(GetUpVec(p1),SurfacePitchVector(p1)).
}

function SurfaceRollVector {
	PARAMETER p1.
	LOCAL localBody IS p1:BODY.
	LOCAL basePos IS p1:POSITION.

	LOCAL upVec IS GetUpVec(p1).
	local adjFc is LOOKDIRUP(p1:FACING:FOREVECTOR, upVec).
	LOCAL rightVec IS adjFc:STARVECTOR * 3.

	LOCAL lPos IS localBody:GEOPOSITIONOF(basePos - rightVec):POSITION.
	LOCAL rPos IS localBody:GEOPOSITIONOF(basePos + rightVec):POSITION.
	return rPos-lPos.
}
function SurfaceRoll {
	PARAMETER p1.
	RETURN 90 -VANG(GetUpVec(p1),SurfaceRollVector(p1)).
}

FUNCTION SurfaceNormal {
	PARAMETER rover, dir, sideOffset, gradeOffset.
	LOCAL localBody IS rover:BODY.
	LOCAL basePos IS rover:POSITION.
	LOCAL upVec IS GetUpVec(rover).
	
	local forVec is VXCL(upVec,dir:FOREVECTOR):NORMALIZED*gradeOffset.
	LOCAL rightVec IS VXCL(upVec,dir:STARVECTOR):NORMALIZED*sideOffset.
	
	local lfPos is localBody:GEOPOSITIONOF(basePos - rightVec + forVec):POSITION.
	local rfPos is localBody:GEOPOSITIONOF(basePos + rightVec + forVec):POSITION.
	local lbPos is localBody:GEOPOSITIONOF(basePos - rightVec - forVec):POSITION.
	local rbPos is localBody:GEOPOSITIONOF(basePos + rightVec - forVec):POSITION.
	
	local sideVec is rfPos-lfPos+rbPos-lbPos.
	local gradeVec is rfPos-rbPos+lfPos-lbPos.
	
	RETURN VCRS(gradeVec,sideVec):NORMALIZED.
}
