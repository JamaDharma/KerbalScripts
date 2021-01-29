RUNONCEPATH("0:/lib/Search/SearchComponent").

local phi is (SQRT(5)+1)/2.
local invphi is (SQRT(5)-1)/2.
local invphi2 is (3-SQRT(5))/2.

local function GoldenSearch{
	parameter metric,context,shift.
	parameter xa,xb,dx.
	parameter noC,xC,mC.
	parameter noD,xD,mD.
	PRINT "gold: "+dx.
	IF ABS(dX) < context:MinimumStep { return. }
	
	set xa to xa-shift.
	set xb to xb-shift.
	set xC to xC-shift.
	set xD to xD-shift.

	if (noC) {
		set xC to xA + invphi2 * dx.
		context:Changer(xC).
		set shift to xC.
		set mC to metric().
	}
	if (noD) {
		set xD to xA + invphi * dx.
		context:Changer(xD).
		set shift to xD.
		set mD to metric().
	}
	
	if (mC < mD) {
		return GoldenSearch(metric,context,shift, xa,xD,dx*invphi, true,0,0, false,xC,mC).
	} else {
		return GoldenSearch(metric,context,shift, xC,xb,dx*invphi, false,xD,mD, true,0,0).
	}
}

local function BoundSearch{
	parameter metric.
	parameter context.
	parameter x0,x1,m1.

	local dx is (x1-x0)*phi.
	
	context:Changer(dX).//step
	local newM is metric().
	if newM < m1
		return BoundSearch(metric,context,-dx, 0, newM).
	return GoldenSearch(metric,context,dx, x0,dx,dx-x0, false,x1,m1, true,0,0).
}

local function DirectionSearch{
	parameter metric.
	parameter context.
	parameter dX is context:DefaultStep.
	parameter startingMetric is metric().
	
	local changer is context:Changer.
	
	changer:call(dX).//step
	local newM is metric().
	if newM < startingMetric
		return BoundSearch(metric,context,-dx, 0, newM).
 	
	local diff is dX*(1+phi).//+1 to compensate prev attempt
	changer:call(-diff).
	set newM to metric().
	if newM < startingMetric
		return BoundSearch(metric,context, diff, 0, newM).
	
	return GoldenSearch(metric,context,0, 0,diff,diff, true,0,0, false,dX*phi,startingMetric).
}

function GSearch{
	parameter metric.
	parameter context.

	DirectionSearch(metric, context).
}