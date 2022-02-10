RUNONCEPATH("0:/lib/Debug").
RUNONCEPATH("0:/lib/Storage").
RUNONCEPATH("0:/lib/Numerical/Entry/AtmosphericEntry").
//accept target alt, sends guides to Master
local targetAlt is 2500.

local dk is ShipTypeStorage():GetValue("DragK").
local sim is MakeAtmEntrySim(dk).
local messageBuffer is CORE:MESSAGES.
local masterLink is PROCESSOR("Master"):CONNECTION.
until ALTITUDE < targetAlt {
	UNTIL messageBuffer:EMPTY {
		set targetAlt to messageBuffer:POP():CONTENT.
		NPrint("TargetAlt",targetAlt).
	}
	local guide is sim:MakeEntryGuide(targetAlt,2).
	masterLink:SENDMESSAGE(lexicon (
		"Header","Guide",
		"Guide",guide
	)).
}