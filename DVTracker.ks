RUNONCEPATH("0:/lib/Debug").
RUNONCEPATH("0:/lib/DeltaV").

function DVTracker{
	local startDV is StageDeltaV().
	local lastDV is startDV.
	
	NPrint("Starting DV",startDV).
	
	function Track{
		local currentDV is StageDeltaV().
		NPrint("Current DV",currentDV).
		NPrint("Spent since last",lastDV-currentDV).
		NPrint("Total spent",startDV-currentDV).
		set lastDV to currentDV.
		return currentDV.
	}
	
	return Track@.
}

local track is DVTracker().

until false {
	if TERMINAL:INPUT:HASCHAR() {
		track().
		TERMINAL:INPUT:CLEAR().
	}
	WAIT 1.
}