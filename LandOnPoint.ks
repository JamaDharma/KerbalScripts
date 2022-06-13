RUNONCEPATH("0:/lib/Debug").
RUNONCEPATH("0:/lib/Defaults").
RUNONCEPATH("0:/lib/Targeting").
RUNONCEPATH("0:/lib/TerminalGuidance").
RUNONCEPATH("0:/lib/Ship/DeltaV").
RUNONCEPATH("0:/lib/Surface/SurfaceAt").
RUNONCEPATH("0:/lib/BurnExecutor").
RUNONCEPATH("0:/lib/Search/GoldenSearch").
RUNONCEPATH("0:/lib/Numerical/Powered/PoweredDescentCalculator").

local targetHeight is 75.
local distanceMargin is 100.
SET SHIP:CONTROL:PILOTMAINTHROTTLE TO 0.

local tgt is GetTargetGeo().
if HASNODE REMOVE NEXTNODE.
local tgtDistCalcMaker is NewSurfaceAtCalculator()["MakeDistToTimeTargetCalculator"].
local pdc is NewPoweredDescentCalculator().
local terrH is tgt:TERRAINHEIGHT.

local targetTime is TimeOnTarget(time).
local burnStartT is targetTime-HorVelAt(targetTime)[1]:MAG*MASS/MAXTHRUST/2.
local info is pdc(burnStartT,10).
local endH is info["Z"]-terrH.
local endT is burnStartT+info["T"].
UpdateInfo(10).
UpdateInfo(2).
PrintInfo().

if targetTime-time > 250
	CorrectionBurn().
	
set pdc to NewPoweredDescentCalculator().
local lastDist is info["X"].
UpdateInfo(1).
UNTIL ABS(lastDist-info["X"]) < 10{
	set lastDist to info["X"].
	UpdateInfo(1).
	PrintInfo().
}
UpdateInfo(1).
PrintInfo().

WARPTO(burnStartT:SECONDS - 60).

SAS ON.
WAIT 0.5.
set SASMODE to "RETROGRADE".
set NAVMODE to "SURFACE".

WAIT UNTIL burnStartT < time+10.
NPrint("Seconds to burn", (burnStartT-time):SECONDS,0).
WAIT UNTIL burnStartT < time+0.05.
SetThrust(1).

NPrint("GeoDistance",GlobeDistance(tgt,ship:GEOPOSITION)).
NPrint("BurnDistance",info["X"]).
NPrint("DistCalk",tgtDistCalcMaker(endT,tgt)(ship:POSITION)).
NPrint("AltDiff",info["SS"]["P"]:Z-ALTITUDE).
NPrint("SpdDiff",info["SS"]["V"]:MAG-velocity:ORBIT:MAG).

//SET SHIP:CONTROL:PILOTMAINTHROTTLE to 1.
SAS OFF.
LOCK STEERING TO RETROGRADE.

WAIT UNTIL tgt:DISTANCE < 500.
//WAIT UNTIL AIRSPEED < 10.
local TerminalControl is MakeTerminalControl(tgt).
local res is TerminalControl().

local steerLock is res["Steering"].
LOCK STEERING TO steerLock.
UNTIL GROUNDSPEED < 5 {
	WAIT 0.
	set res to TerminalControl().
	set steerLock to res["Steering"].
	SetThrust(res["Thrust"]). 
}

run LandingVR.

//functions
local function TimeOnTarget{
	parameter tT.
	
	local DistCalc is tgtDistCalcMaker(tT,tgt).

	GSearch(
		{ return DistCalc(PositionAt(ship,tT)).},
		MakeSearchComponent( 1, 0.01, {parameter dT. set tT to tT + dT.})
	).

	if tT - time > 1 return tT.
	
	return TimeOnTarget(tT+ship:ORBIT:PERIOD).
}
local function TimeOnDist{
	parameter tT, dst.
	
	local DistCalc is tgtDistCalcMaker(endT,tgt).

	GSearch(
		{ 
			if tT < targetTime 
				return ABS(DistCalc(PositionAt(ship,tT))-dst).
			return DistCalc(PositionAt(ship,tT))+dst.
		},
		MakeSearchComponent( 1, 0.01, {parameter dT. set tT to tT + dT.})
	).

	return tT.
}
local function UpdateInfo{
	parameter dt.
	set targetTime to TimeOnTarget(targetTime).
	set burnStartT to TimeOnDist(burnStartT,info["X"]+distanceMargin).
	set info to pdc(burnStartT, dt).
	set endH to info["Z"]-tgt:TERRAINHEIGHT.
	set endT to burnStartT+info["T"].
}
local function PrintInfo{
	PRINT "Burn start at: "+burnStartT:CLOCK.
	
	NPrint("t - braking time",info["T"]).
	NPrint("x - braking distance",info["X"]).
	NPrint("z - drop",-info["DZ"]).
	NPrint("Final height",endH).
	
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
	
	local hAdj is info["DZ"]-terrH-targetHeight.
	GSearch(
		{ return (AltitudeAt(burnStartT)+hAdj)^2.},
		MakeSearchComponent( 1, 0.01, 
		{ parameter dX. set NEXTNODE:PROGRADE to NEXTNODE:PROGRADE+dX. WAIT 0. })
	).

	set NEXTNODE:PROGRADE to (prg + NEXTNODE:PROGRADE)/2.
	
	CorrectInclination().
	
	return NEXTNODE:PROGRADE.
}
local function CorrectInclination{
	local DistCalc is tgtDistCalcMaker(endT,tgt).
	GSearch(
		{ return DistCalc(PositionAt(ship,targetTime)).},
		MakeSearchComponent( 1, 0.001, 
		{ parameter dX. set NEXTNODE:NORMAL to NEXTNODE:NORMAL+dX. WAIT 0. })
	).
}
local function CorrectionBurn{
	if targetTime - time < 150 return.
	
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
		terminal:input:CLEAR().
		PRINT "Calculating correction burn, press any key to skip".
		until ABS(endH-targetHeight) < targetHeight/3 or terminal:input:HASCHAR {
			corrector().
			set pdc to NewPoweredDescentCalculator(
				-MAXTHRUST, MassAfter(NEXTNODE:DELTAV:MAG)).
			UpdateInfo(2).
			UpdateInfo(1).
			PrintInfo().
		}
		SAS OFF.
		PRINT "Executing burn".
		WAIT 1.
		BurnExecutor(NodeBurnControl(NEXTNODE)).
	}

	if HASNODE REMOVE NEXTNODE.
}
