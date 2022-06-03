//Landing error monitor
RUNONCEPATH("0:/lib/Debug").
RUNONCEPATH("0:/lib/Surface/SurfaceAt").
RUNONCEPATH("0:/lib/Numerical/Entry/AtmosphericEntry").



function InverseControl {
	LIST PARTS IN  partList.	
	local fName is "authority limiter".
	for prt in partList
	if prt:HASMODULE("ModuleControlSurface") {
		
		local mdl is prt:getmodule("ModuleControlSurface").
		
		if mdl:HasField(fName){
			local angle is mdl:getfield(fName).
			mdl:setfield(fName, -100).
			PRINT angle.
		}
	}
}
InverseControl().
WAIT 0.5.

global pad is BODY:GEOPOSITIONLATLNG(-0.0972077889151947,-74.5576774701971).

local tgt is pad.
local sim is MakeAtmEntrySim(0.01).

function GetState{
	WAIT 0.
	return lexicon (
		"T", 0,
		"X", 0,
		"Z", ALTITUDE,
		"V", AIRSPEED,
		"VX", GROUNDSPEED,
		"VZ", VERTICALSPEED,
		"GP", ship:GEOPOSITION
	).
}

function GetResultState{
	local sState is GetState().
	local result is sim:FromStateToH(100,1,sState).
	local err is GlobeDistance(tgt,sState["GP"])-result["X"].
	
	NPrintL(lexicon("err",err,"spd",sState["V"])).

	return result.
}
UNTIL false {
	WAIT 0.5.
	GetResultState().	
}