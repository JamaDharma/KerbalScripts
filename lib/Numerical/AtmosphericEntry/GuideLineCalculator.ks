RUNONCEPATH("0:/lib/Debug").
RUNONCEPATH("0:/lib/Numerical/Simulator").

function NewEntryGuide{
	parameter accelCalc.
	parameter bw is body:ANGULARVEL:MAG.
	parameter br is body:radius.
	
	local es is NewSimulator(accelCalc).
	local adjVY is v(0,1/br,0).
	local adjVZ is v(0,0,1).
	
	local function MakeAdjustedState{
		parameter st, adj.
		
		return lexicon(
			"T", st["T"],
			"P", v(0,0,st["P"]:Z),
			"V", st["V"]+adj,
			"A", accelCalc(st["T"],st["P"],st["V"]+adj)
		).
	}
	
	local function GetDistance{
		parameter sSt, eSt.
		return ((eSt["P"]-sSt["P"]):Y-(eSt["T"]-sSt["T"])*bw)*br.
	}
	
	local nStepsToH is es["NStepsToH"].
	local function DistanceAdj2{
		parameter cEntry. 
		parameter nSt, adj.
		local adjSS is MakeAdjustedState(nSt,adj).
		local adjES is nStepsToH(2,cEntry["Z"],adjSS).
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
			local newDist is GetDistance(traj[i],endState).
			local distDiff is newDist-currEntry["X"].
			local distDiffY is DistanceAdj2(currEntry,newSt,adjVY).			
			local distDiffZ is DistanceAdj2(currEntry,newSt,adjVZ).
			local dY is (distDiffY-distDiff)/adjVY:Y.
			local dZ is (distDiffZ-distDiff)/adjVZ:Z.
			local newDrv is v(0,dY,dZ).
			
			set i to i-1.
			set currEntry to lexicon(
				"Z", newSt["P"]:Z,//altitude
				"V", newSt["V"],//(_,angVel,vertVel)
				"X", newDist,//(distace to impact point along sea level)
				"D", newDrv//derivative of X by V
			).

			guide:INSERT(0,currEntry).
		}
		return guide.
	}
	
	return ConstructGuide@.
}

function MakeAtmEntrySim{
	parameter dfc.
	parameter shipMass is MASS.
	
	local shipMassK is 1/shipMass.
	local br is body:radius.
	local bm is V(0,0,-body:mu).
	local bw is body:ANGULARVEL:MAG.	
	local es is NewSimulator(Accel@).
	local egc is NewEntryGuide(Accel@).
	
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
	
	local function EntryGuide{
		parameter exitH, timeStep.
		parameter st.
		
		local startSt is ConstructInnerState(st).
		local traj is es["TrajectoryToH"](exitH,timeStep,startSt).
		return egc(traj).
	}
	
	local function MakeGuideLine{
	}

	return lexicon(
		"StateToHGuide", EntryGuide@,
		"FromStateToH", SimToH@,
		"FromStateToT", SimToT@
	).
}
	
	