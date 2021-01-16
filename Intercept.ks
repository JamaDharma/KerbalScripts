switch to 0.

function TimeTilBrake {
	local DV is (SHIP:VELOCITY:ORBIT-TARGET:VELOCITY:ORBIT):MAG.
	local dist is TARGET:DISTANCE.
	local brakingTime is DV*MASS/MAXTHRUST.
	local brakingDst is brakingTime*DV/2.
	local timeToBrake is (dist - brakingDst)/DV.
	
	RETURN timeToBrake.
}

local refresh is 1.

UNTIL TARGET:DISTANCE < 200 {
	UNTIL TimeTilBrake() < 180 {
		WAIT 5.
	}
	HUDTEXT("Burn in: " + ROUND(TimeTilBrake()) + " seconds!", refresh, 2, 50, red, true).
	WAIT refresh.
}