RUNONCEPATH("0:/lib/Debug").
RUNONCEPATH("0:/lib/Defaults").
RUNONCEPATH("0:/lib/Landing").

local function Gravity {
	return body:mu/body:radius^2.
}

local function VerticalAcceleration{
	local cosA is UP:VECTOR*FACING:VECTOR.
	return cosA*MAXTHRUST/MASS - Gravity().
}

function HeavyTouchDownControl {
	parameter rAlt.
	local landingSpeed is 1.
	local accel is VerticalAcceleration().
	local spd is -VERTICALSPEED.
	
	local brkTime is (spd - landingSpeed)/accel.
	local landTime is rAlt*2/(spd+landingSpeed).
	
	function PrintInfo{
		NPrint("alt",rAlt).
		NPrint("accel",accel).
		NPrint("landTime",landTime).
		NPrint("brakTime",brakTime).
	}
	//PrintInfo().
	
	return brkTime/landTime.
}

LOCK STEERING TO SRFRETROGRADE.
RCS ON.

local hgh is RealAltitudeRay(1).

UNTIL hgh < 1 {
	set hgh to RealAltitudeRay(1).
	SetThrust(HeavyTouchDownControl(hgh)).
	WAIT 0.
}

LOCK STEERING TO UP.

local bg is body:mu/(body:radius+ALTITUDE)^2.
function HoverControl {
	parameter rAlt.	
	local cr is (1-rAlt-3*VERTICALSPEED)*0.03.
	return bg*MASS/MAXTHRUST+cr.
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
local cnt is SHIP:CONTROL.
set cnt:NEUTRALIZE to TRUE.
RCS ON.
until false{
	SetThrust(HoverControl(RealAltitudeRay())).
	WAIT 0.
	
	local fcn is SHIP:FACING.
	local tpv is VXCL(UP:VECTOR, TARGET:POSITION).
	local svv is VXCL(UP:VECTOR, ship:VELOCITY:SURFACE).
	local shipAcc is tThrust/MASS.
	
	CLEARSCREEN.
	PRINT "Top "+cnt:TOP.
	SET cnt:TOP TO TControl(tpv,svv,fcn:TOPVECTOR,shipAcc).
	PRINT "Star "+cnt:STARBOARD.
	SET cnt:STARBOARD TO TControl(tpv,svv,fcn:STARVECTOR,shipAcc).
}