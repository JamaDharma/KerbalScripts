RUNONCEPATH("0:/lib/Debug").
RUNONCEPATH("0:/lib/Numerical/Chutes/ParachuteEnvironment").
RUNONCEPATH("0:/lib/Numerical/Entry/AtmosphericEntry").

function NewParachuteTrajectoryCalculator{
	parameter dragK,cuteK.
	parameter currChuteAlt is 3000.
	parameter m is MASS.
	
	local endVX is 0.2.
	local endVXMax is 0.3.
	
	local simE is MakeAtmEntrySim(dragK, m).
	local envP is NewParachuteEnvironment(dragK,cuteK,m).
	local Accel is envP["Accel"].
	local simP is NewSimulator(Accel).
	

	local function ExitCondition {
		parameter st.
		return st["V"]:X < endVX or st["P"]:Z < 200.
	}
	local function ChuteSim{
		parameter st.
		local pos is v(0,0,st["Z"]).
		local vel is v(st["VX"],0,st["VZ"]).
		local startSt is lexicon(
			"T",0,
			"P",pos,
			"V",vel,
			"A",Accel(0,pos,vel)
		).
		return simP:SimByFromCondition(1,startSt,ExitCondition@).
	}
	local function StoppingDistance {
		parameter st.
		// Dont'n remenber why but vx^2/ax
		return -st["V"]:X^2/st["A"]:X.
	}

	local function ChuteTrajectoryState{
		parameter startState is 0.
		
		local function ChuteTrajectory{
			parameter st.
			NPrint("currChuteAlt",currChuteAlt).
			local chuteSS is simE:FromStateToH(currChuteAlt,2,st).
			local chuteES is ChuteSim(chuteSS).
			if chuteES["P"]:Z > 200 {
				set currChuteAlt to currChuteAlt - chuteES["P"]:Z + 150.
				return ChuteTrajectory(chuteSS).
			}
			if chuteES["V"]:X > endVXMax {
				set currChuteAlt to currChuteAlt + 500.
				return ChuteTrajectory(startState).
			}
			local chuteDist is chuteES["P"]:X+StoppingDistance(chuteES).
			return lexicon (
				"X",chuteSS["X"]+chuteDist,
				"ZP",currChuteAlt,
				"XP",chuteDist
			).
		}
		
		return ChuteTrajectory(startState).
	}
	
	return ChuteTrajectoryState@.
}