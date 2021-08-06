RUNONCEPATH("0:/lib/Debug").
RUNONCEPATH("0:/lib/Storage").
RUNONCEPATH("0:/lib/SurfaceAt").
RUNONCEPATH("0:/lib/Atmosphere").
RUNONCEPATH("0:/lib/AtmosphericEntry").

local chuteDelay is 1.
global pad is BODY:GEOPOSITIONLATLNG(-0.0972077889151947,-74.5576774701971).

local dk is ShipTypeStorage():GetValue("DragK").
local sdk is 0.06.//ShipTypeStorage():GetValue("ChuteDragK").
local dfc is MakeDragForceCalculator(KerbinAT,dk).
local sfc is MakeDragForceCalculator(KerbinAT,sdk).
local simFree is MakeAtmEntrySim(dfc).
local simChute is MakeAtmEntrySim(sfc).

local endGP is 0.
local err is 0.

function ChuteBrackingEstimate{
	local beforeChute is simFree:FromState(
		{parameter vx,vz,cml. return cml[0] >= chuteDelay.},
		chuteDelay+0.1,
		lexicon(
			"VX", GROUNDSPEED,
			"VZ", VERTICALSPEED,
			"T", 0,
			"X", 0,
			"Z", ALTITUDE)
		).
	local resultState is simChute:FromState(
		{parameter vx,vz,cml. return cml[2] <= 100 OR vx <= 33.},
		0.25,
		beforeChute
		).
	return resultState["X"].
}