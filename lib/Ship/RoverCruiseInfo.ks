RUNONCEPATH("0:/lib/Debug").
RUNONCEPATH("0:/lib/Surface").

local crPath is "1:/CruisePitchCorrection".
function ReadCruiseCorrection{
	if EXISTS(crPath)
		return READJSON(crPath).
	else 
		return 0.
}
function WriteCruiseCorrection{
	parameter cr is CruiseCorrection().
	WRITEJSON(cr, crPath).
}
function CruiseCorrection{
	local ld is ship:FACING.
	local sn is SurfaceNormal(ship, ld, 5, 10).
	return VANg(VXCL(ld:STARVECTOR, sn),ld:UPVECTOR).
}

local wpPath is "1:/CruiseRoute".
function ReadCruiseRoute{
	if EXISTS(wpPath)
		return READJSON(wpPath).
	else 
		return list().
}
function WriteCruiseRoute{
	parameter cr.
	WRITEJSON(cr, wpPath).
}
function CleanCruiseRoute{
	DELETEPATH(wpPath).
}