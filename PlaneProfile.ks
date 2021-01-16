RUNONCEPATH("0:/lib/Ascend").
RUNONCEPATH("0:/lib/Orbit").

set pitchLock to 90.
set thrustLevel to 1.

SAS OFF.
LOCK STEERING TO HEADING(90, 90 - pitchLock).

local apo is 80000.

BRAKES OFF.
STAGE.


function SonicLimit{
	if AIRSPEED > 900 { return 1. }
	return 7 - 6*AIRSPEED/900.
}

function AoALimiter{
	parameter tp.
	
	local limit is SonicLimit().
	local cp is VANG(UP:VECTOR, SRFPROGRADE:VECTOR).
	Print "Pitch: "+ round(cp,2).
	
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

set pitchLock to VANG(UP:VECTOR, FACING:VECTOR).
print pitchLock.
WAIT UNTIL AIRSPEED > 100.
set pitchLock to pitchlock - 3.
UNTIL AIRSPEED > 100 and ALTITUDE > 100 {
	WAIT 0.1.
}

GEAR OFF.

function NiceAgressiveProfile{
	AscendByProfile( apo, PitchSetter@, 
		list(90,	87,100,168,370,681,1677,3314,5899,10173,19364,40000), 
		list(90,  1,  2,  5, 10, 15,  25,  35,  45,   55,   70,   90)).
}
	
AscendByProfile( apo, PitchSetter@, 
	list( 0, 168,370,681,1000, 2000, 5000), 
	list(90,  83, 80, 75,  71,   68,   67)).	

RiseFromAtmosphere(apo).

if (ALT:PERIAPSIS < 70000) { CircularizeOrbit(). }