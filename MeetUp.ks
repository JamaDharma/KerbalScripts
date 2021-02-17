RUNONCEPATH("0:/lib/Debug").
parameter margin is 1.

local function TRetro{
	return TARGET:VELOCITY:ORBIT - SHIP:VELOCITY:ORBIT.
}

local startBraking to FALSE.
function MeetUpControl {
	parameter thrustSetter.
	local retroV is TRetro().
	local spd is retroV:MAG.
	local vAngle is VANG(-TARGET:DIRECTION:VECTOR, retroV).
	local dist is COS(vAngle)*TARGET:DISTANCE-margin.
	
	local accel is MAXTHRUST/MASS.
	local brakingTime is spd/accel.
	local brakingDst is (brakingTime+1)*retroV:MAG/2.//1 sec margin
	
	//NPrint("brakingDst",brakingDst).
	//NPrint("dist",dist).
	
	IF dist < brakingDst { set startBraking to TRUE. }

		
	IF startBraking {
		if dist <= 0
			thrustSetter((spd+0.1)/accel).
		else
			thrustSetter(MIN(1,brakingDst/dist)).
	} ELSE {
		thrustSetter(0).
	}
	
	return retroV.
}

RUNONCEPATH("0:/lib/Defaults").

local retro is TRetro().
local retro0 is retro.

SAS OFF.
LOCK STEERING to retro.

UNTIL VANG(retro0, retro) > 60 or retro:MAG < 0.01 {
	set retro to MeetUpControl(SetThrust@).
	WAIT 0.
}

SAS ON.