RUNONCEPATH("0:/lib/Debug").
RUNONCEPATH("0:/lib/Defaults").
RUNONCEPATH("0:/lib/ship/Engines").
RUNONCEPATH("0:/lib/Landing").

local topE is 0.
local botE is 0.
local rghtE is 0.
local leftE is 0.

local function Gravity {
	return body:mu/body:radius^2.
}
local engineList is ListActiveEngines().

local bounds_box is engineList[0]:bounds.
local bkv is -ship:FACING:VECTOR.
local engH is (bounds_box:FURTHESTCORNER(bkv)-SHIP:ROOTPART:POSITION)*bkv.

local function EngPos{
	local result is V(0,0,0).
	if MAXTHRUST > 0 {
		for eng in engineList {
			set result to result + eng:POSITION*eng:MAXTHRUST.
		}
		set result to result/MAXTHRUST.
	}
	return result.
}
local function EngPosA{
	local result is V(0,0,0).
	if MAXTHRUST > 0 {
		for eng in engineList {
			set result to result + eng:POSITION*eng:AVAILABLETHRUST.
		}
		set result to result/AVAILABLETHRUST.
	}
	return result.
}
local epsilon is 0.0001^2.
local function MakeFromToRot{
	parameter v1, v2.
	local axis is VCRS(v1,v2).
	if axis:SQRMAGNITUDE < epsilon 
		return R(0,0,0).
	local ang is VANG(v1,v2).
	return ANGLEAXIS(ang, axis).
}

local function SteeringVector{
	local rot is MakeFromToRot(EngPos(), -UP:VECTOR).
	return rot*ship:FACING.
}


local bg is body:mu/(body:radius+ALTITUDE)^2.
local hoverAlt is 10.
function HoverControl {
	parameter rAlt.	
	local cr is (hoverAlt-rAlt-3*VERTICALSPEED)*0.03.
	return bg*MASS/MAXTHRUST+cr.
}

function MGControl{
	parameter mgv.
	local fv is FACING:VECTOR.
	local weight is 4.
	for eng in engineList {
		local engC is VXCL(fv, eng:POSITION).
		local engCM is engC:MAG.
		local dcot is engC*mgv/engCM.
		local tl is 1.
		if dcot < -0.0001 {
			set tl to (1+weight*dcot/(engCM-dcot)).
		} 
		set eng:THRUSTLIMIT to tl*100.
	}
}
function TControl{
	parameter pos, vel, dir, accel.
	
	local dist is pos*dir.
	local spd is vel*dir.
	
	NPrint("dist",dist).
	NPrint("spd",spd).
	
	if ABS(dist) < 10 return -spd/accel.
	
	local tt is dist/spd.
	if  tt < 0 or tt > 60 return dist.
	
	local bt is spd/accel.
	local bd is bt*spd/2.
	
	if bd+1 >= ABS(dist) return -bd/dist.

	return 0.
}

		
local tThrust is 24.
local gimbalAngle is 10.//engineList[0]:GIMBAL:RANGE.
NPrint("gimbalAngle",gimbalAngle).
local cnt is SHIP:CONTROL.
FreeControlLock().
set cnt:NEUTRALIZE to TRUE.
local cotDiff is V(0,0,0).
local cot is EngPos().
local cotA is EngPosA().
CLEARVECDRAWS().
set drawCoT to VECDRAW(
	{ return UP:VECTOR*15.},
	{ return cot. },
	GREEN,"",1,true,0.1).
set drawCoTA to VECDRAW(
	{ return UP:VECTOR*15.},
	{ return cotA. },
	RED,"",1,true,0.1).
set drawCoTD to VECDRAW(
	{ return UP:VECTOR*15+cot.},
	{ return cotDiff. },
	GREEN,"",1,true,0.1).
set drawEng to VECDRAW(
	{ return engineList[0]:POSITION.},
	{ return (engineList[1]:POSITION-engineList[0]:POSITION)*10. },
	BLUE,"",1,true,0.1).
until false{
	//SET SHIP:CONTROL:PILOTMAINTHROTTLE TO HoverControl(RealAltitudeRay()).
	SET cnt:PITCH TO 1.
	local engBack is engineList[0]:POSITION*FACING:VECTOR.
	//NPrint("engBack",engBack).
	//NPrint("Radar",RealAltitude()).
	set cot to EngPos().
	set cotA to EngPosA().
	set cotDiff to -FACING:TOPVECTOR*engBack*TAN(gimbalAngle).
	NPrint("AngleR",VANG(cot,cotA)).
	NPrint("AngleT",VANG(cot,cot+cotDiff)).
	MGControl(cotDiff).
	//NPrint("Ray",RealAltitudeRay()).
	//NPrint("Radar",RealAltitude()).
	WAIT 0.
}