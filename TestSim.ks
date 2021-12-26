RUNONCEPATH("0:/lib/Debug").
RUNONCEPATH("0:/lib/Storage").
RUNONCEPATH("0:/lib/SurfaceAt").
RUNONCEPATH("0:/lib/Search/TragectoryImpactSearch").
RUNONCEPATH("0:/lib/Atmosphere").
RUNONCEPATH("0:/lib/AtmosphericEntry").

local targetHeight is 500.
local pad is BODY:GEOPOSITIONLATLNG(-0.0972077889151947,-74.5576774701971).
local dfc is MakeDragForceCalculator(KerbinAT,0.01).
local sim is MakeAtmEntrySim(dfc).

WAIT UNTIL ALTITUDE < 60050.
local hspd is GROUNDSPEED. //1497.7
local vspd is VERTICALSPEED. //338.2
local altd is ALTITUDE. //6046
local startGP is ship:GEOPOSITION.
local shipMass is MASS.//50.56
local startDist is GlobeDistance(pad,startGP).
NPrint("shipMass",shipMass).
NPrint("hspd",hspd).
NPrint("vspd",vspd).
NPrint("altd",altd).
NPrint("startDist",startDist).

function GetResultState{
	parameter timestep is 1.
	return sim:FromState(
		{parameter vx,vz,cml. return cml[2] <= targetHeight.},
		timestep,
		lexicon(
			"VX", hspd,
			"VZ", vspd,
			"T", 0,
			"X", 0,
			"Z", altd)
	).
}
local calcT is time:SECONDS.
local resultState is GetResultState(0.25).
NPrint("calcTime",time:SECONDS-calcT).//16.36, 530 steps 0.03/step
NPrint("estTime",resultState["T"]).//132.5
NPrint("estErr",startDist-resultState["X"]).//1:2002,0.25:2041
NPrint("estDist0.25",resultState["X"]).//150376
NPrint("estDist0.5",GetResultState(0.5)["X"]).//150390
NPrint("estDist1",GetResultState(1)["X"]).//150415	
NPrint("estDist2",GetResultState(2)["X"]).//150447
NPrint("estDist4",GetResultState(4)["X"]).//150442	
WAIT UNTIL ALTITUDE < 505.
local endGP is ship:GEOPOSITION.
local endErr is GlobeDistance(pad,endGP).
NPrint("endErr",endErr).//2249