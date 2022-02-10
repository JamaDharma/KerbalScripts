RUNONCEPATH("0:/lib/Debug").
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
		}
	}
}
InverseControl().
WAIT 0.1.

function GetState{
	WAIT 0.
	return lexicon (
		"T", TIME:SECONDS,
		"Q", SHIP:Q,
		"X", 0,
		"Z", ALTITUDE,
		"V", AIRSPEED,
		"VX", GROUNDSPEED,
		"VZ", VERTICALSPEED
	).
}

UNTIL false {
	WAIT 1.
	local newState is GetState().
	
	local pQ is 2000*constant:AtmToKPa*newState["Q"]/newState["V"]^2.
	local pE is AtmDensity(KerbinAT,newState["Z"]).
	
	NPrint("pQ",pQ,6).
	NPrint("pE",pE,6).
}