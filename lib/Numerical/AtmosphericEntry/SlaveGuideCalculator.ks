RUNONCEPATH("0:/lib/Debug").
RUNONCEPATH("0:/lib/Numerical/Simulator").
RUNONCEPATH("0:/lib/Numerical/AtmosphericEntry/EntryEnvironment").

function SlaveGuideCalculator{

	LOCAL messageBuffer IS CORE:MESSAGES.
	local function ReadMessage{
		UNTIL not messageBuffer:EMPTY WAIT 0.1.
		return messageBuffer:POP():CONTENT.
	}
	
	local function MakeAdjustedState{
		parameter st.
		
		return lexicon(
			"T", st["T"],
			"P", v(0,0,st["P"]:Z),
			"V", st["V"]+errV,
			"A", accelCalc(st["T"],st["P"],st["V"]+errV)
		).
	}
	
	local function CalculateDataEntry{
		parameter currSt, newSt.
		
		local adjSS is MakeAdjustedState(currSt).
		local adjES is CHOOSE SimToHFrom(newSt["P"]:Z,adjSS) 
			IF newSt["T"]-currSt["T"] < 3.8 
			ELSE NStepsToH(2,newSt["P"]:Z,adjSS).

		return lexicon(
			"StepDiff", GetDistance(adjSS,adjES),
			"dV", adjES["V"]-newSt["V"]
		).
	}
	function CalculateReply{
		local result is list().
		local startTime is TIME.
		local currSt is ReadMessage().
		local newSt is ReadMessage().
		until newSt = 0 {
			result:ADD(CalculateDataEntry(currSt,newSt)).
			set currSt to newSt.
			set newSt to ReadMessage().
		}
		PRINT "Result: "+(TIME-startTime):SECONDS.
		return result.
	}

	local initMsg is ReadMessage().
	local env is NewEntryEnvironment(initMsg["DragK"],initMsg["M"]).
	local accelCalc is env["Accel"].
	local GetDistance is env["GetDistance"].
	local sim is NewSimulator(accelCalc,2).
	local NStepsToH is sim["NStepsToH"].
	local SimToHFrom is sim["SimToHFrom"].
	local errV is initMsg["AdjV"].
	local replyCh is PROCESSOR(initMsg["Sender"]):CONNECTION.
	replyCh:SENDMESSAGE(lexicon(
		"Sender", CORE:PART:TAG,
		"Data", CalculateReply()
	)).
}
