RUNONCEPATH("0:/lib/Debug").
RUNONCEPATH("0:/lib/Storage").

local resNames is list("LiquidFuel","Oxidizer","Ore").

local refuelMode is "RefuelMode".
local storage is LocalStorage().

local rigName is storage:GetValue("RigName").
local rig is 0.
local tanker is list().

local function UpdateElements{
	local ves is CORE:PART:SHIP.
	tanker:CLEAR().
	for elem in ves:ELEMENTS {
		if elem:NAME = rigName set rig to elem.
		else tanker:ADD(elem).
	}
}

local function GetResource{
	parameter resName, resList.
	for res in resList {
		if res:NAME = resName return res.
	}
}
local function TransferResource{
	parameter resName, source, dest.
	
	local xferAmount is MIN(source:AMOUNT,dest:CAPACITY-dest:AMOUNT).
	if xferAmount > 1 {
		local xfer is TRANSFER(resName, source:PARTS, dest:PARTS, xferAmount).
		set xfer:ACTIVE to TRUE.
		WAIT 0.1.
		WAIT UNTIL not xfer:ACTIVE.
	}
}

local function OnTankerConnected{
	for resName in resNames {
		local rigRes is GetResource(resName,rig:RESOURCES).
		for p in rigRes:PARTS {
			set GetResource(resName,p:RESOURCES):ENABLED to FALSE.
		}
		for tElem in tanker {
			local tRes is GetResource(resName,tElem:RESOURCES).
			TransferResource(resName,rigRes,tRes).
		}
	}
}
local function OnTankerDisconnected{
	for resName in resNames {
		local rigRes is GetResource(resName,rig:RESOURCES).
		for p in rigRes:PARTS {
			local res is GetResource(resName,p:RESOURCES).
			set res:ENABLED to TRUE.
		}
	}
}



UNTIL false {
	WAIT 10.
	UpdateElements().
	if tanker:LENGTH > 0 {
		if not storage:GetValue(refuelMode) {
			OnTankerConnected().
			storage:SetValue(refuelMode, true).
			storage:Save().
		}
	} else {
		if storage:GetValue(refuelMode) {
			OnTankerDisconnected().
			storage:SetValue(refuelMode, false).
			storage:Save().
		}
	}
}
