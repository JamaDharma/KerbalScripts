RUNONCEPATH("0:/lib/Debug").
RUNONCEPATH("0:/lib/Numerical/Simulator").
RUNONCEPATH("0:/lib/Numerical/Entry/EntryEnvironment").
RUNONCEPATH("0:/lib/Numerical/Entry/GuideLineCalculator").

function MakeAtmEntrySim{
	parameter dragK.
	parameter shipMass is MASS.
	
	local env is NewEntryEnvironment(dragK,shipMass).
	local Accel is env["Accel"].
	local GetDistance is env["GetDistance"].
	local ConstructReturnState is env["ConstructReturnState"].
	local CurrentStateInner is env["CurrentStateInner"].
	local ConstructInnerState is env["ConstructInnerState"].
	
	local sim is NewSimulator(Accel).
	local NStepsToH is sim["NStepsToH"].
	local SimToHFrom is sim["SimToHFrom"].

	local function CurrentIf0{
		parameter st.
		if st = 0 
			return CurrentStateInner().
		return ConstructInnerState(st).
	}
	
	local function SimToH{
		parameter exitH, timeStep.
		parameter st.
		
		local startSt is CurrentIf0(st).
		local endSt is sim["SimToHByFrom"](exitH,timeStep,startSt).
		return ConstructReturnState(endSt).
	}
	
	local function SimToT{
		parameter exitT, timeStep.
		parameter st.
		
		local startSt is ConstructInnerState(st).
		local endSt is sim["SimToT"](exitT,timeStep,startSt).
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
		parameter st is 0.
		
		local startSt is CurrentIf0(st).
		local traj is sim["TrajectoryToH"](exitH,timeStep,startSt).
		local glData is NewGuideLineCalculator(env,timeStep)(traj).
		
		InitEntryGuide(glData).
		return glData.
	}
	local function EntryGuide{
		parameter timeStep, st is 0.
		if guideLineDataProvider = 0 return 0.
		local startSt is CurrentIf0(st).
		local guideE is guideLineDataProvider(startSt["P"]:Z).
		local endSt is sim["SimToHByFrom"](guideE["Z"],timeStep,startSt).
		local guideX is guideE["X"]+guideE["D"]*(endSt["V"]-guideE["V"]).
		local stepX is GetDistance(startSt,endSt).
		return guideX+stepX.
	}


	return lexicon(
		"InitEntryGuide", InitEntryGuide@,
		"MakeEntryGuide", MakeEntryGuide@,
		"EntryGuide", EntryGuide@,
		"FromStateToH", SimToH@,
		"FromStateToT", SimToT@
	).
}
	
	