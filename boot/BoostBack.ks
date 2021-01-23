if SHIP:SHIPNAME = "Booster" RUN Pad.
HUDTEXT("Booster boot script waiting!", 5, 2, 50, blue, true).
WAIT UNTIL SHIP:SHIPNAME = "Booster".
WAIT 3.

RUNONCEPATH("0:/lib/Defaults").
RUNONCEPATH("0:/lib/DeltaV").
RUNONCEPATH("0:/lib/SurfaceAt").
RUNONCEPATH("0:/lib/Search/TragectoryImpactSearch").

local function BurnPossible{
	return dvCalc:StageDeltaV() > 450 and SHIP:ALTITUDE > 10000.
}
local function ImpactError{
	parameter t.
	local impP is GeopositionAt(ship,t):POSITION.
	local padP is pad:POSITION + padAdj.
	local errV is VXCL(UP:VECTOR, padP-impP).
	return errV.
}
local function ChangeSettings{
	local stm is STEERINGMANAGER:MAXSTOPPINGTIME.
	local pkd is STEERINGMANAGER:PITCHPID:KD.
	local rkd is STEERINGMANAGER:PITCHPID:KD.
	
	set STEERINGMANAGER:MAXSTOPPINGTIME to 30.
	set STEERINGMANAGER:PITCHPID:KD to 10.
	set STEERINGMANAGER:YAWPID:KD to 10.
	
	return {
		set STEERINGMANAGER:MAXSTOPPINGTIME to stm.
		set STEERINGMANAGER:PITCHPID:KD to pkd.
		set STEERINGMANAGER:YAWPID:KD to rkd.
	}.
}

local function BurnControl{
	RCS ON.
	local revert is ChangeSettings().
	local steeringLock is HEADING(pad:HEADING,0).
	LOCK STEERING TO steeringLock.
	
	local impactTime is TragectoryImpactTime().
	set steeringLock to ImpactError(impactTime).
	
	WAIT UNTIL VANG(steeringLock, SHIP:FACING:VECTOR) < 15.
	revert().
	
	UNTIL (not BurnPossible()) {
		set impactTime to TragectoryImpactTime(impactTime).
		set steeringLock to ImpactError(impactTime).
		local burnTime is steeringLock:MAG/(impactTime-time)/MAXTHRUST*MASS.
		if burnTime < 2 set thrustLevel to burnTime:SECONDS/2.
		else set thrustLevel to thrustLevel+0.03.
		
		PRINT steeringLock:MAG.
		local ang is VANG(steeringLock, SHIP:FACING:VECTOR).
		if ang > 70 break.
		WAIT 0.
	}

	RCS OFF.

	UNLOCK STEERING.
}

global pad is BODY:GEOPOSITIONLATLNG(-0.0972077889151947,-74.5576774701971).
local padAdj is (pad:POSITION - ship:POSITION):NORMALIZED*100.
local dvCalc is StageCalculator(1).
PRINT "DV: "+dvCalc:StageDeltaV().
PRINT "Mass: "+SHIP:MASS.
PRINT "FuelMass: "+StageLfOx().

SAS OFF.
 
if BurnPossible() {
	BurnControl().
}

RUN Pad.
