HUDTEXT("Booster boot script waiting!", 5, 2, 50, blue, true).
WAIT UNTIL SHIP:SHIPNAME = "Booster".
WAIT 3.

RUNONCEPATH("0:/lib/Defaults").
RUNONCEPATH("0:/lib/DeltaV").

function BurnPossible{
	return dvCalc:StageDeltaV() > 450 and SHIP:ALTITUDE > 10000.
}

function ChangeSettings{
	local stm is STEERINGMANAGER:MAXSTOPPINGTIME.
	local pkd is STEERINGMANAGER:PITCHPID:KD.
	local rkd is STEERINGMANAGER:PITCHPID:KD.
	
	set STEERINGMANAGER:MAXSTOPPINGTIME to 50.
	set STEERINGMANAGER:PITCHPID:KD to 10.
	set STEERINGMANAGER:YAWPID:KD to 10.
	
	return {
		set STEERINGMANAGER:MAXSTOPPINGTIME to stm.
		set STEERINGMANAGER:PITCHPID:KD to pkd.
		set STEERINGMANAGER:YAWPID:KD to rkd.
	}.
}

function BurnControl{
	RCS ON.
	local revert is ChangeSettings().
	local steeringLock is HEADING(kspGP:HEADING,0).
	LOCK STEERING TO steeringLock.
	
	WAIT UNTIL VANG(steeringLock:VECTOR, SHIP:FACING:VECTOR) < 5.
	revert().
	
	UNTIL (not BurnPossible()) {
		set steeringLock to HEADING(kspGP:HEADING,0).
		set thrustLevel to thrustLevel+0.03.
		WAIT 0.
	}

	RCS OFF.

	UNLOCK STEERING.
}

local kspGP is WAYPOINT("KSC"):GEOPOSITION.
local dvCalc is StageCalculator(1).
PRINT "DV: "+dvCalc:StageDeltaV().
PRINT "Mass: "+SHIP:MASS.
PRINT "FuelMass: "+StageLfOx().

SAS OFF.
 
if BurnPossible() {
	BurnControl().
}

RUN LandingA.
