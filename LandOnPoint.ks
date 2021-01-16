RUNONCEPATH("0:/lib/Debug").
RUNONCEPATH("0:/lib/Targeting").
RUNONCEPATH("0:/lib/SurfaceAt").
RUNONCEPATH("0:/lib/Search/BinarySearch").
RUNONCEPATH("0:/lib/GravityTurnSimulation").

SET SHIP:CONTROL:PILOTMAINTHROTTLE TO 0.

local tgt is GetTargetGeo().
local targetTime is time:SECONDS+30.

local function TimeOnTarget{
	BSearch(list(
		0.1,
		{ parameter dX. set targetTime to targetTime+dX. },
		1,
		{ return (GeopositionAt(ship,targetTime):POSITION-tgt:POSITION):MAG. }
	)).
}

if HASNODE REMOVE NEXTNODE.

TimeOnTarget().

local inclCorrTime is targetTime - ship:ORBIT:PERIOD/4.
if inclCorrTime > time:SECONDS {
	PRINT "Trying to correct inclination".
	local myNode is NODE(inclCorrTime,0,0,0).
	ADD(myNode).
	BSearch(list(
		1,
		{ parameter dX. set myNode:NORMAL to myNode:NORMAL+dX. },
		0.01,
		{ return (GeopositionAt(ship,targetTime):POSITION-tgt:POSITION):MAG. }
	)).
	run Burn.
	REMOVE(myNode).
}


TimeOnTarget().//orbit changed

local velAtTgt is HorVelAt(targetTime)[1]:MAG.
local burnTime is targetTime-velAtTgt*MASS/MAXTHRUST/2.

local burnAlt is AltitudeAt(burnTime).
PRINT "Burn altitude: "+burnAlt+" above target terrain: "+ (burnAlt-tgt:TERRAINHEIGHT).

local info is FallFrom(burnTime).
NPrint("t - braking time: ",info[0]).
NPrint("x - braking distance: ",info[1]).
NPrint("z - drop: ",info[2]).


local burnStart is targetTime - info[1]/GROUNDSPEED.
WARPTO(burnStart - 30).

WAIT UNTIL burnStart < time:SECONDS+30.

UNTIL burnStart < time:SECONDS+10 {
	set burnStart to targetTime - info[1]/GROUNDSPEED.
	NPrint("Seconds to burn", burnStart-time:SECONDS,0).
	WAIT 1.
}

SAS ON.
WAIT 0.5.
set SASMODE to "RETROGRADE".
set NAVMODE to "SURFACE".
UNTIL burnStart < time:SECONDS {
	set burnStart to targetTime - info[1]/GROUNDSPEED.
	WAIT 0.1.
}
SET SHIP:CONTROL:PILOTMAINTHROTTLE TO 1.

WAIT UNTIL AIRSPEED < 10.
SET SHIP:CONTROL:PILOTMAINTHROTTLE TO 0.3.
WAIT UNTIL AIRSPEED < 1.
SET SHIP:CONTROL:PILOTMAINTHROTTLE TO 0.
run LandingV.