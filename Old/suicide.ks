CLEARSCREEN.

SET SHIP:CONTROL:PILOTMAINTHROTTLE TO 0.
GEAR ON.
BRAKES ON.

set thrustLevel to 0.

LOCK  THROTTLE TO thrustLevel.
LOCK  STEERING TO SRFRETROGRADE.

set landingSpeed to 10.
set gAcc to 9.8.
set startBraking to FALSE.


function RealAltitude{
	RETURN ALT:RADAR - 29.
}

function SuicideBurnControl{
	local vAngle is VANG(UP:VECTOR, SRFRETROGRADE:VECTOR).
	local vCmp is COS(vAngle).
	local accel is vCmp*MAXTHRUST/MASS - gAcc.
	
	local brakingDst is (VERTICALSPEED*VERTICALSPEED - landingSpeed*landingSpeed)/2/accel.

	IF RealAltitude() < brakingDst {
		set startBraking to TRUE.
	}
	
	IF startBraking {
		IF VERTICALSPEED < (-landingSpeed) {
			set thrustLevel to brakingDst/RealAltitude().
		} ELSE {
			set thrustLevel to 0.
		}
	}
}

function SuicideBurn{
	UNTIL (SHIP:STATUS = "LANDED" or SHIP:STATUS = "SPLASHED") {
		SuicideBurnControl().
		WAIT 0.
	}
	HUDTEXT("Finished: " + VERTICALSPEED, 5, 2, 50, green, true).
	set thrustLevel to 0.
	WAIT 10.
}

ON (RealAltitude() < 2) {
	HUDTEXT("Landing speed: " + VERTICALSPEED, 5, 2, 50, green, true).
}

ON (VELOCITY:SURFACE:MAG < 10) {
	LOCK  STEERING TO UP.
	HUDTEXT("Steereng UP", 5, 2, 50, green, true).
}

ON (SHIP:ALTITUDE < 5000 and VELOCITY:SURFACE:MAG < 260) {
	STAGE.
}

ON (VERTICALSPEED > -1) {
	LOCK  STEERING TO UP.
	HUDTEXT("Altitude: " + RealAltitude(), 5, 2, 50, green, true).
}

HUDTEXT("Altitude: " + RealAltitude(), 5, 2, 50, green, true).

SuicideBurn().

