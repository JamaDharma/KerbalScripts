RUNONCEPATH("0:/lib/Debug").
RUNONCEPATH("0:/lib/Common").

//Solves powered landing from terminal velocity
function NewChuteSolver {
	parameter g is LocalGravity().
	NPrint("g",g).
	parameter accel is ship:maxthrust/mass.
	NPrint("accel",accel).
	parameter v0 is VERTICALSPEED.
	NPrint("v0",v0).

	local twr is accel/g.
	local shipGF is twr-1.
	local atRoot is SQRT(shipGF/twr).
	local stoppingACos is ARCCOS(-atRoot).
	local stoppingK is LN(atRoot).

	local accelRoot is SQRT(shipGF).
	local timeK is CONSTANT:RADTODEG*g*accelRoot/v0.

	local velK is accelRoot*v0.

	//velocity at t
	function VelocityAtT {
		parameter t.
		return velK*TAN(timeK*t-stoppingACos).
	}

	//distance at t
	function DistanceAtT {
		parameter t.
		return v0^2/g*(stoppingK - LN(-COS(stoppingACos-timeK*t))).
	}

	function TimeOfV {
		parameter vel.
		set vel to -ABS(vel).//always negative
		//local num is ARCTAN(v/velK)+stoppingACos.
		//NPrintMany("num",num,"den",timeK).
		//hack:why -180?
		RETURN (ARCTAN(vel/velK)+stoppingACos-180)/timeK.
	}

	return lexicon(
		"V0", v0,
		"TimeOfV", TimeOfV@,
		"Velocity", VelocityAtT@,
		"Distance", DistanceAtT@
	).
}