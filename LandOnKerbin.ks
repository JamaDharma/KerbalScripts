RUNONCEPATH("0:/lib/Debug").
RUNONCEPATH("0:/lib/Defaults").
RUNONCEPATH("0:/lib/Storage").
RUNONCEPATH("0:/lib/SurfaceAt").
RUNONCEPATH("0:/lib/Search/TragectoryImpactSearch").
RUNONCEPATH("0:/lib/Atmosphere").
RUNONCEPATH("0:/lib/AtmosphericEntry").
//0.028 for big booster
//0.007 for medium
parameter dk is ShipTypeStorage():GetValue("DragK").

CORE:PART:CONTROLFROM().
local targetHeight is 1000.
global pad is BODY:GEOPOSITIONLATLNG(-0.0972077889151947,-74.5576774701971).

local tgt is pad.
local dfc is MakeDragForceCalculator(KerbinAT,dk).
local sim is MakeAtmEntrySim(dfc).

local function StateAtT{
	parameter t.
	local pos is POSITIONAT(SHIP,t).
	local vel is VELOCITYAT(SHIP,t).
	local bp is BODY:POSITION.

	local upV is pos-bp.
	local sv is vel:SURFACE.
	
	return 	lexicon(
		"VX", VXCL(upV,sv):MAG,
		"VZ", upV:NORMALIZED*sv,
		"T", 0,
		"X", 0,
		"Z", upV:MAG-BODY:RADIUS).
}

local function AdjustTime{
	local time50 is TragectoryAltitudeTime(50000).
	NPrint("time50",(time50-time):SECONDS/60).
	local startState is StateAtT(time50).
	local startGP is GeopositionAt(ship,time50).

	local resultState is sim:FromState(
		{parameter vx,vz,cml. return cml[2] <= 500.},
		1,startState).
		
	NPrint("X",resultState["X"]).
	NPrint("GlobeDistance",GlobeDistance(tgt,startGP)).
	local err is GlobeDistance(tgt,startGP)-resultState["X"].
	NPRINT("err",err).
	set NEXTNODE:ETA to NEXTNODE:ETA + err/groundspeed.
}

local function AdjustInclination{
	local tT is time.
	function Metric{
		return GlobeDistance(GeopositionAt(ship, tT),tgt).
	}
	GSearch( Metric@,
		MakeSearchComponent( 1, 0.1, {parameter dT. set tT to tT + dT.})
	).
	GSearch( Metric@,
		MakeSearchComponent( 1, 0.01, 
		{ parameter dX. set NEXTNODE:NORMAL to NEXTNODE:NORMAL+dX. })
	).
}

AdjustTime().
AdjustInclination().
AdjustTime().