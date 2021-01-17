local binareSearchInputList to lexicon(
	"MinimumStep",0.1,
	"Changer",	{
		parameter dX.
		PRINT "change value of parameter by dX".
	},
	"DefaultStep", 1
).

local function TryStep {
	parameter metric.
	parameter lst.
	parameter dX.
	parameter oldM.
	parameter upstep.
	
	set newM to metric().
	IF  newM < oldM { 
		if upstep { set newstep to dX*2.	} 
			else { set newstep to dX/2. }
		BSearch(metric, lst, newstep, newM, upstep).
		return true.
	}
	return false.
}

function BSearch{
	parameter metric.
	parameter context.
	parameter dX is context:DefaultStep.
	parameter upstep is true.
	
	local startingMetric is metric().
	local changer is context:Changer.
	IF ABS(dX) < context:MinimumStep { return. }
	
	changer:call(dX).//step
	if TryStep(metric, context, dX, startingMetric, upstep) { return. }
 	
	changer:call(-dX*2).//*2 to compensate prev attempt
	if TryStep(metric, context, dX, startingMetric, upstep) { return. }
	
	if upstep { set context:DefaultStep to dX/2+context:MinimumStep. }//WTF?!!!
	changer:call(dX).//failed to improve, no steps
	BSearch(metric, context, dX/2, startingMetric, false).
}