RUNONCEPATH("0:/lib/Debug").
RUNONCEPATH("0:/lib/Numerical/AtmosphericEntry/AtmosphericEntry").

set TERMINAL:WIDTH to 80.
local dfc is MakeDragFactorCalculator(KerbinAT).
local grv is body:mu/body:radius^2.

local startTime is TIME.
local startAlt is ALTITUDE.
local startSPD is verticalSpeed.
UNTIL false {
	wait 2.
	local currTime is TIME.
	local currAlt is ALTITUDE.
	local currSpd is verticalSpeed.
	
	local dt is (currTime-startTime):SECONDS.
	local dz is currAlt-startAlt.
	local dv is currSpd-startSPD.
	
	local dragAcc is grv+dv/dt.
	local dragMult is dfc(startAlt,startSPD)/MASS.
	local dragK is dragAcc/dragMult.
	
	NPrint("dragK",dragK).
	
	set startTime to currTime.
	set startAlt to currAlt.
	set startSPD to currSpd.	
}