RUNONCEPATH("0:/lib/Storage").
RUNONCEPATH("0:/lib/Numerical/AtmosphericEntry/AtmosphericEntry").

local dk is ShipTypeStorage():GetValue("DragK").
local sim is MakeAtmEntrySim(dk).
local masterLink is PROCESSOR("Master"):CONNECTION.
until false{
	local guide is sim:MakeEntryGuide(90,2).
	masterLink:SENDMESSAGE(guide).
}