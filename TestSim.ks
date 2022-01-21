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

function GetResultState{
	parameter timestep is 1.
	local calcT is time:SECONDS.
	local result is sim:FromStateToH(
		targetHeight,
		timestep,
		lexicon(
			"VX", hspd,
			"VZ", vspd,
			"T", 0,
			"X", 0,
			"Z", altd)
	).
	set calcT to time:SECONDS-calcT.
	NPrint("timestep",timestep).
	NPrint("calcTime",calcT).
	NPrint("estDist",result["X"]).
	
	return result.
}
local result is GetResultState(0.25).
NPrint("estHeight",result["Z"]).
NPrint("estHSpeed",result["VX"]).
NPrint("estVSpeed",result["VZ"]).
NPrint("estTime",result["T"]).
GetResultState(0.5).
GetResultState(1).
GetResultState(2).
GetResultState(4).