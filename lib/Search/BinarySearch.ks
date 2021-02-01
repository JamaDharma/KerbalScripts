RUNONCEPATH("0:/lib/Search/SearchComponent").

local function BinarySearch{
	parameter metric.
	parameter context.
	parameter dir.
	parameter x0,x1.
	
	local shift is (x0+x1)/2.
	IF ABS(x0+x1) < context:MinimumStep { return shift. }
	


	context:Changer(shift).//step
	local newM is metric()*dir.
	if newM < 0
		return BinarySearch(metric,context,dir, 0, x1-shift).
	if newM > 0
		return BinarySearch(metric,context,dir, x0-shift, 0).
}
local function BoundSearch{
	parameter metric.
	parameter context.
	parameter dir.
	parameter dX is context:DefaultStep.

	local shift is dX*dir.
	context:Changer(shift).//step
	local newM is metric()*dir.
	if newM < 0
		return BoundSearch(metric,context, dir, dx*2).
	if newM > 0
		return BinarySearch(metric,context,dir, -shift, 0).
}
local function DirectionSearch{
	parameter metric.
	parameter context.
	
	local m0 is metric().
	
	if m0 < 0 
		return BoundSearch(metric,context, 1).
	if m0 > 0 
		return BoundSearch(metric,context, -1).
}

function BSearch{
	parameter metric.
	parameter context.

	return DirectionSearch(metric, context).
}