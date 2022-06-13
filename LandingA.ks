RUNONCEPATH("0:/lib/Defaults").

parameter landingSpeed is 1.
set touchdownAlt to 0.

function InverseControl {
	LIST PARTS IN  partList.	
	local fName is "authority limiter".
	for prt in partList
	if prt:HASMODULE("ModuleControlSurface") {
		
		local mdl is prt:getmodule("ModuleControlSurface").
		
		if mdl:HasField(fName){
			local angle is mdl:getfield(fName).
			mdl:setfield(fName, -angle).
			PRINT angle.
		}
	}
}

function BleedSpeed {
	WAIT UNTIL ALT:RADAR < 50000.
	SET SHIP:CONTROL:YAW to 1.
	SET SHIP:CONTROL:PITCH to 1.
	WAIT UNTIL ALT:RADAR < 2000.
	SET SHIP:CONTROL:YAW to 0.
	SET SHIP:CONTROL:PITCH to 0.	
}

local bounds_box is ship:bounds. 
function RealAltitude {
	RETURN bounds_box:BOTTOMALTRADAR-touchdownAlt.
}

function Gravity {
	return body:mu/body:radius^2.
}

function BlowTrusters {
	set thrustLevel to 0.001.
	WAIT 0.01.
	set thrustLevel to 0.
}

set startBraking to FALSE.
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

	IF startBraking AND AIRSPEED > landingSpeed {
		set thrustLevel to MIN(1,brakingDst/realAltitude).
	} ELSE {
		set thrustLevel to 0.
	}
}

function TouchDownControl {
	local tk is (4-VERTICALSPEED/landingSpeed)/5.
	set thrustLevel to Gravity()*MASS/MAXTHRUST*tk.
}

function SuicideBurn {
	LOCK STEERING to SRFRETROGRADE.
	UNTIL (RealAltitude() < 3) {
		SuicideBurnControl().
		WAIT 0.
	}
	
	//UNTIL (SHIP:STATUS = "LANDED" or SHIP:STATUS = "SPLASHED") {
	UNTIL false {
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

ON (AIRSPEED < landingSpeed) {
	LOCK  STEERING TO UP.
	RCS ON.
}


SAS OFF.
RCS OFF.
BlowTrusters().


//GEAR ON.
SuicideBurn().

WAIT 5.
RCS OFF.
SAS ON.
WAIT 0.