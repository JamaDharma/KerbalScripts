RUNONCEPATH("0:/lib/Debug").
RUNONCEPATH("0:/lib/Search/SearchComponent").

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

function OneStepMomentum{
	parameter context.
	local count is 0.


	UNTIL TERMINAL:INPUT:HASCHAR(){
		OS(context).
		set count to count+1.
		if count > 3 {
			set count to 0.
			for cmp in context[2] {
				set cmp:DefaultStep to cmp:DefaultStep*2.
			}
			local exit is true.
			for change in OS(context)
				set exit to exit and change = 0.
			if exit break.
		}
	}
}
