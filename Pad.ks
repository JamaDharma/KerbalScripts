RUNONCEPATH("0:/lib/Debug").
RUNONCEPATH("0:/lib/Unwieldy").
RUNONCEPATH("0:/lib/SurfaceAt").
RUNONCEPATH("0:/lib/Search/TragectoryImpactSearch").

global runwayStart is BODY:GEOPOSITIONLATLNG(-0.0485526802803094,-74.7282838895171).
global runwayEnd is BODY:GEOPOSITIONLATLNG(-0.0502303377342092,-74.4915286545602).
global pad is BODY:GEOPOSITIONLATLNG(-0.0972077889151947,-74.5576774701971).

local function PadCorrected{
	parameter upd is 0, mlt is 1.
	set impactTime to TragectoryImpactTime(impactTime,upd).
	local impP is GeopositionAt(ship,impactTime):POSITION.
	local padP is pad:POSITION.
	local errV is VXCL(UP:VECTOR, impP-padP).
	NPrint("Error",errV:MAG).
	return (padP-errV*mlt)-ship:POSITION+UP:VECTOR*upd.
}
local function PadCorrectedLocal{
	parameter upd is 0, mlt is 1.
	local tti is (padH+upd-ALTITUDE)/VERTICALSPEED.
	local impP is ship:POSITION + ship:VELOCITY:SURFACE*tti.
	local padP is pad:POSITION.
	local errV is VXCL(UP:VECTOR, impP-padP).
	NPrint("Error",errV:MAG).
	return (padP-errV*mlt)-ship:POSITION+UP:VECTOR*upd.
}
local function PadCorrectedFinal{
	parameter mlt is 1.
	local k is (500-VERTICALSPEED)/VERTICALSPEED.
	local tti is (padH-ALTITUDE)/(k*VERTICALSPEED).
	local impP is ship:POSITION + ship:VELOCITY:SURFACE*k*tti.
	local padP is pad:POSITION.
	local errV is VXCL(UP:VECTOR, impP-padP).
	NPrint("Error",errV:MAG).
	return (padP-errV*mlt)-ship:POSITION.
}
local function PadUp{
	parameter upd is 0.
	local shipP is ship:POSITION.
	local padP is pad:POSITION.
	local errV is VXCL(UP:VECTOR, shipP-padP).
	NPrint("Error current",errV:MAG).
	return padP-ship:POSITION+UP:VECTOR*upd.
}
local function ImpactError{
	set impactTime to TragectoryImpactTime(impactTime).
	local impP is GeopositionAt(ship,impactTime):POSITION.
	local padP is pad:POSITION.
	local errV is VXCL(UP:VECTOR, padP-impP).
	NPrint("Error",errV:MAG).
	return errV:NORMALIZED*RealAltitude() +UP:VECTOR*500.
}

local impactTime is TragectoryImpactTime().
local stl is PadCorrected(5).
local padH is pad:TERRAINHEIGHT.
	
SAS OFF.
local accWatch is PidLoop(0,0,1).
local accAvg is accWatch:UPDATE(time:SECONDS,-VERTICALSPEED).
WHEN true THEN {
	set accWatch:SETPOINT to AVAILABLETHRUST/MASS*SHIP:CONTROL:PILOTMAINTHROTTLE.
	set accAvg to accWatch:UPDATE(time:SECONDS,-VERTICALSPEED).
	return true.
}
LOCK STEERING TO -stl.

set drawTGT to VECDRAW(
		V(0,0,0),
		{ return stl. },
		RED,"",5,true).
set drawSPD to VECDRAW(
		V(0,0,0),
		{ return VXCL(UP:VECTOR,ship:VELOCITY:SURFACE). },
		RED,"",5,true).

UNTIL ALT:RADAR < 25000 {
	NPRINT("accAvg",accAvg).
	set stl to PadCorrected(ALT:RADAR/16, 20).
	WAIT 0.
}
RCS ON.
UNTIL ALT:RADAR < 10000 {
	NPRINT("accAvg",accAvg).
	set stl to PadCorrectedLocal(ALT:RADAR/16,20).
	WAIT 0.
}
UNTIL ALT:RADAR < 3000 {
	NPRINT("accAvg",accAvg).
	set stl to PadCorrectedFinal(20).
	WAIT 0.
}
CHUTES ON.

local bounds_box is ship:bounds. 
function RealAltitude {
	RETURN bounds_box:BOTTOMALTRADAR.
}

function Gravity {
	return body:mu/body:radius^2.
}

set startBraking to FALSE.
function SuicideBurnControl {
	local vAngle is VANG(UP:VECTOR, FACING:VECTOR).
	local vCmp is COS(vAngle).
	local accel is vCmp*MAXTHRUST/MASS - Gravity().
	local brakingDst is (VERTICALSPEED^2)/2/accel.
	local brakingTime is ABS(VERTICALSPEED)/accel.
	local realAltitude is RealAltitude().
	
	IF realAltitude > brakingDst*2 {
		set startBraking to FALSE.
	}
	
	IF realAltitude*5 < (brakingDst-VERTICALSPEED*0.1)*6 {
		set startBraking to TRUE.
	}

	IF startBraking AND AIRSPEED > 1 {
		SET SHIP:CONTROL:PILOTMAINTHROTTLE TO MIN(1,brakingDst/realAltitude).
	} ELSE {
		SET SHIP:CONTROL:PILOTMAINTHROTTLE TO 0.
	}
}

WHEN true THEN {
	//SuicideBurnControl().
	return not (RealAltitude() < 1 or AIRSPEED < 1 or VERTICALSPEED > 0).
}
UNTIL VERTICALSPEED > -200 {
	NPRINT("accAvg",accAvg).
	//set stl to -ImpactError().
	set stl to PadCorrectedFinal(20).
	WAIT 0.
}
UNTIL RealAltitude() < 1 or AIRSPEED < 1 or VERTICALSPEED > 0 {
	//set stl to -ImpactError().
	set stl to -PadUp(ALT:RADAR+25).
	WAIT 0.
}
SET SHIP:CONTROL:PILOTMAINTHROTTLE TO 0.