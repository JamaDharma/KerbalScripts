RUNONCEPATH("0:/lib/Debug").
RUNONCEPATH("0:/lib/Atmosphere").

local deploymentStart is 2.5.
local deploymentFinish is 4.5.
local deploymentLength is deploymentFinish-deploymentStart.

function NewParachuteEnvironment{
	parameter dragK.
	parameter chuteK.
	parameter shipMass is MASS.
	
	local dfc is MakeDragFactorCalculator(KerbinAT).
	local shipMassK is 1/shipMass.
	
	local dep1K is dragK+chuteK/1000.
	local dep2K is chuteK/30.
	local dep3K is chuteK*0.9.
	local fullK is dragK+chuteK.
	
	local br is body:radius.
	local bm is V(0,0,-body:mu).
	local grv is bm/(br+1000)^2.
	
	local function CurrDragK{
		parameter t.
		if t > deploymentFinish return fullK.
		if t < 0.5 return dragK.
		if t < 2 return dep1K.
		if t < deploymentStart return dragK+dep2K*(t-2)/(deploymentStart-2).
		
		local deploymentFraction is (t-deploymentStart)/deploymentLength.
		return dep2K + deploymentFraction*deploymentFraction*dep3K.
	}
	local function Accel{
		parameter t,pos,vel.
		
		local spd is vel:MAG.
	
		local ac is -dfc(pos:Z,spd)*shipMassK*CurrDragK(t).
		local df is ac*vel/spd.

		return grv+df.
	}
	
	return lexicon(
		"CurrDragK", CurrDragK@,
		"Accel", Accel@
	).
}