RUNONCEPATH("0:/lib/Ship/DeltaV").

function NodeBurnControl{
	parameter burn.
	
	local dvCalc is StageCalculator().
	local function GetBurnTime{
		parameter burn.
		return dvCalc:BurnTime(burn:DELTAV:MAG).
	}
	
	local this is lexicon(
		"Burn", burn,
		"StateControl", MainBurn@,
		"SteerControl", { return burn:DELTAV.},
		"BurnLeft", { return burn:DELTAV:MAG.}
	).
	
	function MainBurn{
		if GetBurnTime(burn) < 1 ToFinalization().
		return false.
	}
	
	function ToFinalization{
		local finalDirection is burn:DELTAV.
		set this["StateControl"] to {return VANG(burn:DELTAV, finalDirection) > 80.}.
		set this["SteerControl"] to { return finalDirection.}.
	}
	
	return this.
}

function CustomBurnControl{
	parameter burn, tc.
	
	local dvCalc is StageCalculator().
	local function GetBurnTime{
		parameter burn.
		return dvCalc:BurnTime(burn:DELTAV:MAG).
	}
	
	local this is lexicon(
		"Burn", burn,
		"StateControl", MainBurn@,
		"SteerControl", { return burn:DELTAV.},
		"BurnLeft", tc
	).
	
	function MainBurn{
		if GetBurnTime(burn) < 1 or tc() < 1 ToFinalization().
		return false.
	}
	
	function ToFinalization{
		set this["StateControl"] to { return tc() <= 0.}.
		local finalDirection is burn:DELTAV.
		set this["SteerControl"] to { return finalDirection.}.
	}
	
	return this.
}

function GradeBurnControl{
	parameter burn, tc.
	
	local this is lexicon(
		"Burn", burn,
		"StateControl", { return tc() <= 0.},
		"BurnLeft", tc
	).
	
	if(burn:PROGRADE > 0)
		this:ADD("SteerControl", { return PROGRADE.}).
	else
		this:ADD("SteerControl", { return RETROGRADE.}).

	return this.
}
function ProgradeBurnControl{
	parameter burn, tc.
	
	local this is lexicon(
		"Burn", burn,
		"StateControl", { return tc() <= 0.},
		"SteerControl", { return PROGRADE.},
		"BurnLeft", tc
	).
	
	return this.
}
function RetrogradeBurnControl{
	parameter burn, tc.
	
	local this is lexicon(
		"Burn", burn,
		"StateControl", { return tc() <= 0.},
		"SteerControl", { return RETROGRADE.},
		"BurnLeft", tc
	).
	
	return this.
}
local function PrepareForBurn{
	parameter burn, burnTime.

	LOCK STEERING TO burn:DELTAV.

	HUDTEXT(ROUND(burn:ETA - burnTime/2) + "s to maneuver. Burn time " + ROUND(burnTime) + "s.", 5, 2, 50, green, true).
	WAIT UNTIL VANG(burn:DELTAV, SHIP:FACING:VECTOR) < 1.
	
	UNLOCK STEERING.
	
	HUDTEXT("Timewarp.", 5, 2, 50, blue, true).
	WARPTO(TIME:SECONDS + burn:ETA - burnTime/2 - 30).
}

function BurnExecutor{
	parameter burnControl.
	local burn is burnControl:Burn.
	local burnTime is StageCalculator():BurnTime(burn:DELTAV:MAG).
	
	PrepareForBurn(burn, burnTime).

	local steeringLock is burnControl:SteerControl().
	LOCK STEERING TO steeringLock.
	
	UNTIL burn:ETA < burnTime/2{
		set steeringLock to  burnControl:SteerControl().
		WAIT 0.
	}

	HUDTEXT("Burn!", 5, 2, 50, red, true).
	
	until burnControl:StateControl() {
		set steeringLock to  burnControl:SteerControl().
		set thrustLevel to burnControl:BurnLeft()*MASS/MAXTHRUST.
		WAIT 0.
	}
	
	set thrustLevel to 0.
	UNLOCK STEERING.
}