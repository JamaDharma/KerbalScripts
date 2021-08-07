RUNONCEPATH("0:/lib/Debug").
RUNONCEPATH("0:/lib/Atmosphere").

global xlChuteK is 0.36.

local deploymentStart is 2.
local deploymentFinish is 5.

function MakeChuteForceCalculator{
	parameter dragT.
	parameter dragK.
	parameter chuteK.
	
	local deploymentLength is deploymentFinish-deploymentStart.
	local function CurrDragK{
		parameter t.
		if t > deploymentFinish return chuteK.
		if t < deploymentStart return dragK.
		
		local deploymentFraction is (t-deploymentStart)/deploymentLength.
		return dragK + deploymentFraction*deploymentFraction*(chuteK-dragK).
	}
	
	return {
		parameter t.
		parameter cAlt.
		parameter spd.
		return AtmDensity(dragT,cAlt)*CurrDragK(t)*spd*spd.
	}.
}