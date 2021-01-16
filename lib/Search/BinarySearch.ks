local binareSearchInputList to LIST(
	"minimum stepsize",	
	{
		parameter dX.
		PRINT "change value of parameter by dX".
	},
	"default stepsize",
	{return "target metric".}
).

local function TryStep {
	parameter lst.
	parameter dX.
	parameter oldM.
	parameter upstep.
	
	set newM to lst[3]().
	IF  newM < oldM { 
		if upstep { set newstep to dX*2.	} 
			else { set newstep to dX/2. }
		BSearch(lst, newstep, newM, upstep).
		return true.
	}
	return false.
}

function BSearch{
	parameter lst.
	parameter dX is lst[2].
	parameter metric is lst[3]().
	parameter upstep is true.
	
	local changer is lst[1].
	IF ABS(dX) < lst[0] { return. }
	
	changer:call(dX).//step
	if TryStep(lst, dX, metric, upstep) { return. }
 	
	changer:call(-dX*2).//*2 to compensate prev attempt
	if TryStep(lst, dX, metric, upstep) { return. }
	
	if upstep { set lst[2] to dX/2+lst[0]. }
	changer:call(dX).//failed to improve, no steps
	BSearch(lst, dX/2, metric, false).
}