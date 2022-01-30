RUNONCEPATH("0:/lib/Debug").
RUNONCEPATH("0:/lib/Atmosphere").

function NewEntryEnvironment{
	parameter dragK.
	parameter shipMass is MASS.
	
	local dfc is MakeDragForceCalculator(KerbinAT,dragK).
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
		local cf is VCRS(orbV,V(0,w,0)).//hack - y ignored
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
	
	local function GetDistance{
		parameter sSt, eSt.
		return ((eSt["P"]-sSt["P"]):Y-(eSt["T"]-sSt["T"])*bw)*br.
	}
	
	return lexicon(
		"BodyR", br,
		"BodyW", bw,
		"ShipMass", shipMass,
		"DragK", dragK,
		"Accel", Accel@,
		"ConstructReturnState", ConstructReturnState@,
		"ConstructInnerState", ConstructInnerState@,
		"GetDistance", GetDistance@
	).
}

	
	