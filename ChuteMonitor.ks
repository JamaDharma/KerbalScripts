RUNONCEPATH("0:/lib/Debug").

local fName is "PathLogLightChute.txt".
local startTime is 0.
local path is list().
local function CaptureState{
	local res is lexicon(
		"T", (TIME - startTime):SECONDS,
		"Z", ALTITUDE,
		"V", VERTICALSPEED
	).
	NPrintL(res).
	return res.
}

LOCK STEERING to UP.
WAIT UNTIL ALTITUDE < 2000.
WAIT 0.
set startTime to TIME.
CHUTES ON.
path:ADD(CaptureState()).
UNTIL TIME-startTime > 10 {
	WAIT 0.1.
	path:ADD(CaptureState()).
}
WRITEJSON(path, "PathLogData.json").
if(false){
local result is "".
for entry in path {
	local es is "T: "+ROUND(entry["T"],3)
			+" Z: " +ROUND(entry["Z"],2)
			+" V: " +ROUND(entry["V"],2)+"
			".
	set result to result+es. 
} 
LOG result to fName.
}