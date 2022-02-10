RUNONCEPATH("0:/lib/Debug").
RUNONCEPATH("0:/lib/Storage").
RUNONCEPATH("0:/lib/Numerical/Chutes/ParachuteTrajectoryCalculator").

local dk is ShipTypeStorage():GetValue("DragK").
local ck is 0.45.
local ptc is NewParachuteTrajectoryCalculator(dk,ck).
local masterLink is PROCESSOR("Master"):CONNECTION.
local exitH is 0.
until ALTITUDE < exitH {
	local result is ptc().
	result:ADD("Header","Parachute").
	set exitH to result["ZP"].
	masterLink:SENDMESSAGE(result).
}