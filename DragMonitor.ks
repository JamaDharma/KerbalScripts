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
WAIT 0.1.

local sKTable is list().

set TERMINAL:WIDTH to 80.
local dfc is MakeDragForceCalculator(KerbinAT,0.01).
local simN is MakeAtmEntrySim({parameter d1,d2,d3. return 0.}).
local simA is MakeAtmEntrySim(dfc).
local simV is MakeAtmEntrySim({
	parameter ct,ca,cs.
	return AtmDensity(SpeedKT,cs)*dfc(ct,ca,cs).
}).



function GetState{
	WAIT 0.
	local oV is ship:VELOCITY:ORBIT.
	return lexicon (
		"T", TIME:SECONDS,
		"X", 0,
		"Z", ALTITUDE,
		"VX", GROUNDSPEED,
		"VXO", VXCL(UP:VECTOR,oV):MAG,
		"VZ", UP:VECTOR*oV,
		"V", AIRSPEED
	).
}
local tStep is 0.25.
local startState is GetState().
UNTIL false {
	local newState is GetState().
	local dt is newState["T"]-startState["T"].
	local noAtm is simN:FromStateToT(newState["T"], tStep, startState).
	local estS is simA:FromStateToT(newState["T"], tStep, startState).
	local estSV is simV:FromStateToT(newState["T"], tStep, startState).

	local dVX is (newState["VXO"]-startState["VXO"]).
	local drAX is (newState["VXO"]-noAtm["VXO"]).
	local edAX is (estS["VXO"]-noAtm["VXO"]).
	local eeX is (newState["VXO"]-estS["VXO"]).
	
	local dVZ is (newState["VZ"]-startState["VZ"]).
	local drAZ is (newState["VZ"]-noAtm["VZ"]).
	local edAZ is (estS["VZ"]-noAtm["VZ"]).
	local eeZ is (newState["VZ"]-estS["VZ"]).
	local eeZV is (newState["VZ"]-estSV["VZ"]).
	

	if startState["V"] < 500 AND startState["V"] > 200 {
		sKTable:INSERT(0,list(startState["V"],drAZ/edAZ)).
	}
	
	if AIRSPEED < 250 {
		CHUTES ON.
		local outT is "".
		for entry in sKTable {
			set outT to outT + ROUND(entry[0],1)+","+
				ROUND(entry[1],3)+char(10).
		}
		LOG outT TO "SKTable.txt".
		WAIT 10.
		PRINT 0/0.
	}
	
	if ABS(edAX) > 0.00001 NPrint("vKX",drAX/edAX).
	if ABS(edAZ) > 0.00001 NPrint("vKZ",drAZ/edAZ).
	
	set startState to newState.
}