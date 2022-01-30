RUNONCEPATH("0:/lib/Debug").
RUNONCEPATH("0:/lib/Numerical/Simulator").

function NewGuideLineCalculator{
	parameter env.
	parameter timeStep is 2.
	
	local dY is 1/env["BodyR"].
	local dZ is 1.
	local adjVY is v(0,dY,0).
	local adjVZ is v(0,0,dZ).
	
	local accelCalc is env["Accel"].
	local GetDistance is env["GetDistance"].
	local sim is NewSimulator(accelCalc,timeStep).
	local NStepsToH is sim["NStepsToH"].
	local SimToHFrom is sim["SimToHFrom"].
	
	local function MakeAdjustedState{
		parameter st, adj.
		
		return lexicon(
			"T", st["T"],
			"P", v(0,0,st["P"]:Z),
			"V", st["V"]+adj,
			"A", accelCalc(st["T"],st["P"],st["V"]+adj)
		).
	}

	local function DistanceAdj2{
		parameter cEntry. 
		parameter nSt, adj.
		local adjSS is MakeAdjustedState(nSt,adj).
		local adjES is NStepsToH(2,cEntry["Z"],adjSS).
		local stepDist is GetDistance(adjSS,adjES).
		local diffDist is cEntry["D"]*(adjES["V"]-cEntry["V"]).
		return stepDist+diffDist.	
	}
	local function ConstructGuide{
		parameter traj.
		
		local endState is traj[traj:LENGTH-1].
		local i is traj:LENGTH-2.
		
		local currEntry is lexicon(
			"Z", endState["P"]:Z,
			"V", endState["V"],
			"X", 0,
			"D", V(0,0,0)
		).
		local guide is list(currEntry).

		until i < 0 {
			local newSt is traj[i].
			local newDist is GetDistance(newSt,endState).
			local distDiff is newDist-currEntry["X"].
			local distDiffY is DistanceAdj2(currEntry,newSt,adjVY).			
			local distDiffZ is DistanceAdj2(currEntry,newSt,adjVZ).
			local drvY is (distDiffY-distDiff)/dY.
			local drvZ is (distDiffZ-distDiff)/dZ.
			
			set i to i-1.
			set currEntry to lexicon(
				"Z", newSt["P"]:Z,//altitude
				"V", newSt["V"],//(_,angVel,vertVel)
				"X", newDist,//(distace to impact point along sea level)
				"D", v(0,drvY,drvZ)//derivative of X by V
			).

			guide:INSERT(0,currEntry).
		}
		return guide.
	}
	
	return ConstructGuide@.
}

function NewGuideLineDataProvider{
	parameter table.
	
	local maxI is table:LENGTH-2.
	
	//state
	local curI is 0.
	local startKey is 0.
	local endKey is 0.
	
	local function UpdateState{
		local se is table[curI].
		local ee is table[curI+1].
		set startKey to se["Z"].
		set endKey to ee["Z"].
	}
	
	local function GetValue{
		parameter keyP.

		if keyP > startKey {
			UNTIL curI = 0 or table[curI]["Z"] >= keyP {
				set curI to curI-1.
			}
			UpdateState().
		}
		
		if keyP < endKey {
			UNTIL curI = maxI or table[curI+1]["Z"] <= keyP {
				set curI to curI+1.
			}
			UpdateState().
		}

		return table[curI+1].
	}
	
	UpdateState().
	return GetValue@.
}