RUNONCEPATH("0:/lib/Storage").
RUNONCEPATH("0:/lib/Numerical/AtmosphericEntry/MasterGuideCalculator").

local dk is ShipTypeStorage():GetValue("DragK").
local env is NewEntryEnvironment(dk, MASS).
local calc is NewMasterGuideCalculator(env).

until false{
	local startState is lexicon(
			"VX", GROUNDSPEED,
			"VZ", VERTICALSPEED,
			"T", 0,
			"X", 0,
			"Z", ALTITUDE).
	local guide is calc(startState).
}