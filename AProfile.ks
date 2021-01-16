RUNONCEPATH("0:/lib/Ascend").
RUNONCEPATH("0:/lib/Orbit").

set pitchLock to 0.
set thrustLevel to 1.

LOCK STEERING TO HEADING(90, 90 - pitchLock).

local apo is 80000.
STAGE.

function SonicLimit{
	if AIRSPEED > 300 { return 4. }
	return 7 - 3*AIRSPEED/300.
}

function AoALimiter{
	parameter tp.
	
	local limit is SonicLimit().
	local cp is VANG(UP:VECTOR, SRFPROGRADE:VECTOR).
	
	if tp > cp { 
		return MIN(tp, cp+limit).
	}
	return MAX(tp, cp-limit).
}

function PitchSetter{
	parameter newPitch.
	clearscreen.
	set pitchLock to AoALimiter(newPitch).
	Print "Pitch lock "+ pitchLock+" target " + newPitch.
}

function NiceAgressiveProfile{
	AscendByProfile( apo, PitchSetter@, 
		list(0,	87,100,168,370,681,1677,3314,5899,10173,19364,40000), 
		list(0,  1,  2,  5, 10, 15,  25,  35,  45,   55,   70,   90)).
}
	
AscendByProfile( apo, PitchSetter@, 
	list(0,	168,370,681,1677,3314,5899,10173,19364,40000), 
	list(0,  10, 15, 20,  25,  35,  45,   55,   70,   90)).	

RiseFromAtmosphere(apo).

if (ALT:PERIAPSIS < 70000) { CircularizeOrbit(). }