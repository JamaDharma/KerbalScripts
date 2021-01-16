local binareSearchInputList to LIST(
	"default stepsize",
	{
		parameter dX.
		PRINT "chenge value of parameter by dX".
	},
	"minimum stepsize",
	{
		return "target metric to minimise".
	}
).

local function SetStepSizeUpMode{
	parameter lst.
	parameter dX.
	parameter upstep.
	set lst[0]  to dX.
	set lst[1]  to upstep.
}

function TryStep {
	parameter lst.
	parameter dX.
	parameter oldM.
	parameter upstep.
	
	set newM to lst[3]().
	IF  newM < oldM { 
		if upstep { set newstep to dX*2.	} 
			else { set newstep to dX/2. }
		BinareSearch(lst, newstep, newM, upstep).
		return true.
	}
	return false.
}

function BinareSearch{
	parameter lst.
	parameter dX is lst[0].
	parameter metric is lst[3]().
	parameter upstep is true.
	
	local changer is lst[1].
	IF ABS(dX) < lst[2] { return. }
	
	changer:call(dX).//step
	if TryStep(lst, dX, metric, upstep) { return. }
 	
	changer:call(-dX*2).//*2 to compensate prev attempt
	if TryStep(lst, dX, metric, upstep) { return. }
	
	changer:call(dX).//failed to improve, no steps
	BinareSearch(lst, dX/2, metric, false).
}