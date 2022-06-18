RUNONCEPATH("0:/lib/Debug").
RUNONCEPATH("0:/lib/Ship/DeltaV").

function MakeThrustControl{
	parameter tgtValue, sign.
	
	local currentThrust is 1.
	local tracker is PIDLOOP(1,0,1,-0.25,0.125).
	set tracker:SETPOINT to sign*tgtValue.
	
	return {
		parameter currVal.
		local change is tracker:UPDATE(time:SECONDS, sign*currVal).
		set currentThrust to MAX(0,MIN(1,currentThrust+currentThrust*change)).
		return currentThrust.
	}.
}

function NewEncounterThrustControl {
	parameter tgtBody,tgtPeriapsis.
	local tc is MakeThrustControl(tgtPeriapsis,-1).
	local function ThrustControl{
		if ship:ORBIT:HASNEXTPATCH and ship:ORBIT:NEXTPATCH:BODY = tgtBody {
			local currPer is ship:ORBIT:NEXTPATCH:PERIAPSIS.
			if currPer < tgtPeriapsis return -1.	
			return tc(currPer)+0.001.
		}
		return 1.
	}
	RETURN ThrustControl@.
}

function BurnControlBase{
	parameter burn.
	local bl is StageCalculator():BurnTime(burn:DELTAV:MAG).
	return lexicon(
		"Burn", burn,
		"BurnTiming", bl/2,
		"BurnLength", bl
	).
}

function BurnControlThrust{
	parameter burn, tc.
	local this is BurnControlBase(burn).
	this:ADD("StateControl", { return tc() <= 0.}).
	this:ADD("ThrustControl", tc).
	return this.
}

function NodeBurnControl{
	parameter burn.
	
	local dvCalc is StageCalculator().
	local function GetBurnTime{
		parameter burn.
		return dvCalc:BurnTime(burn:DELTAV:MAG).
	}
	
	local this is BurnControlBase(burn).
	this:ADD("StateControl", MainBurn@).
	this:ADD("SteerControl", { return burn:DELTAV.}).
	this:ADD("ThrustControl", { return burn:DELTAV:MAG*MASS/MAXTHRUST.}).
	
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
	
	local this is BurnControlBase(burn).
	this:ADD("StateControl", MainBurn@).
	this:ADD("SteerControl", { return burn:DELTAV.}).
	this:ADD("ThrustControl", tc).
	
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
	
	local this is BurnControlThrust(burn,tc).
	
	if(burn:PROGRADE > 0)
		this:ADD("SteerControl", { return PROGRADE.}).
	else
		this:ADD("SteerControl", { return RETROGRADE.}).

	return this.
}
function ProgradeBurnControl{
	parameter burn, tc.
	
	local this is BurnControlThrust(burn,tc).
	this:ADD("SteerControl", { return PROGRADE.}).
	
	return this.
}
function RetrogradeBurnControl{
	parameter burn, tc.
	
	local this is BurnControlThrust(burn,tc).
	this:ADD("SteerControl", { return RETROGRADE.}).
	
	return this.
}

local function PrepareForBurn{
	//node,burnTiming, burnLength
	parameter burn, bt, bl.

	LOCK STEERING TO burn:DELTAV.

	HUDTEXT(ROUND(burn:ETA - bt) + "s to maneuver. Burn time " 
		+ ROUND(bl) + "s.", 5, 2, 50, green, true).
	WAIT UNTIL VANG(burn:DELTAV, SHIP:FACING:VECTOR) < 1.
	
	UNLOCK STEERING.
	
	HUDTEXT("Timewarp.", 5, 2, 50, blue, true).
	local warpTime is TIME + burn:ETA - bt - 30.
	WARPTO(warpTime:SECONDS).
	WAIT UNTIL TIME > warpTime.
}

function BurnExecutor{
	parameter burnControl.
	local burn is burnControl:Burn.
	local bt is burnControl:BurnTiming.
	
	PrepareForBurn(burn, bt, burnControl:BurnLength).

	local steeringLock is burnControl:SteerControl().
	LOCK STEERING TO steeringLock.
	
	UNTIL burn:ETA < bt{
		set steeringLock to  burnControl:SteerControl().
		WAIT 0.
	}

	HUDTEXT("Burn!", 5, 2, 50, red, true).
	
	until burnControl:StateControl() {
		set steeringLock to  burnControl:SteerControl().
		set thrustLevel to burnControl:ThrustControl().
		WAIT 0.
	}
	
	set thrustLevel to 0.
	UNLOCK STEERING.
}