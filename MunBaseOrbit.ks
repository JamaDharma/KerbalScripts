RUNONCEPATH("0:/lib/Ascend").
RUNONCEPATH("0:/lib/Unwieldy").

set STEERINGMANAGER:ROLLCONTROLANGLERANGE to 2.
set STEERINGMANAGER:ROLLPID:KD to 10.
SET SHIP:CONTROL:PILOTMAINTHROTTLE TO 0.
SAS OFF.

set pitchLock to 0.
LOCK STEERING TO HEADING(90, 90 - pitchLock).

function PitchSetter{
	parameter newPitch.
	set pitchLock to newPitch.
}

set thrustLevel to 1.


AscendByProfile( 90000, PitchSetter@, 
list( 0,   2517,2533,2598,2739,2910,3104,3319,3556,3813,4092,4392,5055,5808,6614,7000), 
list( 0,	 1,2,5,10,15,20,25,30,35,40,45,55,65,75,80)).

UNTIL (SHIP:APOAPSIS > 20000) {
	set pitchLock to VANG(UP:VECTOR, SRFPROGRADE:VECTOR).
	WAIT 0.
}

set thrustLevel to 0.
WAIT 0.1.

SAS ON.
WAIT 0.5.
SET SASMODE to "PROGRADE".
WAIT 0.5.