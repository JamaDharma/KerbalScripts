RUNONCEPATH("0:/lib/Debug").
RUNONCEPATH("0:/lib/Surface").
RUNONCEPATH("0:/lib/Ship/RoverCruiseInfo").

parameter spd is 20.
PRINT "Cruise speed: " + spd.

local pitchCorrection is ReadCruiseCorrection().

local function MakeRouteWheelControl{
	parameter route is ReadCruiseRoute().
	if route:LENGTH = 0 
		return lexicon(
			"CurrentTarget",{ return ship:GEOPOSITION.},
			"WheelControl",{}
		).
	
	local currT is route[0].
	local this is lexicon(
		"CurrentTarget",{ return currT.},
		"WheelControl",Steer@
	).
	
	function Steer{
		if currT:DISTANCE < 100 {
			route:REMOVE(0).
			if route:LENGTH = 0 {
				set this["WheelControl"] to Finalize@.
				return.
			}
			set currT to route[0].
			WriteCruiseRoute(route).
			PRINT "Waypoint passed. Route updated.".
		}
		set SHIP:CONTROL:PILOTWHEELSTEERTRIM 
			to MAX(-0.5,MIN(0.5,-0.05*currT:BEARING)).
	}
	
	function Finalize{
		set SHIP:CONTROL:PILOTWHEELSTEERTRIM to 0.
		BRAKES ON.
		CleanCruiseRoute().
		PRINT "Last waypoint.".
		set this["WheelControl"] to {}.
	}
	
	return this.
}
CLEARSCREEN.

set motor to 1.
set steerLock to SRFPROGRADE.
local wc is MakeRouteWheelControl().
BRAKES OFF.
SAS OFF.

set STEERINGMANAGER:ROLLCONTROLANGLERANGE to 180.

LOCK WHEELTHROTTLE TO motor.
LOCK STEERING to steerLock.

WHEN terminal:input:haschar THEN {
	local ch is terminal:input:getchar().
	if ch = "w" {
		set spd to spd+1.
	} else if ch = "s" {
		set spd to spd-1.
	} else if ch = "c" {
		WriteCruiseCorrection().
		set pitchCorrection to ReadCruiseCorrection().
		NPrint("CruiseCorrection updated",pitchCorrection).
	} else if ch = "i" {		
		NPrint("Distance to next WP",wc:CurrentTarget():DISTANCE).
	}
	NPrint("Speed",spd).
	return true.
}

set exit to false.
function SafeMode{
	set exit to true.
	UNLOCK WHEELTHROTTLE.
	SAS OFF.
	GEAR ON.
	PANELS OFF.
	SHIP:PARTSTAGGED("UpFacingControlPoint")[0]:CONTROLFROM().
	LOCK STEERING to UP.
	WAIT UNTIL AIRSPEED < 1.
}

function LookDir {
	if airspeed < 3 { return ship:FACING. }
	return SRFPROGRADE.
}

UNTIL exit {

	if not BRAKES { 
		set motor to MAX(0,MIN(1, spd - AIRSPEED)). 
	}
	else { 
		set motor to 0. 
	}

	local ld is LookDir().
	local sn is SurfaceNormal(ship, ld, 5, 10).
	local correction is ANGLEAXIS(-pitchCorrection,ld:STARVECTOR).
	set steerLock to correction*LOOKDIRUP(VXCL(sn,ld:VECTOR), sn).
	wc:WheelControl().
	WAIT 0.
}

SAS ON.
BRAKES ON.
CORE:PART:CONTROLFROM().
