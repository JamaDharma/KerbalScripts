//this will refine rough landing maneuver 
RUNONCEPATH("0:/lib/Debug").
RUNONCEPATH("0:/lib/Defaults").
RUNONCEPATH("0:/lib/Storage").
RUNONCEPATH("0:/lib/Ship/DeltaV").
RUNONCEPATH("0:/lib/Surface/KerbinPoints").
RUNONCEPATH("0:/lib/Surface/SurfaceAt").
RUNONCEPATH("0:/lib/Search/TragectoryImpactSearch").
RUNONCEPATH("0:/lib/Numerical/Chutes/ParachuteTrajectoryCalculator").
RUNONCEPATH("0:/lib/BurnExecutor").
//0.028 for big booster
//0.007 for medium
parameter dk is ShipTypeStorage():GetValue("DragK").

CORE:PART:CONTROLFROM().

local tgt is pad.
local massAfterBurn is MassAfter(NEXTNODE:DELTAV:MAG).
NPRINT("massAfterBurn",massAfterBurn).
local ptc is NewParachuteTrajectoryCalculator(dk,0.45,3000,massAfterBurn).
local sim is MakeAtmEntrySim(dk,massAfterBurn).
local br is BODY:RADIUS.
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
		"Z", upV:MAG-br).
}

local function AdjustTime{
	local simTime is TragectoryAltitudeTime(65000).
	
	local startState is StateAtT(simTime).
	local startGP is GeopositionAt(ship,simTime).
	
	local resultState is ptc(startState).
	local confrState is sim:FromStateToH(90,2,startState).
	NPRINT("LandingDistance0",confrState["X"]).
	NPrint("LandingDistance",resultState["X"]).
	NPrint("GlobeDistance",GlobeDistance(tgt,startGP)).
	local err is GlobeDistance(tgt,startGP)-resultState["X"].
	NPRINT("err",err).
	local timeAdj is err*(ALTITUDE+br)/(br*GROUNDSPEED).
	set NEXTNODE:ETA to NEXTNODE:ETA + timeAdj.
	NPRINT("timeAdj",timeAdj/60,3).
	WAIT 0.
	return err.
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

AdjustInclination().
until ABS(AdjustTime()) < 100 AdjustInclination().

function DeorbitBurnControl{
	parameter burn.
	
	local this is NodeBurnControl(burn).
	local startSpd is VELOCITYAT(ship, TIME+burn:ETA-1):SURFACE:MAG.
	NPrint("startSpd",startSpd).
	local speedK is 1-burn:DeltaV:MAG/(2*startSpd).
	NPrint("speedK",speedK).
	set this:BurnTiming to speedK*this:BurnLength.
	
	return this.
}
SAS OFF.
WAIT 0.
BurnExecutor(NodeBurnControl(NEXTNODE)).
set NAVMODE to "SURFACE".
SAS ON.
WAIT 0.1.
SET SASMODE TO "RETROGRADE".
WAIT 0.
local ss is lexicon(
		"VX", GROUNDSPEED,
		"VZ", VERTICALSPEED,
		"T", 0,
		"X", 0,
		"Z", ALTITUDE).
local gd is GlobeDistance(tgt,ship:GEOPOSITION).
local afterSt is NewParachuteTrajectoryCalculator(dk,0.36)(ss).
NPRINT("err",gd-afterSt["X"]).

RUN GuideToPad(gd-afterSt["X"],afterSt["ZP"]).