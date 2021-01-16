RUNONCEPATH("0:/lib/Debug").
RUNONCEPATH("0:/lib/Engines").

local function FRV{
	return ship:FACING:FOREVECTOR.
}

local function CoTPosition{
	local engList is ListActiveEngines().
	local trustPos is V(0,0,0).
	FOR eng IN engLst {
		set trustPos to trustPos + eng:POSITION*eng:MAXTHRUST.
	}
	set trustPos to trustPos/MAXTHRUST.
	return VXCL(FRV(),trustPos).
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
	
	local cotP is CoTPosition().
	local cotV is cotP:NORMALIZED. 
	local cotM is cotP:MAG.
	NPrint("Starting discrepancy",cotM).

	local srcList is list().
	local dstList is list().
	for p in pList {
		if p[1]:AMOUNT > 1 {srcList:ADD(p).}
		if p[1]:CAPACITY - p[1]:AMOUNT > 1 { dstList:ADD(p).}
	}
	
	if srcList:LENGTH = 0 or dstList:LENGTH = 0 { print "no usable transfers". return false. }
	
	local src is srcList[0].
	for p in srcList {
		if src[0]:POSITION*cotV > p[0]:POSITION*cotV {
			set src to p.
		}
	}
	
	local dst is dstList[0].
	for p in dstList {
		if dst[0]:POSITION*cotV < p[0]:POSITION*cotV {
			set dst to p.
		}
	}
	
	if src = dst  { return false. }
	
	local dm is (dst[0]:POSITION-src[0]:POSITION)*cotV.
	NPrint("Correction base",dm).
	local m is MASS*cotP:MAG/(cotP:MAG+dm).
	NPrint("Correction mass",m).
	local amt is m/dst[1]:DENSITY.
	local tfer is TRANSFER(fuel,src,dst,amt).
	PRINT "Transferring from " + src[0]:NAME + " to " + dst[0]:NAME.
	NPrint("Transfer amount",amt).
	SET tfer:ACTIVE to TRUE.
	WAIT 0.1.
	WAIT UNTIL not tfer:ACTIVE.
	return true.
}
CLEARVECDRAWS().
set mylist to list().
mylist:ADD(VECDRAW(
		V(0,0,0),
		FRV()*20,
		GREEN,"",0.5,true)).
mylist:ADD(VECDRAW(
		{return CoTPosition().},
		FRV()*20,
		RED,"",0.5,true)).

MakeTransfer(TankList("LiquidFuel"),"LiquidFuel").

print CoTPosition():MAG.

	