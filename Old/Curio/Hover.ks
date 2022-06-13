RUNONCEPATH("0:/lib/Debug").
RUNONCEPATH("0:/lib/ship/Engines").
local function Gravity {
	return body:mu/body:radius^2.
}
local alleng is ListStageEngines(0).
local function EngPos{
	local result is V(0,0,0).
	if MAXTHRUST > 0 {
		for eng in alleng {
			set result to result + eng:POSITION*eng:MAXTHRUST.
		}
		set result to result/MAXTHRUST.
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

		

STAGE.
WAIT 0.
SAS OFF.
LOCK STEERING TO SteeringVector().

until false{
SET SHIP:CONTROL:PILOTMAINTHROTTLE TO Gravity()*MASS/MAXTHRUST+0.01.
}