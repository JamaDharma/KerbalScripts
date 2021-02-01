RUNONCEPATH("0:/lib/Debug").
RUNONCEPATH("0:/lib/Search/SearchComponent").

local function OneStep{
	parameter metric.
	parameter context.
	parameter startingMetric is metric().

	local dX is context:DefaultStep.
	IF ABS(dX) < context:MinimumStep {
		return false. 
	}
		
	local changer is context:Changer.
	
	//step
	changer:call(dX).
	local newM is metric().
	if newM < startingMetric {
		//set context:DefaultStep to 2*dx.
		return true.
	}
 	//2 to compensate prev attempt
	changer:call(-2*dX).
	set newM to metric().
	if newM < startingMetric{
		//set context:DefaultStep to -2*dx.
		return true.
	}
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
	
	local result is false.
	for cmp in cmps {
		set result to OneStep(metric, cmp) or result.
	}
	return result.
}

function OneStepOptimization{
	parameter context.
	local count is 0.
	UNTIL not OS(context) or TERMINAL:INPUT:HASCHAR(){
		set count to count+1.
		if count > 4 {
			set count to 0.
			for cmp in context[2] {
				set cmp:DefaultStep to cmp:DefaultStep*2.
			}
		}
	}
}
