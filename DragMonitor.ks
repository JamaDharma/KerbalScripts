RUNONCEPATH("0:/lib/Debug").
RUNONCEPATH("0:/lib/Numerical/MidpointSolver").
RUNONCEPATH("0:/lib/Numerical/AtmosphericEntry/AtmosphericEntry").



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

local dfc is MakeDragForceCalculator(KerbinAT,0.01).
local simA is MakeAtmEntrySim(dfc).
local simN is MakeAtmEntrySim({parameter d1,d2,d3. return 0. }).

function GetState{
	WAIT 0.
	return lexicon (
		"T", TIME:SECONDS,
		"X", 0,
		"Z", ALTITUDE,
		"VX", GROUNDSPEED,
		"VXO", VXCL(UP:VECTOR,ship:VELOCITY:ORBIT):MAG,
		"VZ", VERTICALSPEED
	).
}

local startState is GetState().
UNTIL false {
	WAIT 0.84.
	local newState is GetState().
	local dt is newState["T"]-startState["T"].
	local noAtm is simN:FromStateToT(newState["T"], 10, startState).
	local estS is simA:FromStateToT(newState["T"], 10, startState).

	local dAX is (newState["VXO"]-noAtm["VXO"]).
	local edAX is (estS["VXO"]-noAtm["VXO"]).
	local dAZ is (newState["VZ"]-noAtm["VZ"]).
	local edAZ is (estS["VZ"]-noAtm["VZ"]).
	NPrint("dt",dt).
	if ABS(edAX) > 0.00001 NPrint("vKX",dAX/edAX).
	if ABS(edAZ) > 0.00001 NPrint("vKZ",dAZ/edAZ).
	
	NPrintL(startState).
	NPrintL(noAtm).
	NPrintL(estS).
	NPrintL(newState).
	
	set startState to newState.
}