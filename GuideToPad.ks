RUNONCEPATH("0:/lib/Debug").
//RUNONCEPATH("0:/lib/Unwieldy").
RUNONCEPATH("0:/lib/Storage").
RUNONCEPATH("0:/lib/Surface/KerbinPoints").
RUNONCEPATH("0:/lib/Surface/SurfaceAt").
RUNONCEPATH("0:/lib/Numerical/AtmosphericEntry/AtmosphericEntry").

LOCAL messageBuffer IS CORE:MESSAGES.
local dk is ShipTypeStorage():GetValue("DragK").
local sim is MakeAtmEntrySim(dk).

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
	local ga is "0:/lib/Numerical/AtmosphericEntry/GuideAuxiliary".
	PROCESSOR("Slave1"):CONNECTION:SENDMESSAGE(ga).	
	
}

InitSlaveProcessors().



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

local currImpact is 0.
local currDistance is 0.
local currError is 0.
local function UpdateState{
	UNTIL messageBuffer:EMPTY{
		local newGuide is messageBuffer:POP():CONTENT.
		sim:InitEntryGuide(newGuide).
	}
	set currDistance to GlobeDistance(pad,ship:GEOPOSITION).
	set currImpact to sim:EntryGuide(2).
	if currImpact > 0 set currError to currDistance-currImpact.
}

local function TargetHeading{
	local tv is pad:ALTITUDEPOSITION(ALTITUDE):NORMALIZED.
	local ang is VCRS(SRFPROGRADE:VECTOR, tv)*SRFPROGRADE:TOPVECTOR*CONSTANT:RadToDeg.
	//NPrint("ha",ang).
	return pad:HEADING+ang.
}

local function TaretPitch{
	local ang is currError/currDistance*CONSTANT:RadToDeg.
	local ptch is 90-VANG(SRFPROGRADE:VECTOR,UP:VECTOR).
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

UNTIL GlobeDistance(pad,ship:GEOPOSITION)<10 {
	UpdateState().
	local ptch is 90-VANG(SRFPROGRADE:VECTOR,UP:VECTOR).
	local currPtch is 90-VANG(-FACING:VECTOR,UP:VECTOR).
	local tgtPtch is ptch+2*currError/currDistance*CONSTANT:RadToDeg.
	set stl to HEADING(TargetHeading(),tgtPtch).
	WAIT 0.
	CLEARSCREEN.
	NPrint("currDistance",currDistance).
	NPrint("currImpact",currImpact).
	NPrint("currError",currError).
	NPrint("SrfPitch",ptch).
	NPrint("CurrPitch",currPtch-ptch).
	NPrint("TgtPtchDiff",tgtPtch-ptch).
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
local chutesT is TIME.

UNTIL ALTITUDE < 150 {
	local dst is GlobeDistance(pad,ship:GEOPOSITION).
	local est to ChuteBrackingEstimate((TIME-chutesT):SECONDS).
	local ptch is CHOOSE 0 IF dst>est ELSE -88.
	set stl to HEADING(TargetHeading(),ptch).
	NPrint("ptch",ptch).
	NPrint("dst",dst).
	NPrint("est",est).
	WAIT 0.3.
}

LOCK STEERING TO UP.

RUN LandingA.