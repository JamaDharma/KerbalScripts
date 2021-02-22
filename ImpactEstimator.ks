RUNONCEPATH("0:/lib/Debug").
RUNONCEPATH("0:/lib/SurfaceAt").
RUNONCEPATH("0:/lib/Search/TragectoryImpactSearch").
RUNONCEPATH("0:/lib/Atmosphere").
RUNONCEPATH("0:/lib/AtmosphericEntry").

local targetHeight is 300.
global pad is BODY:GEOPOSITIONLATLNG(-0.0972077889151947,-74.5576774701971).
local chainLink is PROCESSOR("Slave2"):CONNECTION.

local dfc is MakeDragForceCalculator(KerbinAT,0.028).
local sim is MakeAtmEntrySim(dfc).

local endGP is 0.
local err is 0.

local function UpdateEstimate{
	local startGP is ship:GEOPOSITION. 
	local resultState is sim:FromState(
		{parameter vx,vz,cml. return cml[2] <= targetHeight.},
		1,
		lexicon(
			"VX", GROUNDSPEED,
			"VZ", VERTICALSPEED,
			"T", 0,
			"X", 0,
			"Z", ALTITUDE)
		).
	set endGP to GlobeAddDistance(startGP,resultState["X"]).
	return GlobeDistance(pad,startGP)-resultState["X"].
}

set err to UpdateEstimate().
CLEARVECDRAWS().
set estimatedImpact to VECDRAW(
	{ return endGP:ALTITUDEPOSITION(0).},
	{ return endGP:ALTITUDEPOSITION(0)-BODY:POSITION. },
	RED,"",5,true).

UNTIL ALTITUDE < 1000 {
	set err to UpdateEstimate().
	chainLink:SENDMESSAGE(err).
	WAIT 0.
}