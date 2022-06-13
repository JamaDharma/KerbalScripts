RUNONCEPATH("0:/lib/Debug").
RUNONCEPATH("0:/lib/Defaults").
RUNONCEPATH("0:/lib/ship/Engines").
RUNONCEPATH("0:/lib/Landing").

local engineList is ListActiveEngines().
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
local gimbalAngle is engineList[0]:GIMBAL:RANGE.
NPrint("gimbalAngle",gimbalAngle).
local cnt is SHIP:CONTROL.
FreeControlLock().
set cnt:NEUTRALIZE to TRUE.
local cotDiff is V(0,0,0).
LOCK STEERING to UP.
until false{
	SET SHIP:CONTROL:PILOTMAINTHROTTLE TO HoverControl(RealAltitudeRay()).
	//local engBack is engineList[0]:POSITION*FACING:VECTOR.
	//set cotDiff to -FACING:TOPVECTOR*engBack*TAN(gimbalAngle).
	//MGControl(0.5*cotDiff).
	WAIT 0.
}