RUNONCEPATH("0:/lib/Debug").
RUNONCEPATH("0:/lib/Numerical/Simulator").

function NewMessageManager{
	parameter sp1, sp2.
	parameter adj1,adj2.
	parameter dragK,m.
	
	local cnn1 is PROCESSOR(sp1):CONNECTION.
	local cnn2 is PROCESSOR(sp2):CONNECTION.
	
	local function BootListener{
		parameter procName.
		
		local s is PROCESSOR(procName).
		s:DEACTIVATE().
		set s:BOOTFILENAME to "/boot/bootlisten.ks".
		s:ACTIVATE().
	}
	
	LOCAL messageBuffer IS CORE:MESSAGES.
	local function ReadMessage{
		UNTIL not messageBuffer:EMPTY WAIT 0.2.
		return messageBuffer:POP():CONTENT.
	}
	
	local function SendMessages{
		parameter msg.
		cnn1:SENDMESSAGE(msg).
		cnn2:SENDMESSAGE(msg).
	}
	
	function InitSlaveProcessors{
		BootListener(sp1).
		BootListener(sp2).
		WAIT 0.5.
		SendMessages("0:/lib/Numerical/AtmosphericEntry/GuideSlave").
	}
	
	local function SendInitMessage{
		parameter cnn, errV.
		
		cnn:SENDMESSAGE(lexicon(
			"AdjV",errV,
			"DragK",dragK,
			"M", m,
			"Sender",CORE:PART:TAG
		)).
	}
	
	function InitCalculation{
		SendInitMessage(cnn1,adj1).
		SendInitMessage(cnn2,adj2).
	}
	
	function GetResults{
		SendMessages(0).
		local result1 is 0.
		local result2 is 0.
		local msg is ReadMessage().
		if msg["Sender"] = sp1 set result1 to msg["Data"].
		if msg["Sender"] = sp2 set result2 to msg["Data"].
		set msg to ReadMessage().
		if msg["Sender"] = sp1 set result1 to msg["Data"].
		if msg["Sender"] = sp2 set result2 to msg["Data"].
		return list(result1,result2).
	}
	
	InitSlaveProcessors().
	return lexicon(
		"SendMessages",SendMessages@,
		"InitCalculation",InitCalculation@,
		"GetResults",GetResults@
	).
}

function NewMasterGuideCalculator{
	parameter env.
	parameter sp1, sp2.//slaved processors
	
	local dY is 1/env["BodyR"].
	local dZ is 1.
	local adjVY is v(0,dY,0).
	local adjVZ is v(0,0,dZ).
	
	local msgManager is NewMessageManager(sp1,sp2
		,adjVY,adjVZ,env["DragK"],env["ShipMass"]).
	local sim is NewSimulator(env["Accel"],2).
	
	local GetDistance is env["GetDistance"].	
	local SendMessages is msgManager["SendMessages"].
	
	local function DistanceAdj{
		parameter adjEntry, drv.
		return adjEntry["StepDiff"]+adjEntry["dV"]*drv.
	}
	
	local function ConstructGuide{
		parameter startSt.
		
		local startTime is TIME.
		
		set startSt to env["ConstructInnerState"](startSt).
		msgManager["InitCalculation"]().

		local traj is list().
		local count is 0.
		local function ProcessState{
			parameter st.
			
			if MOD(count,2) = 0 OR st["P"]:Z < 505 {
				SendMessages(st).
				traj:ADD(st).
			}
			set count to count+1.
		}
		ProcessState(startSt).
		sim["SimToHByFromListener"](500,2,startSt,ProcessState@).
		PRINT "Trajectory: "+(TIME-startTime):SECONDS.
		local dyz is msgManager["GetResults"]().
		PRINT "Reply: "+(TIME-startTime):SECONDS.
		local dataY is dyz[0].
		local dataZ is dyz[1].
		
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
			local distDiffY is DistanceAdj(dataY[i],currEntry["D"]).			
			local distDiffZ is DistanceAdj(dataZ[i],currEntry["D"]).	
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
		PRINT "Result: "+(TIME-startTime):SECONDS.
		return guide.
	}
	
	return ConstructGuide@.
}
