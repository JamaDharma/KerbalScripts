RUNONCEPATH("0:/lib/Debug").
RUNONCEPATH("0:/lib/AtmosphericEntry").
RUNONCEPATH("0:/lib/SurfaceAt").

local fName is "PathLog.txt".
local timestep is 0.25.
local pad is BODY:GEOPOSITIONLATLNG(-0.0972077889151947,-74.5576774701971).

function InverseControl {
	LIST PARTS IN  partList.	
	local fName is "authority limiter".
	for prt in partList
	if prt:HASMODULE("ModuleControlSurface") {
		
		local mdl is prt:getmodule("ModuleControlSurface").
		
		if mdl:HasField(fName){
			local angle is mdl:getfield(fName).
			mdl:setfield(fName, -100).
			PRINT angle.
		}
	}
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
		
		local result is "T: " + ROUND(lt,3)
						+ "    VX: " + ROUND(lvx,1)
						+ "    DragK: " + ROUND(dragK,5).
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

InverseControl().
WAIT UNTIL AIRSPEED < 250.
ON (ALTITUDE < 2000) {
	CHUTES ON.
	LOG "CHUTES" to fName.
	PRINT "CHUTES".
}.
StartRecording().
