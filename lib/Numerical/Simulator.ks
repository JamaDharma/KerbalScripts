RUNONCEPATH("0:/lib/Debug").
RUNONCEPATH("0:/lib/Numerical/Solvers").

local function SolveQuadratic {
	parameter pK, vK, aK.
	return (SQRT(2*aK*pK+vK*vK)+vK)/aK.	
}

local function SolveHalley {
	parameter pK, vK, aK.
	return -2*pK*vK/(2*vK*vk-pK*aK).	
}

function NewSimulator{
	parameter accelCalc.
	parameter dfltStep is 2.
	parameter solverMaker is NewRunge4Solver@.
	parameter rootFinder is SolveQuadratic@.
	
	local dfltSolver is solverMaker(dfltStep,accelCalc).
	
	local function EulerStep {
		parameter tgtHgh, st.
		local ma is st["A"].
		local timeErr is rootFinder(st["P"]:Z-tgtHgh,st["V"]:Z,ma:Z).
		return lexicon(
			"T",st["T"]+timeErr,
			"P",st["P"]+(st["V"]+ma*timeErr/2)*timeErr,
			"V",st["V"]+ma*timeErr,
			"A",ma
		).
	}
	
	local function StepToAlt {
		parameter tgtHgh, st1, st2 is st1.
		
		local err is st2["P"]:Z-tgtHgh.
		if ABS(err) < 10 return EulerStep(tgtHgh,st2).
		
		local timeErr is rootFinder(st1["P"]:Z-tgtHgh,st1["V"]:Z,st1["A"]:Z).
		
		local newSt is solverMaker(timeErr, accelCalc)(st1).
		
		return StepToAlt(tgtHgh,newSt).
	}	
		
	local function SimToHLong{
		parameter exitH, timeStep.
		parameter st.
		
		local solver to solverMaker(timeStep, accelCalc).
 		local oldSt is st.
		local currSt is oldSt.
		
		until currSt["P"]:Z < exitH {
			set oldSt to currSt.
			set currSt to solver(oldSt).
		}
		
		return StepToAlt(exitH,oldSt,currSt).
	}
	
	local function SimToHFrom{
		parameter exitH.
		parameter currSt.
		
		until currSt["P"]:Z+timeStep*currSt["V"]:Z < exitH {
			set currSt to dfltSolver(currSt).
		}
		
		return StepToAlt(exitH,currSt).
	}
	
	local function SimToHByFrom{
		parameter exitH, timeStep.
		parameter currSt.
		
		local solver to solverMaker(timeStep, accelCalc).
		
		until currSt["P"]:Z+timeStep*currSt["V"]:Z < exitH {
			set currSt to solver(currSt).
		}
		
		return StepToAlt(exitH,currSt).
	}
	
	local function NStepsToHR{
		parameter n.
		parameter exitH.
		parameter currSt.
		
		if n = 0 
			return StepToAlt(exitH,currSt).
			
		return NStepsToH(n-1, exitH, dfltSolver(currSt)).
	}
	local function NStepsToHI{
		parameter n.
		parameter exitH.
		parameter currSt.
		
		until n = 0 {
			set currSt to dfltSolver(currSt).
			set n to n-1.
		}
		
		return StepToAlt(exitH,currSt).
	}
	local function Traj2ToH{
		parameter exitH, timeStep.
		parameter st.
		
		local solver to solverMaker(timeStep, accelCalc).
		local result is list(st).
		local currSt is st.
		until currSt["P"]:Z < exitH {
			result:ADD(currSt).
			set currSt to solver(currSt).
		}
		result:ADD(StepToAlt(exitH,result[result:LENGTH-1],currSt)).
		
		local count is MOD(result:LENGTH-1,2).
		local result2 is list().
		until count >= result:LENGTH {
			result2:ADD(result[count]).
			set count to count+2.
		}

		return result2.
	}
	
	local function SimToT{
		parameter exitT, timeStep.
		parameter st.
		
		local solver to solverMaker(timeStep, accelCalc).
		local currSt is st.
		
		until currSt["T"]+timeStep > exitT {
			set currSt to solver(currSt).
		}
		
		return solverMaker(exitT-currSt["T"], accelCalc)(currSt).
	}

	return lexicon(
		"OneStepToH", StepToAlt@,
		"TrajectoryToH", Traj2ToH@,
		"SimToHLong", SimToHLong@,
		"SimToHFrom", SimToHFrom@,
		"SimToHByFrom", SimToHByFrom@,
		"NStepsToH", NStepsToHI@,
		"SimToT", SimToT@
	).
}
