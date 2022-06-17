//big wheels phisics abuse
RUNONCEPATH("0:/lib/Surface/Surface").

parameter spd is 20.
PRINT "Cruise speed: " + spd.

CLEARSCREEN.

local dir is 1.
function Ski{
	SET SHIP:CONTROL:WHEELSTEER TO dir.
	set dir to -dir. 
}

set motor to 10.
set SHIP:CONTROL:WHEELSTEER to 0.
SET SHIP:CONTROL:WHEELTHROTTLE TO motor.

BRAKES OFF.
SAS OFF.

UNTIL false{
	//Ski().
	wait 0.
}

SAS ON.
BRAKES ON.
CORE:PART:CONTROLFROM().
