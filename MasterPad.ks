RUNONCEPATH("0:/lib/Debug").
RUNONCEPATH("0:/lib/Unwieldy").
RUNONCEPATH("0:/lib/SurfaceAt").
RUNONCEPATH("0:/lib/ChuteTiming").
RUNONCEPATH("0:/lib/Ship/Acceleration").
RUNONCEPATH("0:/lib/Search/TragectoryImpactSearch").

global runwayStart is BODY:GEOPOSITIONLATLNG(-0.0485526802803094,-74.7282838895171).
global runwayEnd is BODY:GEOPOSITIONLATLNG(-0.0502303377342092,-74.4915286545602).
local pad is BODY:GEOPOSITIONLATLNG(-0.0972077889151947,-74.5576774701971).

function InitSlaveProcessors{
	local file is "/boot/bootlisten.ks".
	local s is PROCESSOR("Slave1").
	s:DEACTIVATE().
	set s:BOOTFILENAME to file.
	s:ACTIVATE().
	set s to PROCESSOR("Slave2").
	s:DEACTIVATE().
	set s:BOOTFILENAME to file.
	s:ACTIVATE().

	WAIT 0.5.

	PROCESSOR("Slave1"):CONNECTION:SENDMESSAGE("ImpactEstimator").
	PROCESSOR("Slave2"):CONNECTION:SENDMESSAGE("AuxiliaryMonitor").
}

InitSlaveProcessors().

LOCAL messageBuffer IS CORE:MESSAGES.

local impError is 0.
local currAcc is 0.

local function InverseControl {
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

local function UpdateState{
	UNTIL messageBuffer:EMPTY{
		local newState is messageBuffer:POP():CONTENT.
		set impError to newState[0].
		set currAcc to newState[1].
		NPrint("impError",impError).
		NPrint("currAcc",currAcc).
	}
}

local function TargetHeading{
	local tv is pad:ALTITUDEPOSITION(ALTITUDE):NORMALIZED.
	local ang is VCRS(SRFPROGRADE:VECTOR, tv)*SRFPROGRADE:TOPVECTOR*CONSTANT:RadToDeg.
	//NPrint("ha",ang).
	return pad:HEADING+ang.
}
local function TaretPitch{
	local ang is impError/GlobeDistance(pad,ship:GEOPOSITION)*CONSTANT:RadToDeg.
	local ptch is 90-VANG(SRFPROGRADE:VECTOR,UP:VECTOR).
	//NPrint("impError",impError).
	//NPrint("pa",ang).
	return ptch+2*ang.
}

InverseControl().
//set STEERINGMANAGER:ROLLCONTROLANGLERANGE to 180.	
SAS OFF.
WAIT 0.
local stl is SRFPROGRADE.
LOCK STEERING TO -stl:VECTOR.
set steerV to VECDRAW(
	V(0,0,0),
	{ return stl:VECTOR*100. },
	GREEN,"",1,true).

UNTIL GlobeDistance(pad,ship:GEOPOSITION)<10000 {
	UpdateState().
	set stl to HEADING(TargetHeading(),TaretPitch()).
	WAIT 0.
}

//test insert
UNTIL GROUNDSPEED < 300 {
	UpdateState().
	set stl to HEADING(TargetHeading(),TaretPitch()).
	WAIT 0.
}

local chuteDist is ChuteBrackingEstimate().
local globeDist is GlobeDistance(pad,ship:GEOPOSITION).
UNTIL globeDist  < chuteDist + GROUNDSPEED*2 {
	set chuteDist to ChuteBrackingEstimate().
	set globeDist to GlobeDistance(pad,ship:GEOPOSITION).
	set stl to HEADING(TargetHeading(),0).
	PRINT chuteDist. 
	PRINT globeDist. 
	WAIT 0.
}

WAIT UNTIL GlobeDistance(pad,ship:GEOPOSITION) < chuteDist.
CHUTES ON.

WAIT UNTIL GROUNDSPEED < 10.
LOCK STEERING TO pad:POSITION.

WAIT UNTIL ALTITUDE < 150.

RUN LandingA.