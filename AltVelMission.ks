parameter tgtAlt is 10.
set tgtAlt to tgtAlt*1000.
parameter tgtVel is 500.
parameter margin is 20.

local grv is body:mu/(body:radius+tgtAlt)^2.

local function DesiredVelocity{
	parameter dst, vel.
	//d - (vs+ve)/2 * (vs-ve)/g
	//d = (vs^2-ve^2)/2g
	//sqrt(2dg + ve^2)
	return SQRT(2*dst*grv + vel^2).
}

local thrustLevel is 1.

LOCK throttle to thrustLevel.
LOCK steering to UP.

STAGE.
WAIT 0.5.

until ALTITUDE > tgtAlt {
	local altDiff is tgtAlt - altitude.
	local spd is verticalSpeed.

	local minGoal is DesiredVelocity(altDiff,tgtVel-margin).
	local maxGoal is DesiredVelocity(altDiff,tgtVel).

	set thrustLevel to (maxGoal - spd)/(maxGoal-minGoal).

	PRINT " Min: "+ROUND(minGoal)+" Max: "+ROUND(maxGoal)+"   " at (0,0).

	WAIT 0.
}

STAGE.