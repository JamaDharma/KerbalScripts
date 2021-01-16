RUNONCEPATH("0:/lib/Ascend").

local spd is 250.
//FreeControlLock().

set pitchLock to 0.
LOCK STEERING TO HEADING(90, 90 - pitchLock).

function twr{
	return MAXTHRUST/MASS/10.
}

WHEN SHIP:AIRSPEED > spd THEN {
	set thrustLevel to MAX(1/twr() - (SHIP:AIRSPEED - spd)*0.01, 0).
	return SHIP:ALTITUDE < 14000.
}
WHEN SHIP:AIRSPEED < spd THEN {
	set thrustLevel to MIN(1/twr() - (SHIP:AIRSPEED - spd)*0.01,1).
	return SHIP:ALTITUDE < 14000.
}
WHEN SHIP:ALTITUDE > 15000 THEN {
	set thrustLevel to 1.
	return false.
}

function NPrint {
	parameter s,n.
	PRINT s + ": " + ROUND(n,2).
}
WHEN terminal:input:haschar THEN {
	local ch is terminal:input:getchar().
	if ch = "w" {
		set spd to spd+10.
		NPrint("Speed limit",spd).
	} else if ch = "s" {
		set spd to spd-10.
		NPrint("Speed limit",spd).
	} 
	return true.
}


function PitchSetter{
	parameter newPitch.
	set pitchLock to newPitch.
	//PRINT SHIP:CONTROL:PITCH.
	//PRINT STEERINGMANAGER:PITCHPID:SETPOINT.
}

set thrustLevel to 1.

STAGE.

AscendByProfile( 90000, PitchSetter@, 
list( 0,   101,150,250,500,1000,8000, 10000, 15000), 
list( 0,	 0,  5, 10, 15,  25,  35,    45,    55)).

UNTIL (SHIP:ALTITUDE > 30000) {
	set pitchLock to VANG(UP:VECTOR, SRFPROGRADE:VECTOR)-2.
	WAIT 0.1.
}

SAS ON.
WAIT 0.1.
SET SASMODE to "PROGRADE".
WAIT 0.1.