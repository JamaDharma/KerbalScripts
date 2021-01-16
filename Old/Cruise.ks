RUNONCEPATH("0:/lib/Surface").

parameter spd is 20.
PRINT "Cruise speed: " + spd.

CLEARSCREEN.

set motor to 1.
SET controlStick to SHIP:CONTROL.
BRAKES OFF.

LOCK WHEELTHROTTLE TO motor.


set exit to false.
function SafeMode{
	set exit to true.
	UNLOCK WHEELTHROTTLE.
	set controlStick:ROLL to 0.
	SAS OFF.
	GEAR ON.
	PANELS OFF.
	SHIP:PARTSTAGGED("UpFacingControlPoint")[0]:CONTROLFROM().
	LOCK STEERING to UP.
	WAIT UNTIL AIRSPEED < 1.
}

UNTIL exit {
	set rollDiff to GetRoll() - SurfaceRoll(ship).
	
	if ABS(rollDiff) > 60 { 
		SafeMode(). 
	} else {
		if not BRAKES { set motor to MAX(0,MIN(1, spd - GROUNDSPEED)). }
		else { set motor to 0. }
		set controlStick:ROLL to rollDiff/15.
	}
	WAIT 0.1.
}

SAS ON.
BRAKES ON.
CORE:PART:CONTROLFROM().
