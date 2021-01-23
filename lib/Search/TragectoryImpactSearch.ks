RUNONCEPATH("0:/lib/Search/BinarySearch").

local function Gravity {
	return body:mu/body:radius^2.
}

local function AltAtP{
	parameter p.
	local th is BODY:GEOPOSITIONOF(p):TerrainHeight.
	return ((p - BODY:POSITION):MAG - BODY:RADIUS - th).
}

local function AltAtT{
	parameter t.
	return AltAtP(POSITIONAT(SHIP,t)).
}

function TragectoryImpactTime{
	parameter minSepTime is time.
	local aboveGrnd is 100.
	BSearch({ 
			local mtr is AltAtT(minSepTime)-aboveGrnd.
			if mtr > aboveGrnd return aboveGrnd+1/(minSepTime+500-time:SECONDS).
			return ABS(mtr).
		},
		MakeBSComponent( 1, 0.1, 
		{ parameter dT. set minSepTime to minSepTime + dT.})
	).
	
	return minSepTime.
}

function TragectoryBurnTime{
	parameter impT is TragectoryImpactTime().
	
	local iVec is VELOCITYAT(ship,impT):SURFACE.
	local upVec is (POSITIONAT(ship,impT) - ship:BODY:POSITION).
	local avgAng is (180+VANG(upVec, iVec))/2.
	local gCorr is COS(avgAng)*Gravity().//neg value
	
	local vBurn is iVec:MAG.
	local tBurn is vBurn/(MAXTHRUST/mass+gCorr).
	
	return tBurn.
}