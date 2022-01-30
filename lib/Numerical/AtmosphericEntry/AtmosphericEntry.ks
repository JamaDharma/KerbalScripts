RUNONCEPATH("0:/lib/Debug").
RUNONCEPATH("0:/lib/Numerical/Simulator").
RUNONCEPATH("0:/lib/Numerical/AtmosphericEntry/EntryEnvironment").
RUNONCEPATH("0:/lib/Numerical/AtmosphericEntry/GuideLineCalculator").

function MakeAtmEntrySim{
	parameter dragK.
	parameter shipMass is MASS.
	
	local env is NewEntryEnvironment(dragK,shipMass).
	local Accel is env["Accel"].
	local ConstructReturnState is env["ConstructReturnState"].
	local ConstructInnerState is env["ConstructInnerState"].
	local Accel is env["Accel"].
	
	local sim is NewSimulator(Accel).
	local NStepsToH is sim["NStepsToH"].
	local SimToHFrom is sim["SimToHFrom"].

	local function SimToH{
		parameter exitH, timeStep.
		parameter st.
		
		local startSt is ConstructInnerState(st).
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
		parameter st.
		
		local startSt is ConstructInnerState(st).
		local traj is sim["TrajectoryToH"](exitH,timeStep,startSt).
		local glData is NewGuideLineCalculator(env,timeStep)(traj).
		
		InitEntryGuide(glData).
		return glData.
	}
	local function EntryGuide{
		parameter timeStep, st.
		
		local startSt is ConstructInnerState(st).
		local guideE is guideLineDataProvider(startSt["P"]:Z).
		local endSt is sim["SimToHByFrom"](guideE["Z"],timeStep,startSt).
		local guideX is guideE["X"]+guideE["D"]*(endSt["V"]-guideE["V"])..
		local stepX is ConstructReturnState(endSt)["X"].
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
	
	