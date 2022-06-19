//lib for correction to fly over specific point while on polar orbit.
RUNONCEPATH("0:/lib/Debug").
RUNONCEPATH("0:/lib/Targeting").
RUNONCEPATH("0:/lib/Surface/SurfaceAt").
RUNONCEPATH("0:/lib/Search/BinarySearch").
RUNONCEPATH("0:/lib/Search/GoldenSearch").
RUNONCEPATH("0:/lib/Search/ManeuverSearch").

local function LNGDiff{
	parameter gpO, gpG.
	local lDiff is gpO:LNG - gpG:LNG.
	if lDiff < 0 set lDiff to lDiff + 180.
	if lDiff > 180 set lDiff to lDiff - 180.
	return lDiff.
}

local function Separation{
	parameter tT,tGP.
	return GlobeDistance(GeopositionAt(ship, tT),tGP).
}

local function MinimalSeparationTime{
	parameter minSepTime, tGP.

	GSearch(
		{ return Separation(minSepTime,tGP).},
		MakeSearchComponent( 1, 0.1, {parameter dT. set minSepTime to minSepTime + dT.})
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

local function FindFlyOverPolar{
	parameter timeOver, tGP.
	
	set timeOver to MinimalSeparationTime(timeOver, tGP).
	
	PRINT "Distance: " + Separation(timeOver,tGP).
	PRINT "Time: " + ToTime(timeOver).
	
	local search is MakeProgradeSearcher(Metric@,100,timeOver).
	
	function Metric{
		return Separation(search:TrgTime(), tGP)+ABS(NEXTNODE:PROGRADE).
	}
	search:GO(0.1).
	
	PRINT "Distance: " + Separation(search:TrgTime(),tGP).
	PRINT "Time: " + ToTime(search:TrgTime()).
}

function FlyOverPolar{
	local tGP is GetTargetGeo().
	local oP is ship:OBT:PERIOD.
	local orbitStep is BODY:ROTATIONPERIOD/2.
	local burnT is time + ETA:PERIAPSIS.
	local tT is OrbitOverAfter(tGP,burnT+oP+oP/2).
	
	ADD NODE(burnT:SECONDS,0,0,0).
	WAIT 0.
	
	FindFlyOverPolar(tT,tGP).
}

local function FindFlyOverM{
	parameter timeOver, tGP.
	
	set timeOver to MinimalSeparationTime(timeOver, tGP).
	
	PRINT "Distance: " + Separation(timeOver,tGP).
	PRINT "Time: " + ToTime(timeOver).
	
	local search is MakeMSearcher(Metric@,100,timeOver).
	
	function Metric{
		return Separation(search:TrgTime(), tGP)+ABS(NEXTNODE:PROGRADE).
	}
	search:GO(0.1).
	
	PRINT "Distance: " + Separation(search:TrgTime(),tGP).
	PRINT "Time: " + ToTime(search:TrgTime()).
}
//Searches for fly over target by adjusting naneuver  
function FlyOverM{
	local tGP is GetTargetGeo().
	local oP is ship:OBT:PERIOD.
	parameter tOver is NEXTNODE:ETA+oP/4.

	local tT is MinimalSeparationTime(time+tOver, tGP).
	PRINT (tT-time):seconds/60.
	WAIT 0.
	
	FindFlyOverM(tT,tGP).
}

