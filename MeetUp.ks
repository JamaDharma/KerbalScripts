RUNONCEPATH("0:/lib/Debug").
local function TRetro{
	return TARGET:VELOCITY:ORBIT - SHIP:VELOCITY:ORBIT.
}

local startBraking to FALSE.
function MeetUpControl {
	parameter thrustSetter.
	local retroV is TRetro().
	local spd is retroV:MAG.
	local vAngle is VANG(-TARGET:DIRECTION:VECTOR, retroV).
	local dist is COS(vAngle)*TARGET:DISTANCE.
	
	local accel is MAXTHRUST/MASS.
	local brakingTime is spd/accel+1.//1 sec margin
	local brakingDst is brakingTime*retroV:MAG/2.
	
	//NPrint("brakingDst",brakingDst).
	//NPrint("dist",dist).
	
	IF dist < brakingDst { set startBraking to TRUE. }

		
	IF startBraking {
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

UNTIL VANG(retro0, retro) > 30 and retro:MAG < 1 {
	set retro to MeetUpControl(SetThrust@).
	WAIT 0.
}

SAS ON.