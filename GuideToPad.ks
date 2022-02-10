RUNONCEPATH("0:/lib/Debug").
RUNONCEPATH("0:/lib/Storage").
RUNONCEPATH("0:/lib/Surface/KerbinPoints").
RUNONCEPATH("0:/lib/Surface/SurfaceAt").
RUNONCEPATH("0:/lib/Numerical/Entry/AtmosphericEntry").
RUNONCEPATH("0:/lib/Numerical/Chutes/ParachuteTrajectoryCalculator").

parameter currError is 0.
parameter parachuteAltitude is 2000.

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
	local ga is "0:/auxiliary/GuideAuxiliary".
	PROCESSOR("Slave1"):CONNECTION:SENDMESSAGE(ga).
	PROCESSOR("Slave1"):CONNECTION:SENDMESSAGE(parachuteAltitude).
	
	local pa is "0:/auxiliary/ParachuteAuxiliary".
	PROCESSOR("Slave2"):CONNECTION:SENDMESSAGE(pa).
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

local lastUpdate is TIME.
local updateTime is 0.5.

local currImpact is 0.
local parachuteAdj is 0.
local currDistance is 10000.

local function UpdateState{
	UNTIL messageBuffer:EMPTY{
		local msg is messageBuffer:POP():CONTENT.
		if msg["Header"] = "Parachute" {
			set parachuteAdj to msg["XP"].
			set parachuteAltitude to msg["ZP"].
			PROCESSOR("Slave1"):CONNECTION:SENDMESSAGE(parachuteAltitude).
		} else if msg["Header"] = "Guide" {
			sim:InitEntryGuide(msg["Guide"]).
		} else {
			PRINT msg.
		}
	}
	set currDistance to GlobeDistance(pad,ship:GEOPOSITION).
	set currImpact to sim:EntryGuide(2).
	if currImpact > 0 
		set currError to currDistance-currImpact-parachuteAdj.
	set updateTime to ((TIME-lastUpdate):SECONDS).
	set lastUpdate to TIME.
}

local function TargetHeading{
	local tv is pad:ALTITUDEPOSITION(ALTITUDE):NORMALIZED.
	local ang is VCRS(SRFPROGRADE:VECTOR, tv)*SRFPROGRADE:TOPVECTOR*CONSTANT:RadToDeg.
	//NPrint("ha",ang).
	return pad:HEADING+ang.
}

local function TaretPitch{
	local ang is currError/currDistance*CONSTANT:RadToDeg.
	if(ALTITUDE > 10000)
		set ang to ang*ALTITUDE/10000.
	set ang to MIN(5,MAX(-5,ang)).
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

WHEN parachuteAltitude >= ALTITUDE THEN {	CHUTES ON.}

UNTIL currDistance < parachuteAdj {
	UpdateState().
	local ptch is 90-VANG(SRFPROGRADE:VECTOR,UP:VECTOR).
	local currPtch is 90-VANG(-FACING:VECTOR,UP:VECTOR).
	local tgtPtch is TaretPitch().
	set stl to HEADING(TargetHeading(),tgtPtch).
	WAIT 0.
	CLEARSCREEN.
	NPrint("Update time",updateTime).
	NPrint("currDistance",currDistance).
	NPrint("currImpact",currImpact).
	NPrint("currError",currError).
	NPrint("SrfPitch",ptch).
	NPrint("CurrPitch",currPtch-ptch).
	NPrint("TgtPtchDiff",tgtPtch-ptch).
}
LOCK STEERING TO SRFRETROGRADE.
WAIT UNTIL GROUNDSPEED < 5.

LOCK STEERING TO -(pad:POSITION).
WAIT UNTIL ALTITUDE < 150.

LOCK STEERING TO UP.
RUN LandingA.
NPRINT("pad dist",GlobeDistance(pad,ship:GEOPOSITION)).
NPRINT("pad dist",GlobeDistance(pad,ship:GEOPOSITION)).