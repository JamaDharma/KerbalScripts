RUNONCEPATH("0:/lib/Debug").
RUNONCEPATH("0:/lib/Math/Vectors").
RUNONCEPATH("0:/lib/Search/SearchComponent").

local function StepForward{
	parameter metric.
	parameter cmp.
	parameter startingMetric is metric().

	local dX is cmp:DefaultStep.
	IF ABS(dX) < cmp:MinimumStep
		return 0.

	local changer is cmp:Changer.

	//step
	changer:call(dX).
	local newM is metric().
	if newM < startingMetric
		return list(dx,newM).

	//failed to improve, no steps
	changer:call(-dX).//waste of set
	set cmp:DefaultStep to dx/2.
	return StepForward(metric, cmp, startingMetric).
}

function MomentumTracker{
	parameter context.
	
	local metric is context[1].
	local cmps is context[2].
	local momentumV is list().
	local ds is 0.
	local ms is 1.
	for cmp in cmps {
		momentumV:ADD(0).
		set ds to MAX(ds, cmp:DefaultStep).
		set ds to MIN(ds, cmp:MinimumStep).
	}
	
	local mCmp is MakeSearchComponent(ds,ms,{
		parameter dx.
		local mVC is momentumV:COPY.
		if (SetVectorMagnitude(mVC,dx))
			FROM {local i is 0.} UNTIL i = mVC:LENGTH STEP {set i to i+1.} DO {
				if mVC[i]<>0 cmps[i]:Changer(mVC[i]).
			}
	}).
	
	return lexicon(
		"UpStep", { parameter n. set mCmp:DefaultStep to mCmp:DefaultStep*n.},
		"Update", WeightedUpdate@:BIND(7,1,momentumV),
		"DoStep", StepForward@:BIND(metric,mCmp)
	).
}