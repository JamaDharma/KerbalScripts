RUNONCEPATH("0:/lib/Debug").
RUNONCEPATH("0:/lib/Atmosphere").
RUNONCEPATH("0:/lib/Ship/Engines").
RUNONCEPATH("0:/lib/Numerical/Simulator").
RUNONCEPATH("0:/lib/Numerical/AtmosphericEntry/GuideLineCalculator").

function MakeAtmEntrySim{
	parameter dfc.
	parameter shipMass is MASS.
	
	local shipMassK is 1/shipMass.
	local br is body:radius.
	local bm is V(0,0,-body:mu).
	local bw is body:ANGULARVEL:MAG.	
	local es is NewSimulator(Accel@).
	
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
	
	local function SimToH{
		parameter exitH, timeStep.
		parameter st.
		
		local startSt is ConstructInnerState(st).
		local endSt is es["SimToHByFrom"](exitH,timeStep,startSt).
		return ConstructReturnState(endSt).
	}
	
	local function SimToT{
		parameter exitT, timeStep.
		parameter st.
		
		local startSt is ConstructInnerState(st).
		local endSt is es["SimToT"](exitT,timeStep,startSt).
		return ConstructReturnState(endSt).
	}
	
	local guideLineDataProvider is 0.
	local function InitEntryGuide{
		parameter guideLineData.
		set guideLineDataProvider to 
			NewGuideLineDataProvider(guideLineData).
	}
	local function MakeEntryGuide{
		parameter exitH, timeStep.
		parameter st.
		
		local startSt is ConstructInnerState(st).
		local traj is es["TrajectoryToH"](exitH,timeStep,startSt).
		local glData is NewGuideLineCalculator(Accel@,timeStep)(traj).
		
		InitEntryGuide(glData).
		return glData.
	}
	local function EntryGuide{
		parameter timeStep, st.
		
		local startSt is ConstructInnerState(st).
		local guideE is guideLineDataProvider(startSt["P"]:Z).
		local endSt is es["SimToHByFrom"](guideE["Z"],timeStep,startSt).
		local guideX is guideE["X"]+guideE["D"]*(endSt["V"]-guideE["V"])..
		local stepX is ConstructReturnState(endSt)["X"].
		return guideX+stepX.
	}


	return lexicon(
		"MakeEntryGuide", MakeEntryGuide@,
		"EntryGuide", EntryGuide@,
		"FromStateToH", SimToH@,
		"FromStateToT", SimToT@
	).
}
	
	