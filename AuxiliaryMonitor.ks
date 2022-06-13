RUNONCEPATH("0:/lib/Debug").
RUNONCEPATH("0:/lib/Surface/SurfaceAt").
RUNONCEPATH("0:/lib/Search/TragectoryImpactSearch").
RUNONCEPATH("0:/lib/Ship/Acceleration").

local targetHeight is 300.
local pad is BODY:GEOPOSITIONLATLNG(-0.0972077889151947,-74.5576774701971).

local masterLink is PROCESSOR("Master"):CONNECTION.
LOCAL messageBuffer IS CORE:MESSAGES.

local adj is 0.
local timeT is TragectoryAltitudeTime(targetHeight).

local function AdjustError{
	parameter er.
	UNTIL messageBuffer:EMPTY{
		local trueErr is messageBuffer:POP():CONTENT.
		set adj to trueErr - er.
	}
	if adj = 0 return 0.
	return adj + er.
}

local accWatch is MakeAccelerometerSimple().
local accAvg is 0.
WAIT 0.
WHEN true THEN {
	set accAvg to accWatch:UpdateV().
	return true.
}
WAIT 0.5.



UNTIL ALTITUDE < 1000 {
	set timeT to TragectoryAltitudeTime(targetHeight, timeT).
	local padD is GlobeDistance(pad,ship:GEOPOSITiON).
	local impD is GlobeDistance(GeopositionAt(ship,timeT),ship:GEOPOSITiON).
	local err is AdjustError(padD-impD).
	masterLink:SENDMESSAGE(list(err,accAvg)).
	WAIT 0.
}