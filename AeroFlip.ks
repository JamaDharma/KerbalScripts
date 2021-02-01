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
local function FRV{
	return ship:FACING:FOREVECTOR.
}

local function TankList{
	parameter fuel.
	local result is list().
	LIST PARTS in prtLst.
	FOR p IN prtLst {
		FOR res IN p:RESOURCES {
			IF res:NAME = fuel {
				result:ADD(list(p,res)).
			}
		}
	}
	return result.
}

local function MakeTransfer{
	parameter pList,fuel.

	local srcList is list().
	local dstList is list().
	for p in pList {
		if p[1]:AMOUNT > 1 {srcList:ADD(p).}
		if p[1]:CAPACITY - p[1]:AMOUNT > 1 { dstList:ADD(p).}
	}
	
	if srcList:LENGTH = 0 { print "All empty of "+fuel. return false. }
	if dstList:LENGTH = 0 { print "All full of "+fuel. return false. }
	
	local src is srcList[0].
	for p in srcList {
		if src[0]:POSITION*FRV < p[0]:POSITION*FRV {
			set src to p.
		}
	}
	
	local dst is dstList[0].
	for p in dstList {
		if dst[0]:POSITION*FRV > p[0]:POSITION*FRV {
			set dst to p.
		}
	}
	
	if src = dst  { PRINT "Only one tank for "+fuel. return false. }
	
	local tfer is TRANSFERALL(fuel,src,dst).
	PRINT "Transferring from " + src[0]:NAME + " to " + dst[0]:NAME.
	SET tfer:ACTIVE to TRUE.
}
InverseControl().
local tanks is TankList("LiquidFuel").
MakeTransfer(tanks, "LiquidFuel").
MakeTransfer(TankList("Oxidizer"), "Oxidizer").
SAS ON.
CHUTES OFF.
WAIT 0.5.
set SASMODE to "RETROGRADE".
WAIT 0.5.
