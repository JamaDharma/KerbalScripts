RUNONCEPATH("0:/lib/Debug").
RUNONCEPATH("0:/lib/Unwieldy").
RUNONCEPATH("0:/lib/SurfaceAt").
RUNONCEPATH("0:/lib/Ship/Acceleration").
RUNONCEPATH("0:/lib/Search/TragectoryImpactSearch").

global runwayStart is BODY:GEOPOSITIONLATLNG(-0.0485526802803094,-74.7282838895171).
global runwayEnd is BODY:GEOPOSITIONLATLNG(-0.0502303377342092,-74.4915286545602).
global pad is BODY:GEOPOSITIONLATLNG(-0.0972077889151947,-74.5576774701971).
//global pad is BODY:GEOPOSITIONLATLNG((-0.04855268-0.05023)/2,(-74.7282-74.4915)/2).

function InverseControl {
	LIST PARTS IN  partList.	
	local fName is "authority limiter".
	for prt in partList
	if prt:HASMODULE("ModuleControlSurface") {
		
		local mdl is prt:getmodule("ModuleControlSurface").
		
		if mdl:HasField(fName){
			local angle is mdl:getfield(fName).
			mdl:setfield(fName, -100).
			PRINT angle.
		}
	}
}
local function PadCorrected{
	parameter upd is 0, mlt is 1.
	set impactTime to TragectoryImpactTime(impactTime,upd).
	local impP is GeopositionAt(ship,impactTime):POSITION.
	local padP is pad:POSITION.
	local errV is VXCL(UP:VECTOR, impP-padP).
	NPrint("Error",errV:MAG).
	return (padP-errV*mlt)-ship:POSITION+UP:VECTOR*upd.
}

InverseControl().
local impactTime is TragectoryImpactTime().
local stl is PadCorrected(5).
local padH is pad:TERRAINHEIGHT.
set STEERINGMANAGER:ROLLCONTROLANGLERANGE to 180.	
SAS OFF.

local accWatch is MakeAccelerometer().
local accAvg is 0.
LOCK accAvg to accWatch:UpdateV().

LOCK STEERING TO -stl.

set drawTGT to VECDRAW(
		V(0,0,0),
		{ return pad:POSITION. },
		RED,"",5,false).
		
local ss is FALSE.
local sf is TRUE.
function StopControl {
	parameter vAngle is VANG(UP:VECTOR, FACING:VECTOR).
	local vCmp is SIN(vAngle).
	local accel is vCmp*(ship:MAXTHRUSTAT(1)/MASS+accAvg/2).
	local brakingTime is ABS(GROUNDSPEED)/accel+1.
	local brakingDst is brakingTime*GROUNDSPEED/2.
	local padHorV is VXCL(UP:VECTOR,pad:POSITION).
	local dist is padHorV:MAG-25.
	
	IF sf AND dist > brakingDst*2 {
		set ss to FALSE.
	}	
	IF sf AND dist*3 < brakingDst*2 {
		set ss to TRUE.
	}
	if sf AND ship:VELOCITY:SURFACE*padHorV:NORMALIZED < 10 {
		set sf to FALSE.
	}
	
	NPRINT("Pad distance", dist).
	NPRINT("Bracking distance", brakingDst).

	IF ss AND sf {
		SET SHIP:CONTROL:PILOTMAINTHROTTLE TO MIN(1,brakingDst/dist).
	} ELSE {
		SET SHIP:CONTROL:PILOTMAINTHROTTLE TO 0.
	}
}
UNTIL ss {
	StopControl().
	//set stl to VXCL(SRFPROGRADE:TOPVECTOR,PadCorrected(10)).
	set stl to PadCorrected(10).
	WAIT 0.
}
UNTIL not sf {
	StopControl().
	set stl to SRFPROGRADE:VECTOR.
	WAIT 0.
}

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
	local accel is vCmp*ship:MAXTHRUSTAT(1)/MASS + accAvg*vCmp/2-Gravity().
	local brakingDst is (VERTICALSPEED^2)/2/accel.
	local brakingTime is ABS(VERTICALSPEED)/accel.
	local rlAlt is MAX(1, RealAltitude()).
	NPRINT("realAltitude",rlAlt).
	IF rlAlt > brakingDst*2 {
		set startBraking to FALSE.
	}
	
	IF rlAlt*15 < (brakingDst-VERTICALSPEED*0.1)*16 {
		set startBraking to TRUE.
	}

	IF startBraking AND AIRSPEED > 1 {
		SET SHIP:CONTROL:PILOTMAINTHROTTLE TO MIN(1,brakingDst/rlAlt).
	} ELSE {
		SET SHIP:CONTROL:PILOTMAINTHROTTLE TO 0.
	}
}

UNTIL startBraking {
	SuicideBurnControl().
	set stl to PadCorrected(5).
	WAIT 0.
}

LOCK STEERING TO SRFRETROGRADE.

UNTIL VERTICALSPEED > -5 {
	SuicideBurnControl().
}

SET SHIP:CONTROL:PILOTMAINTHROTTLE TO 0.