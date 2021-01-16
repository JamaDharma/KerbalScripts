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
	parameter cotPstn is CoTPosition().
	
	local cotV is cotPstn:NORMALIZED. 
	local cotM is cotPstn:MAG.
	
	NPrint("Starting discrepancy",cotM).
	if cotM < 0.01 { print "Already balanced!". return false. }

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
	
	if src = dst  { PRINT "Only one tank for "+fuel. return false. }
	
	local dm is (dst[0]:POSITION-src[0]:POSITION)*cotV.
	NPrint("Correction base",dm).
	local m is MASS*cotM/(cotM+dm).
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

local function BalanceFuelType{
	parameter fuel.
	PRINT "Balancing "+fuel.
	local tanks is TankList(fuel).
	until not MakeTransfer(tanks, fuel).
	PRINT "-------------".
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

BalanceFuelType("LiquidFuel").
BalanceFuelType("Oxidizer").

NPrint("Final imbalance: ", CoTPosition():MAG).

WAIT UNTIL terminal:input:haschar.
CLEARVECDRAWS().


	