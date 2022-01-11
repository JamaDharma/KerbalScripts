RUNONCEPATH("0:/lib/Debug").
RUNONCEPATH("0:/lib/Atmosphere").
RUNONCEPATH("0:/lib/Ship/Engines").
RUNONCEPATH("0:/lib/Numerical/MidpointSolver").

local function SolveQuadratic {
	parameter pK, vK, aK.
	return (SQRT(2*aK*pK+vK*vK)+vK)/aK.	
}

function MakeAtmEntrySim{
	parameter dfc.
	parameter shipMass is MASS.
	 
	local exitHeight is 500.
	
	local shipMassK is 1/shipMass.
	local br is body:radius.
	local bm is V(0,0,-body:mu).
	local bw is body:ANGULARVEL:MAG.	

	local function Accel{
		parameter t,pos,vel.

		local cR is (br+pos:Z).
		local w is vel:Y.
		
		local orbV is V(w*cR,0,vel:Z).
		local atmV is V((w-bw)*cR,0,vel:Z).
		
		local gf is bm/(cR*cR).
		local cf is VCRS(orbV,V(0,w,0)).
		local spd is atmV:MAG.
		local ac is -dfc(t,pos:Z,spd)*shipMassK.
		local df is ac*atmV/spd.

		local totalF is gf+cf+df.
		
		return V(0,totalF:X/cR,totalF:Z).
	}
	
	local solver is 0.
	
	local function AtHeightParams {
		parameter st1, st2.
		
		local err is st2["P"]:Z-500.
		if ABS(err) < 1 return lexicon(
			"VX", (st2["V"]:Y-bw)*br,
			"VZ", st2["V"]:Z,
			"T", st2["T"],
			"X", (st2["P"]:Y-bw*st2["T"])*br,
			"Z", st2["P"]:Z
		).
		
		local timeErr is SolveQuadratic(st1["P"]:Z-500,st1["V"]:Z,st1["A"]:Z).
		local newSt is NewMidpoint1Solver(timeErr, Accel@)(st1).
		
		return AtHeightParams(newSt,newSt).
	}	
	
	local function GravTStep{
		parameter st.
		
		local newSt is solver(st).
		
		if newSt["P"]:Z < exitHeight	
			return AtHeightParams(st,newSt).

		return GravTStep(newSt).
	}

	local function SimState{
		parameter exitH, timeStep.
		parameter st.
		
		set exitHeight to exitH.
		set solver to NewMidpoint1Solver(timeStep, Accel@).
		set st["AX"] to 0.
		set st["AZ"] to 0.
		
		return GravTStep(lexicon(
			"T", st["T"],
			"P", V(st["X"],0,st["Z"]),
			"V", V(st["VX"],st["VX"]/(br+st["Z"]),st["VZ"]),
			"A", V(0,0,0)
		)).
	}

	return lexicon("FromState", SimState@).
}