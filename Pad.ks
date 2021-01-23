RUNONCEPATH("0:/lib/Debug").
RUNONCEPATH("0:/lib/Unwieldy").
RUNONCEPATH("0:/lib/SurfaceAt").
RUNONCEPATH("0:/lib/Search/TragectoryImpactSearch").

global runwayStart is BODY:GEOPOSITIONLATLNG(-0.0485526802803094,-74.7282838895171).
global runwayEnd is BODY:GEOPOSITIONLATLNG(-0.0502303377342092,-74.4915286545602).
global pad is BODY:GEOPOSITIONLATLNG(-0.0972077889151947,-74.5576774701971).

local function PadCorrected{
	parameter mlt is 1.
	set impactTime to TragectoryImpactTime(impactTime).
	local impP is GeopositionAt(ship,impactTime):POSITION.
	local padP is pad:POSITION.
	local errV is VXCL(UP:VECTOR, impP-padP).
	return (padP-errV)-ship:POSITION.
}

local impactTime is TragectoryImpactTime().
local stl is PadCorrected(10).
	
SAS OFF.
LOCK STEERING TO -stl.
set drawTGT to VECDRAW(
		V(0,0,0),
		{ return stl. },
		RED,"",5,true).
UNTIL ALT:RADAR < 2000 set stl to PadCorrected(5).

CHUTES ON.

UNTIL ALT:RADAR < 200 set stl to PadCorrected(2).

run LandingA.

