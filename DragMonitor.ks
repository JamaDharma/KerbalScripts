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

function Gravity {
	local br is body:radius+ALTITUDE.
	local ohs is VXCL(UP:VECTOR,ship:VELOCITY:ORBIT):MAG.
	return body:mu/(br*br)-ohs*ohs/br.
}

function GetState{
	WAIT 0.
	return lexicon (
		"T", TIME:SECONDS,
		"X", 0,
		"Z", ALTITUDE,
		"VX", GROUNDSPEED,
		"VZ", VERTICALSPEED,
		"g", Gravity()
	).
}

local function Accel{
	parameter t,x,z,vx,vz.
	
	local w is vx/(body:radius+x).

	local spd is SQRT(vx^2+vz^2).
	local ac is -dfc(t,z,spd)*shipMassK.
	local sk is ac/spd.

	return lexicon(
		"AX", vx*sk - 2*vz*w,
		"AZ", vz*sk - startState["g"]
	).
}

local shipMassK is 1/MASS.
local dfc is MakeDragForceCalculator(KerbinAT,0.01).
local solver is MakeMidpoint1Solver()["AdvanceStateT"].

WAIT UNTIL ALTITUDE < 50000.

local startState is GetState().
UNTIL false {
	WAIT 0.84.
	local newState is GetState().
	local dt is newState["T"]-startState["T"].
	local estS is solver(Accel@, startState, dt).
	local oAX is (newState["VX"]-startState["VX"])/dt.
	local oAZ is (newState["VZ"]-startState["VZ"])/dt-startState["g"].
	NPrint("dt",dt).
	NPrint("vKX",oAX/estS["AX"]).
	NPrint("vKZ",oAZ/(estS["AZ"]-startState["g"])).
	NPrintL(startState).
	NPrintL(newState).
	NPrintL(estS).
	set startState to newState.	
}