RUNONCEPATH("0:/lib/Debug").
RUNONCEPATH("0:/lib/Targeting").
RUNONCEPATH("0:/lib/SurfaceAt").
RUNONCEPATH("0:/lib/Search/BinarySearch").
RUNONCEPATH("0:/lib/GravityTurnSimulation").

SET SHIP:CONTROL:PILOTMAINTHROTTLE TO 0.


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


local tgt is GetTargetGeo().
if HASNODE REMOVE NEXTNODE.
local targetTime is TimeOnTarget(time+300,tgt).


local inclCorrTime is targetTime - ship:ORBIT:PERIOD/4.
if inclCorrTime > time:SECONDS {
	PRINT "Trying to correct inclination".
	local myNode is NODE(inclCorrTime:SECONDS,0,0,0).
	ADD(myNode).
	BSearch(
		{ return SeparationNrm(targetTime, tgt):SQRMAGNITUDE.},
		MakeBSComponent( 1, 0.1, { parameter dX. set myNode:NORMAL to myNode:NORMAL+dX. })
	).
	run Burn.
	REMOVE(myNode).
}


set targetTime to TimeOnTarget(targetTime,tgt).//orbit changed

local velAtTgt is HorVelAt(targetTime)[1]:MAG.
local burnTime is targetTime-velAtTgt*MASS/MAXTHRUST/2.

local burnAlt is AltitudeAt(burnTime).
PRINT "Burn altitude: "+burnAlt+" above target terrain: "+ (burnAlt-tgt:TERRAINHEIGHT).

local info is FallFrom(burnTime).
NPrint("t - braking time: ",info[0]).
NPrint("x - braking distance: ",info[1]).
NPrint("z - drop: ",info[2]).


local burnStart is targetTime - info[1]/GROUNDSPEED.
WARPTO(burnStart:SECONDS - 90).

SAS ON.
WAIT 0.5.
set SASMODE to "RETROGRADE".
set NAVMODE to "SURFACE".

WAIT UNTIL burnStart < time+30.

UNTIL burnStart < time+10 {
	set burnStart to targetTime - info[1]/GROUNDSPEED.
	NPrint("Seconds to burn", (burnStart-time):SECONDS,0).
	WAIT 1.
}

UNTIL burnStart < time {
	set burnStart to targetTime - info[1]/GROUNDSPEED.
	WAIT 0.1.
}
SET SHIP:CONTROL:PILOTMAINTHROTTLE TO 1.

WAIT UNTIL AIRSPEED < 10.
SET SHIP:CONTROL:PILOTMAINTHROTTLE TO 0.3.
WAIT UNTIL AIRSPEED < 1.
SET SHIP:CONTROL:PILOTMAINTHROTTLE TO 0.
run LandingV.