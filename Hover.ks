RUNONCEPATH("0:/lib/Debug").

parameter hgh.

local tThrust is 12.
local bg is body:mu/(body:radius+ALTITUDE)^2.

SAS OFF.
LOCK STEERING TO LOOKDIRUP(UP:VECTOR,TARGET:FACING:VECTOR).
function ToInput{
	parameter val.
	local aval is ABS(val).
	
	if aval > 0.001 and aval < 0.05 {
		if val < 0 return -0.05.
		else return 0.05.
	}
	
	return val.
}
function TControl{
	parameter pos, vel, dir, accel.
	
	local dist is pos*dir.
	local spd is vel*dir.
	
	NPrint("dist",dist).
	NPrint("spd",spd).
	
	if ABS(dist) < 0.1 return -spd/accel.
	
	local tt is dist/spd.
	if  tt < 0 or tt > 60 return dist.
	
	local bt is spd/accel.
	local bd is bt*spd/2.
	
	if bd+1 >= ABS(dist) return -bd/dist.

	return 0.
}
local cnt is SHIP:CONTROL.
local fcn is SHIP:FACING.
set cnt:NEUTRALIZE to TRUE.
RCS ON.
until false{
	local cr is (hgh-ALT:RADAR-3*VERTICALSPEED)*0.03.
	SET cnt:PILOTMAINTHROTTLE TO bg*MASS/MAXTHRUST+cr.
	WAIT 0.
	
	local tpv is VXCL(UP:VECTOR, TARGET:POSITION).
	if tpv:MAG < 0.1 set hgh to hgh - 0.1.
	local svv is VXCL(UP:VECTOR, ship:VELOCITY:SURFACE).
	local shipAcc is tThrust/MASS.
	
	CLEARSCREEN.
	PRINT "Top "+cnt:TOP.
	SET cnt:TOP TO ToInput(TControl(tpv,svv,fcn:TOPVECTOR,shipAcc)).
	PRINT "Star "+cnt:STARBOARD.
	SET cnt:STARBOARD TO ToInput(TControl(tpv,svv,fcn:STARVECTOR,shipAcc)).
}