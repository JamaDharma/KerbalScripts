RUNONCEPATH("0:/lib/Debug").
RUNONCEPATH("0:/lib/Search/SearchComponent").
local function StepForward{
	parameter metric.
	parameter context.
	parameter startingMetric is metric().

	local dX is context:DefaultStep.
	IF ABS(dX) < context:MinimumStep
		return 0.

	local changer is context:Changer.

	//step
	changer:call(dX).
	local newM is metric().
	if newM < startingMetric
		return list(dx,newM).

	//failed to improve, no steps
	changer:call(-dX).//waste of set
	set context:DefaultStep to dx/2.
	return OneStep(metric, context, startingMetric).
}

local function OneStep{
	parameter metric.
	parameter context.
	parameter startingMetric is metric().

	local dX is context:DefaultStep.
	IF ABS(dX) < context:MinimumStep
		return list(0,startingMetric).

	local changer is context:Changer.

	//step
	changer:call(dX).
	local newM is metric().
	if newM < startingMetric
		return list(dx,newM).

	//2 to compensate prev attempt
	changer:call(-2*dX).
	set newM to metric().
	if newM < startingMetric
		return list(-dx,newM).

	//failed to improve, no steps
	changer:call(dX).//waste of set
	set context:DefaultStep to dx/2.
	return OneStep(metric, context, startingMetric).
}

local function OS{
	parameter context.

	local stepSize is context[0].
	local metric is context[1].
	local cmps is context[2].

	local result is list().
	local currM is metric().
	for cmp in cmps {
		local sr is OneStep(metric, cmp, currM).
		result:ADD(sr[0]).
		set currM to sr[1].	
	}
	return result.
}

local function DecayV{
	parameter oldV, myV.
	FROM {local i is 0.} UNTIL i = myv:LENGTH STEP {set i to i+1.} DO {
		set oldV[i] to (oldV[i]*7+myV[i])/8.
	}
}
local function MultV{
	parameter factor, myV.
	FROM {local i is 0.} UNTIL i = myv:LENGTH STEP {set i to i+1.} DO {
		set myV[i] to myV[i]*factor.
	}
}
local function SetVM{
	parameter newMag, myV.
	local sqMag is 0.
	for cmp in myV{
		set sqMag to sqMag + cmp*cmp.
	}
	if sqMag = 0 return false.
	MultV(newMag/SQRT(sqMag), myV).
	return true.
}

function OneStepMomentum{
	parameter context.
	
	local count is 0.
	local cmps is context[2].
	
	local momentum is list().
	for cmp in cmps {
		momentum:ADD(0).
	}
	local mCmp is MakeSearchComponent(1,0.001,{
		parameter dx.
		local myV is momentum:COPY.
		if (SetVM(dx,myV))
			FROM {local i is 0.} UNTIL i = myV:LENGTH STEP {set i to i+1.} DO {
				cmps[i]:Changer(myV[i]).
			}
	}).
	function RunStep{
		local sr is OS(context).
		DecayV(momentum,sr).
		StepForward(context[1],mCmp).
		return sr.
	}


	UNTIL TERMINAL:INPUT:HASCHAR(){
		RunStep().
		set count to count+1.
		if count > 3 {
			set count to 0.
			set mCmp:DefaultStep to mCmp:DefaultStep*2.
			for cmp in cmps {
				set cmp:DefaultStep to cmp:DefaultStep*2.
			}
			local exit is true.
			for change in RunStep()
				set exit to exit and change = 0.
			if exit break.
		}
	}
}
