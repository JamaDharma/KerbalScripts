RUNONCEPATH("0:/lib/Search/SearchComponent").

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
		BSearch(metric, lst, upstep, newstep, newM).
		return true.
	}
	return false.
}

function BSearch{
	parameter metric.
	parameter context.
	parameter upstep is true.
	parameter dX is context:DefaultStep.
	parameter startingMetric is metric().


	local changer is context:Changer.
	IF ABS(dX) < context:MinimumStep { return. }
	
	changer:call(dX).//step
	if TryStep(metric, context, dX, startingMetric, upstep) { return. }
 	
	changer:call(-dX*2).//*2 to compensate prev attempt
	if TryStep(metric, context, dX, startingMetric, upstep) { return. }
	
	if upstep { set context:DefaultStep to dX/2+context:MinimumStep. }//WTF?!!!
	changer:call(dX).//failed to improve, no steps
	BSearch(metric, context, false, dX/2, startingMetric).
}