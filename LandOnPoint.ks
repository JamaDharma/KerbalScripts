RUNONCEPATH("0:/lib/Debug").
RUNONCEPATH("0:/lib/Defaults").
RUNONCEPATH("0:/lib/Targeting").
RUNONCEPATH("0:/lib/SurfaceAt").
RUNONCEPATH("0:/lib/BurnExecutor").
RUNONCEPATH("0:/lib/Search/BinarySearch").
RUNONCEPATH("0:/lib/GravityTurnSimulation").

local targetHeight is 75.
SET SHIP:CONTROL:PILOTMAINTHROTTLE TO 0.


local tgt is GetTargetGeo().
if HASNODE REMOVE NEXTNODE.

local targetTime is TimeOnTarget(time+300,tgt).
local horVel is HorVelAt(targetTime)[1]:MAG.
local burnTime is targetTime-horVel*MASS/MAXTHRUST/2.
local info is FallFrom(burnTime,10).
local endH is EndHeight().
UpdateInfo(10).
PrintInfo().

CorrectionBurn().

UpdateInfo(1).
PrintInfo().

WARPTO(burnTime:SECONDS - 60).

SAS ON.
WAIT 0.5.
set SASMODE to "RETROGRADE".
set NAVMODE to "SURFACE".

WAIT UNTIL burnTime < time+30.

UNTIL burnTime < time+2 {
	NPrint("Seconds to burn", (burnTime-time):SECONDS,0).
	WAIT 1.
}

WAIT UNTIL burnTime < time.
SetThrust(1).
WAIT UNTIL VANG(SRFRETROGRADE:VECTOR,UP:VECTOR) < 45.

run LandingV.

//functions
local function SeparationNrm{
	parameter tT,tGP.
	return NormalizeGP(GeopositionAt(ship, tT)) - NormalizeGP(tGP).
}
local function TimeOnTarget{
	parameter tT, tGP.

	BSearch(
		{ return SeparationNrm(tT, tGP):SQRMAGNITUDE.},
		MakeBSComponent( 1, 0.1, {parameter dT. set tT to tT + dT.})
	).

	return tT.
}
local function EndHeight{
	return AltitudeAt(burnTime)-tgt:TERRAINHEIGHT-info[2].
}
local function UpdateInfo{
	parameter dt.
	
	set targetTime to TimeOnTarget(targetTime,tgt).
	set horVel to HorVelAt(burnTime)[1]:MAG.
	set burnTime to targetTime - info[1]/horVel.
	set info to FallFrom(burnTime, dt).
	set endH to EndHeight().
}
local function PrintInfo{
	NPrint("t - braking time",info[0]).
	NPrint("x - braking distance",info[1]).
	NPrint("z - drop",info[2]).
	NPrint("Final height",endH).
	NPrint("Final distance",SeparationNrm(targetTime, tgt):MAG).
	PRINT "----------------------".
}
local function CorrectionBurnNeeded{
	until false {
		terminal:input:CLEAR().
		PRINT "Press Y after adding or editing correction burn node".
		PRINT "Press N to skip correction burn".
		local ch is terminal:input:getchar().
		if ch = "n" 	return false.
		if ch = "y"	return true.
	}
}
local function MakeCorrector{
	local mPrg is 0.
	return { set mPrg to SetCorrection(mPrg).}.
}
local function SetCorrection{
	parameter prg.
	BSearch(
		{ return (EndHeight() - targetHeight)^2.},
		MakeBSComponent( 1, 0.1, 
		{ parameter dX. set NEXTNODE:PROGRADE to NEXTNODE:PROGRADE+dX. })
	).

	set NEXTNODE:PROGRADE to (prg + NEXTNODE:PROGRADE)/2.
	
	BSearch(
		{ return SeparationNrm(targetTime, tgt):SQRMAGNITUDE.},
		MakeBSComponent( 1, 0.1, 
		{ parameter dX. set NEXTNODE:NORMAL to NEXTNODE:NORMAL+dX. })
	).
	
	return NEXTNODE:PROGRADE.
}
local function CorrectionBurn{
	if targetTime - time < 300 return.
	
	local inclCorrTime is targetTime - ship:ORBIT:PERIOD/4.
	if inclCorrTime > time {
		PRINT "Placing correction node for optimal inclination correction".
		ADD(NODE(inclCorrTime:SECONDS,0,0,0)).
	} else {
		PRINT "Placing correction node, eta 2 minutes".
		ADD(NODE(time:SECONDS + 120,0,0,0)).
	}
	
	if CorrectionBurnNeeded() {
		local corrector is MakeCorrector().
		until ABS(endH-targetHeight) < targetHeight/3 {
			corrector().
			UpdateInfo(1).
			PrintInfo().
		}
		SAS OFF.
		BurnExecutor(NodeBurnControl(NEXTNODE)).
	}

	if HASNODE REMOVE NEXTNODE.
}
