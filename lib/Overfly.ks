RUNONCEPATH("0:/lib/Debug").
RUNONCEPATH("0:/lib/Targeting").
RUNONCEPATH("0:/lib/SurfaceAt").
RUNONCEPATH("0:/lib/Search/BinarySearch").
RUNONCEPATH("0:/lib/Search/ManeuverSearch").

local function LNGDiff{
	parameter gpO, gpG.
	local lDiff is gpO:LNG - gpG:LNG.
	if lDiff < 0 set lDiff to lDiff + 180.
	if lDiff > 180 set lDiff to lDiff - 180.
	return lDiff.
}

local function SeparationV{
	parameter tT,tGP.
	return GeopositionAt(ship, tT):POSITION - tGP:POSITION.
}

local function SeparationNrm{
	parameter tT,tGP.
	return NormalizeGP(GeopositionAt(ship, tT)) - NormalizeGP(tGP).
}

local function MinimalSeparationTime{
	parameter minSepTime, tGP.

	BSearch(
		{ return SeparationNrm(minSepTime, tGP):SQRMAGNITUDE.},
		MakeBSComponent( 1, 0.1, {parameter dT. set minSepTime to minSepTime + dT.})
	).

	return minSepTime.
}

local function OrbitOver{
	parameter tGP.

	local lDiff is LNGDiff(ship:GEOPOSITION,tGP).

	return BODY:ROTATIONPERIOD*lDiff/360.
}
local function OrbitOverAfter{
	parameter tGP, t.
	local nextOver is time+OrbitOver(tGP).
	local orbitStep is BODY:ROTATIONPERIOD/2.
	until nextOver > t {
		set nextOver to nextOver+orbitStep.
	}
	return nextOver.
}


function ToTime{
	parameter t.
	local tt is t-time.
	return FLOOR(tt:SECONDS/3600/6)+"d:"+tt:HOUR+"h:"+(t-time):MINUTE+"m:"+(t-time):SECOND+"s".
}

local function FindFlyOver{
	parameter timeOver, tGP.
	
	set timeOver to MinimalSeparationTime(timeOver, tGP).
	
	PRINT "Distance: " + SeparationV(timeOver,tGP):MAG.
	PRINT "Time: " + ToTime(timeOver).
	
	local search is MakeProgradeSearcher(Metric@,100,timeOver).
	
	function Metric{
		return SeparationNrm(search:TrgTime(), tGP):SQRMAGNITUDE+ABS(NEXTNODE:PROGRADE).
	}
	search:GO(0.1).
	
	PRINT "Distance: " + SeparationV(search:TrgTime(),tGP):MAG.
	PRINT "Time: " + ToTime(search:TrgTime()).
}

function FlyOver{
	local tGP is GetTargetGeo().
	local oP is ship:OBT:PERIOD.
	local orbitStep is BODY:ROTATIONPERIOD/2.
	local burnT is time + ETA:PERIAPSIS.
	local tT is OrbitOverAfter(tGP,burnT+oP+oP/2).
	
	ADD NODE(burnT:SECONDS,0,0,0).
	WAIT 0.
	
	FindFlyOver(tT,tGP).
}

