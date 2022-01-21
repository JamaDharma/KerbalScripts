RUNONCEPATH("0:/lib/Debug").
RUNONCEPATH("0:/lib/Storage").
RUNONCEPATH("0:/lib/SurfaceAt").
RUNONCEPATH("0:/lib/Search/TragectoryImpactSearch").
RUNONCEPATH("0:/lib/Atmosphere").
RUNONCEPATH("0:/lib/Numerical/AtmosphericEntry/AtmosphericEntry").

local targetHeight is 500.

local hspd is 1497.7.
local vspd is -338.2.
local altd is 60046.
local shipMass is 50.56.

local dfc is MakeDragForceCalculator(KerbinAT,0.01).
local sim is MakeAtmEntrySim(dfc,shipMass).

//CLEARSCREEN.

NPrint("shipMass",shipMass).
NPrint("hspd",hspd).
NPrint("vspd",vspd).
NPrint("altd",altd).

local startState is lexicon(
			"VX", hspd,
			"VZ", vspd,
			"T", 0,
			"X", 0,
			"Z", altd).
			
local calcT is time:SECONDS.
local simRes is sim:FromStateToH(	targetHeight,2,startState).
set calcT to time:SECONDS-calcT.
NPrint("SimCalcTime",calcT).
NPrint("estDist",simRes["X"]).
set calcT to time:SECONDS.
local guide is sim:MakeEntryGuide(targetHeight,2,startState).
set calcT to time:SECONDS-calcT.
NPrint("GuideCalcTime",calcT).
NPrint("estDist",guide[0]["X"]).

local function TestGuideXZ{
	parameter tge, eX, eZ.
	
	local resultE is sim:FromStateToH(
	targetHeight,2,lexicon(
		"VXO", tge["V"]:X+eX,
		"VZ", tge["V"]:Z+eZ,
		"T", 0,
		"X", 0,
		"Z", tge["Z"])
	).
	local guideE is tge["X"]+tge["D"]*V(0,eX/(body:RADIUS+tge["Z"]),eZ).
	NPrintL(lexicon(
		"Guide0",tge["X"],
		"ErrX", eX,
		"ErrZ", eZ,
		"Guide",guideE,
		"Result",resultE["X"],
		"Diff",ABS(resultE["X"]-guideE),
		"RelDiff",ABS(resultE["X"]-guideE)/ABS(resultE["X"]-tge["X"])
	),3).
}
local function TestGuideE{
	parameter tge.
	TestGuideXZ(tge,-1,-1).
	TestGuideXZ(tge,1,1).
	TestGuideXZ(tge,5,5).
	TestGuideXZ(tge,10,10).
}
NPrint("GuideLenght",guide:LENGTH).
//TestGuideE(guide[0]).
//TestGuideE(guide[10]).
//TestGuideE(guide[20]).
//TestGuideE(guide[30]).
PRINT sim:EntryGuide(2,lexicon(
			"VX", hspd-2,
			"VZ", vspd+1,
			"T", 0,
			"X", 0,
			"Z", altd-500)).
PRINT sim:FromStateToH(500,2,lexicon(
			"VX", hspd-2,
			"VZ", vspd+1,
			"T", 0,
			"X", 0,
			"Z", altd-500))["X"].

