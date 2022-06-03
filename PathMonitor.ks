//Show drag k possible log to file
RUNONCEPATH("0:/lib/Debug").
RUNONCEPATH("0:/lib/Numerical/Entry/AtmosphericEntry").
RUNONCEPATH("0:/lib/Surface/SurfaceAt").

local fName is "PathLogLightChute.txt".

function StartRecording {
	parameter timestep is 1.
	local startTime is TIME.
	local dmc is MakeKerbinDragMultiplyerCalculator().

	local lt is 0.
	local lspd is AIRSPEED.
	local lvx is GROUNDSPEED.
	local lvz is VERTICALSPEED.
	local lz is ALTITUDE.
	
	UNTIL GROUNDSPEED < 1 {
		WAIT timestep.
		
		local t is (TIME-startTime):SECONDS.
		local vx is GROUNDSPEED.
		local vz is VERTICALSPEED.
		local cz is ALTITUDE.

		local dt is t - lt.
		local dragK is (lvx-vx)*MASS/(dt*dmc(lz,lspd)*lspd*lvx).

		local result is "T: 	" + ROUND(lt,3)
						+ "	 VX: 	" + ROUND(lvx,1)
						+ "	 DragK: 	" + ROUND(dragK,5).
		//LOG result to fName.
		PRINT result.
		
		set lt to t.
		set lspd to SQRT(vx*vx+vz*vz).
		set lvx to vx.
		set lvz to vz.
		set lz to cz.
	}
}

LOCK STEERING to SRFRETROGRADE.
WAIT UNTIL ALTITUDE < 70000.
WAIT 0.
StartRecording().