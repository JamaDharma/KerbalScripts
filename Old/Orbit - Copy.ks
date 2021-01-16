function RiseApoapsis{
	parameter desiredApoapsis.
	HUDTEXT("Rising apoapsis.", 5, 2, 50, green, true).
	LOCK STEERING TO SRFPROGRADE.
	until ALT:APOAPSIS > desiredApoapsis
	{
		WAIT 0.
	}
	set thrustLevel to 0.
}

function Coast{
	parameter desiredApoapsis.

	HUDTEXT("Coasting out of the atmosphere.", 5, 2, 50, green, true).

	//Coast with drag compensation
	UNTIL SHIP:ALTITUDE > 70000{
		UNTIL ALT:APOAPSIS > desiredApoapsis
		{
			set thrustLevel to 0.5.
			WAIT 0.
		}
		set thrustLevel to 0.
		WAIT 0.
	}
	HUDTEXT("Space.", 5, 2, 50, green, true).
}

function RiseFromAtmosphere{
	parameter desiredApoapsis is 80000.
	RiseApoapsis(desiredApoapsis).
	SET WARPMODE TO "PHYSICS".
	SET WARP TO 3.
	Coast(desiredApoapsis).
	SET WARP TO 0.
	SET WARPMODE TO "RAILS".
}

function RisePeriapsis{
	parameter desiredPeriapsis.
	
	HUDTEXT("Planning circularization.", 5, 2, 50, green, true).
	set circularization TO NODE(TIME:SECONDS+ETA:APOAPSIS, 0, 0, 1).
	ADD circularization.

	UNTIL (desiredPeriapsis - circularization:ORBIT:PERIAPSIS) < 0 {
		SET circularization:PROGRADE to circularization:PROGRADE + 1.
	}

	LOCK STEERING TO circularization:DELTAV.
	local dv is circularization:DELTAV:MAG.
	local burnTime is dv*MASS/MAXTHRUST.

	HUDTEXT((circularization:ETA - burnTime/2) + " seconds to maneuver.", 5, 2, 50, green, true).
	WAIT UNTIL VANG(circularization:DELTAV, SHIP:FACING:VECTOR) < 1.
	
	HUDTEXT("Timewarp.", 5, 2, 50, blue, true).
	WARPTO(TIME:SECONDS + circularization:ETA - burnTime/2 - 30).
	
	WAIT circularization:ETA - burnTime/2.
	HUDTEXT("Burn!", 5, 2, 50, red, true).
	set thrustLevel to 1.
	WAIT UNTIL ALT:PERIAPSIS > desiredPeriapsis.

	set thrustLevel to 0.
	REMOVE circularization.
}

function SetPeriapsis{
	parameter desiredPeriapsis.
	
	local epsilon is 1.
	
	set circularization TO NODE(TIME:SECONDS+ETA:APOAPSIS, 0, 0, 1).
	ADD circularization.
	
	local burn is 1.
	IF desiredPeriapsis < ALT:PERIAPSIS { set burn to 1.  } ELSE { PRINT "X is small".  }

	UNTIL ABS(desiredPeriapsis - circularization:ORBIT:PERIAPSIS) < epsilon {
		SET circularization:PROGRADE to circularization:PROGRADE + 1.
	}

	ExecuteBurn(circularization).
}

function BurnTime{
	parameter burn.
	RETURN burn:DELTAV:MAG*MASS/MAXTHRUST.
}

function ExecuteBurn{
	parameter burn.
	
	local burnDirection is burn:DELTAV.
	LOCK STEERING TO burnDirection.
	local burnTime is BurnTime(burn).

	HUDTEXT((burn:ETA - burnTime/2) + " seconds to maneuver.", 5, 2, 50, green, true).
	WAIT UNTIL VANG(burn:DELTAV, SHIP:FACING:VECTOR) < 1.
	
	HUDTEXT("Timewarp.", 5, 2, 50, blue, true).
	WARPTO(TIME:SECONDS + burn:ETA - burnTime/2 - 30).
	
	WAIT burn:ETA - burnTime/2.
	
	HUDTEXT("Burn!", 5, 2, 50, red, true).
	UNTIL burnTime < 0.05 OR VANG(burn:DELTAV, burnDirection) > 5 {
		set burnTime to BurnTime(burn).
		set thrustLevel to MIN(burnTime, 1).
	}
	
	set thrustLevel to 0.
	REMOVE burn.
}

function CircularizeOrbit{
	RisePeriapsis(ALT:APOAPSIS - 1000).
	HUDTEXT("Circular orbit.", 5, 2, 50, green, true).
}

function StabilizeOrbit{
	RisePeriapsis(71000).
	HUDTEXT("Stable orbit.", 5, 2, 50, green, true).
}

//defaults

SET SHIP:CONTROL:PILOTMAINTHROTTLE TO 0.

set thrustLevel to 0.

LOCK  THROTTLE TO thrustLevel.