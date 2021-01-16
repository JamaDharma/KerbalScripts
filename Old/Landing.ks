switch to 0.
RUNONCEPATH("Integers").
run Chutes.

SET SHIP:CONTROL:PILOTMAINTHROTTLE TO 0.
SAS OFF.
GEAR ON.
BRAKES ON.
set thrustLevel to 0.

LOCK  THROTTLE TO thrustLevel.
LOCK  STEERING TO SRFRETROGRADE.

set landingSpeed to 1.
set startBraking to FALSE.

local coreHeight is ReadInt(CORE:PART:TAG).

function RealAltitude {
	RETURN ALT:RADAR - coreHeight.
}

function Gravity {
	return body:mu/body:radius^2.
}

function BlowTrusters {
	set thrustLevel to 0.001.
	WAIT 0.
	set thrustLevel to 0.
}

function SuicideBurnControl {
	local vAngle is VANG(UP:VECTOR, SRFRETROGRADE:VECTOR).
	local vCmp is COS(vAngle).
	local accel is vCmp*MAXTHRUST/MASS - Gravity().
	local brakingDst is (VERTICALSPEED^2 - landingSpeed^2)/2/accel.
	local brakingTime is ABS(VERTICALSPEED + landingSpeed)/accel.
	local realAltitude is RealAltitude().
	
	IF realAltitude > brakingDst*2 {
		set startBraking to FALSE.
	}
	
	IF realAltitude*5 < (brakingDst-VERTICALSPEED*0.1)*6 {
		set startBraking to TRUE.
	}

	IF startBraking AND VERTICALSPEED < (-landingSpeed) {
		set thrustLevel to MIN(1,brakingDst/realAltitude).
	} ELSE {
		set thrustLevel to 0.
	}
}

function TouchDownControl {
	set thrustLevel to Gravity()*MASS/MAXTHRUST*(9-VERTICALSPEED/landingSpeed)/10.
}

function ChutesDeploy {
	local chuteList is ListChutes().
	UNTIL (chuteList:LENGTH = 0) {
		IF SHIP:ALTITUDE < 15000 {
			set chuteList to TryToDeployChutes(chuteList).
		}
		WAIT 0.25.
	}
}

function SuicideBurn {
	local chuteList is ListChutes().
	UNTIL (RealAltitude() < 0) {
		IF SHIP:ALTITUDE < 15000 {
			set chuteList to TryToDeployChutes(chuteList).
		}
		FROM {local x is 25.} UNTIL x = 0 STEP {set x to x-1.} DO {
			SuicideBurnControl().
			WAIT 0.
		}
	}
	
	UNTIL (SHIP:STATUS = "LANDED" or SHIP:STATUS = "SPLASHED") {
		TouchDownControl().
		WAIT 0.
	}
	set thrustLevel to 0.
	WAIT 3.
}

ON (RealAltitude() < 2) {
	HUDTEXT("Landing speed 2: " + VERTICALSPEED, 5, 2, 50, green, true).
	ON (RealAltitude() < 1) {
		HUDTEXT("Landing speed 1: " + VERTICALSPEED, 5, 2, 50, green, true).
		ON (RealAltitude() < 0) {
			HUDTEXT("Landing speed 0: " + VERTICALSPEED, 5, 2, 50, green, true).
		}
	}
}

ON (VELOCITY:SURFACE:MAG < 10) {
	LOCK  STEERING TO UP.
}

HUDTEXT("Ship height: " + coreHeight, 5, 2, 50, green, true).
BlowTrusters().
SuicideBurn().

