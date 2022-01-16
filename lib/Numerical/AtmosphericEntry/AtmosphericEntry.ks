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
	
	local shipMassK is 1/shipMass.
	local br is body:radius.
	local bm is V(0,0,-body:mu).
	local bw is body:ANGULARVEL:MAG.	

	local function Accel{
		parameter t,pos,orbV.

		local cR is (br+pos:Z).
		local cR2R is 1/(cR*cR).
		local w is orbV:Y.
		
		set orbV:X to w*cR.
		local atmV is V((w-bw)*cR,0,orbV:Z).
		
		local gf is bm*cR2R.
		local cf is VCRS(orbV,V(0,w,0)).//hack,y ignored
		local spd is atmV:MAG.
		local ac is -dfc(t,pos:Z,spd)*shipMassK.
		local df is ac*atmV/spd.

		local totalF is gf+cf+df.
		set totalF:Y to (totalF:X*cR-orbV:X*orbV:Z)*cR2R.
		
		return totalF.
	}
	
	local function ConstructReturnState{
		parameter st.
		local cr is br+st["P"]:Z.
		return lexicon(
			"T", st["T"],
			"X", (st["P"]:Y-bw*st["T"])*br,
			"Z", st["P"]:Z,
			"VX", (st["V"]:Y-bw)*cr,
			"VXO", st["V"]:Y*cr,
			"VZ", st["V"]:Z
		).
	}
	
	local function ConstructInnerState{
		parameter st.
		local cr is br+st["Z"].
		local ip is V(st["X"],st["X"]/br,st["Z"]).
		local iv is 0.
		if st:HASKEY("VXO") 
			set iv to V(st["VXO"],st["VXO"]/cr,st["VZ"]).
		else
			set iv to V(st["VX"]+cr*bw,st["VX"]/cr+bw,st["VZ"]).
		return lexicon(
			"T", st["T"],
			"P", ip,
			"V", iv,
			"A", Accel(st["T"],ip,iv)
		).
	}
	
	local function AtHeightState {
		parameter st1, st2.
		
		local err is st2["P"]:Z-500.
		if ABS(err) < 1 return ConstructReturnState(st2).
		
		local timeErr is SolveQuadratic(st1["P"]:Z-500,st1["V"]:Z,st1["A"]:Z).
		local newSt is NewMidpoint1Solver(timeErr, Accel@)(st1).
		
		return AtHeightState(newSt,newSt).
	}	
	
	local function SimToH{
		parameter exitH, timeStep.
		parameter st.
		
		local solver to NewMidpoint1Solver(timeStep, Accel@).
		local oldSt is ConstructInnerState(st).
		local currSt is oldSt.
		
		until currSt["P"]:Z < exitH {
			set oldSt to currSt.
			set currSt to solver(oldSt).
		}
		
		return AtHeightState(oldSt,currSt).
	}
	
	local function SimToT{
		parameter exitT, timeStep.
		parameter st.
		
		local solver to NewMidpoint1Solver(timeStep, Accel@).
		local currSt is ConstructInnerState(st).
		
		until currSt["T"]+timeStep > exitT {
			set currSt to solver(currSt).
		}
		
		return ConstructReturnState(
			NewMidpoint1Solver(exitT-currSt["T"], Accel@)(currSt)
		).
	}

	return lexicon(
		"FromStateToH", SimToH@,
		"FromStateToT", SimToT@,
		"FromState", SimToH@).
}