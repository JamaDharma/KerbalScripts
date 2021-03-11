RUNONCEPATH("0:/lib/Debug").
RUNONCEPATH("0:/lib/Defaults").
RUNONCEPATH("0:/lib/Targeting").
RUNONCEPATH("0:/lib/SurfaceAt").
RUNONCEPATH("0:/lib/BurnExecutor").
RUNONCEPATH("0:/lib/Search/GoldenSearch").
RUNONCEPATH("0:/lib/GravityTurnSimulation").

local targetHeight is 75.
SET SHIP:CONTROL:PILOTMAINTHROTTLE TO 0.


local tgt is GetTargetGeo().
if HASNODE REMOVE NEXTNODE.

local targetTime is TimeOnTarget(time,tgt).
local burnTime is targetTime-HorVelAt(targetTime)[1]:MAG*MASS/MAXTHRUST/2.
local info is FallFrom(burnTime,10).
local endH is EndHeight().
UpdateInfo(10).
PrintInfo().

if targetTime-time > 250
	CorrectionBurn().

UpdateInfo(1).
PrintInfo().
UpdateInfo(1).
PrintInfo().
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

//run TerminalGuidance.
run LandingVR.

//functions
local function Separation{
	parameter tT,tGP.
	return GlobeDistance(GeopositionAt(ship, tT),tGP).
}
local function TimeOnTarget{
	parameter tT, tGP.

	GSearch(
		{ return Separation(tT, tGP).},
		MakeSearchComponent( 1, 0.1, {parameter dT. set tT to tT + dT.})
	).

	if tT - time > 1 return tT.
	
	return TimeOnTarget(tT+ship:ORBIT:PERIOD, tGP).
}
local function EndHeight{
	return AltitudeAt(burnTime)-tgt:TERRAINHEIGHT+info["Z"].
}
local function UpdateInfo{
	parameter dt.
	
	set targetTime to TimeOnTarget(targetTime,tgt).
	local spdV is VELOCITYAT(ship,targetTime):SURFACE.
	local upV is (POSITIONAT(ship, targetTime) - ship:BODY:POSITION).
	local gs is VXCL(upV,spdV):MAG.
	set burnTime to targetTime - info["X"]/gs.
	set info to FallFrom(burnTime, dt).
	set endH to EndHeight().
}
local function PrintInfo{
	NPrint("t - braking time",info["T"]).
	NPrint("x - braking distance",info["X"]).
	NPrint("z - drop",-info["Z"]).
	NPrint("Final height",endH).
	NPrint("Final distance",Separation(targetTime, tgt)).
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
	GSearch(
		{ return (EndHeight() - targetHeight)^2.},
		MakeSearchComponent( 1, 0.1, 
		{ parameter dX. set NEXTNODE:PROGRADE to NEXTNODE:PROGRADE+dX. })
	).

	set NEXTNODE:PROGRADE to (prg + NEXTNODE:PROGRADE)/2.
	
	GSearch(
		{ return Separation(targetTime, tgt).},
		MakeSearchComponent( 1, 0.1, 
		{ parameter dX. set NEXTNODE:NORMAL to NEXTNODE:NORMAL+dX. })
	).
	
	return NEXTNODE:PROGRADE.
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
