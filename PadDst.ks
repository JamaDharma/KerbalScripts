RUNONCEPATH("0:/lib/Debug").
RUNONCEPATH("0:/lib/Targeting").
RUNONCEPATH("0:/lib/Surface/SurfaceAt").
RUNONCEPATH("0:/lib/Surface/KerbinPoints").

//prints distances to target and launchpad

CLEARVECDRAWS().
set padVec to VECDRAW(
	pad:POSITION,
	pad:POSITION-BODY:POSITION,
	RED,"",2,true).

PRINT GlobeDistance(pad,ship:GEOPOSITION).
local tgt is GetTargetGeo().
set tgtVec to VECDRAW(
	tgt:POSITION,
	tgt:POSITION-BODY:POSITION,
	RED,"",2,true).	
PRINT GlobeDistance(GetTargetGeo(),ship:GEOPOSITION).