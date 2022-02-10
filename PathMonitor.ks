RUNONCEPATH("0:/lib/Debug").
RUNONCEPATH("0:/lib/AtmosphericEntry").
RUNONCEPATH("0:/lib/SurfaceAt").

local fName is "PathLogLightChute.txt".
local startTime is 0.
local path is list().
local function CaptureState{
	return lexicon(
		"T", TIME - startTime,
		"Z", ALTITUDE,
		"V", VERTICALSPEED
	).
}

function StartRecording {
	
	local startTime is TIME.
	local lt is 0.
	local lspd is AIRSPEED.
	local lvx is GROUNDSPEED.
	local lvz is VERTICALSPEED.
	local lx is GlobeDistance(pad,ship:GEOPOSITION).
	local lz is ALTITUDE.
	
	UNTIL GROUNDSPEED < 1 {
		WAIT timestep.
		
		local t is (TIME-startTime):SECONDS.
		local vx is GROUNDSPEED.
		local vz is VERTICALSPEED.
		local cx is GlobeDistance(pad,ship:GEOPOSITION).
		local cz is ALTITUDE.
		
		local dt is t - lt.
		local dragK is (lvx-vx)*MASS/(dt*AtmDensity(KerbinAT,lz)*lspd*lvx).
		
		local result is "T: 	" + ROUND(lt,3)
						+ "	 VX: 	" + ROUND(lvx,1)
						+ "	 DragK: 	" + ROUND(dragK,5).
		LOG result to fName.
		PRINT result.
		
		set lt to t.
		set lspd to SQRT(vx*vx+vz*vz).
		set lvx to vx.
		set lvz to vz.
		set lx to cx.
		set lz to cz.
	}
}

LOCK STEERING to UP.
WAIT UNTIL ALTITUDE < 2000.
WAIT 0.
set startTime to TIME.
CHUTES ON.
path:ADD(CaptureState()).
UNTIL TIME-startTime > 30 {
	WAIT 0.333.
	path:ADD(CaptureState()).
}
