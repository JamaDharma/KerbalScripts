function Mod360 {
	parameter value.
	IF value < 0 { set value to value + 360. }
	IF value > 360 { set value to value - 360. }
	RETURN value.
}

function LongitudeDelta {
	RETURN SHIP:LONGITUDE - TARGET:LONGITUDE.
}

function SetDefaultTarget {
	set TARGET to Sun.
}

function TargetSet {
	RETURN TARGET <> Sun.
}

function LongitudeChangeRate {
	local sample is 10.
	
	local ld0 is TARGET:LONGITUDE.
	WAIT sample.
	local ld1 is TARGET:LONGITUDE.
	RETURN Mod360(ld1-ld0)/sample.
}

function WaitForIt {
	parameter targetDelta.
	
	local rate is LongitudeChangeRate().
	local change is  Mod360(SHIP:LONGITUDE - targetDelta - TARGET:LONGITUDE).
	local waitTime is change/rate.

	WARPTO(TIME:SECONDS + waitTime - 10).
	
	WAIT UNTIL LongitudeDelta() > targetDelta.
	WAIT UNTIL LongitudeDelta() < targetDelta.
}