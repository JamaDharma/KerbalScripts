RUNONCEPATH("0:/lib/Debug").
RUNONCEPATH("0:/lib/Defaults").
RUNONCEPATH("0:/lib/Surface").
RUNONCEPATH("0:/lib/Targeting").
parameter minimalSpeed is 1.

local function SeparationNrm{
	parameter tT,tGP.
	return NormalizeGP(GeopositionAt(ship, tT)) - NormalizeGP(tGP).
}
function MakeTerminalControl{
	parameter tGP, setP, setT.
	local tgtH is tGP:TERRAINHEIGHT.
	local grv is body:mu/body:radius^2.
	local startBurn is false.
	
	function TerminalControl{
		local shipAcc is MAXTHRUST/MASS.
		local ang is VANG(UP:VECTOR,FACING:VECTOR).
		
		local hgh is ALTITUDE - tgtH.
		local vVel is -VERTICALSPEED.
		local vAcc is shipAcc*cos(ang) - grv.
		local vbT is vVel/vAcc+1.
		local vbD is vVel*vbT/2.
		local vK is vbD/hgh.
		
		local dst is (NormalizeGP(tGP) - NormalizeGP(ship)):MAG-10.
		local hVel is GROUNDSPEED.
		local hAcc is shipAcc*sin(ang).
		local hbT is hVel/hAcc+1.
		local hbD is hVel*hbT/2.
		local hK is hbD/dst.	

		NPrint("hgh",hgh).
		NPrint("vbD",vbD).
		NPrint("vK",vK).	

		NPrint("dst",dst).
		NPrint("hbD",hbD).
		NPrint("hK",hK).
		
		PRINT "-------------".
		
		if ABS(hK-vK) < 0.1
			if vbD > hgh-vVel or hbD > dst - hVel 
				set startBurn to true.

		setP(ang-vK*10+hK*10).
		if startBurn 
			setT(MAX(vK,hK)).
	}
	
	return TerminalControl@.
}

SAS OFF.

local pitchLock is 0.
LOCK STEERING TO HEADING(heading_of_vector(SRFRETROGRADE:VECTOR),pitchLock).

local function SetPitch{
	parameter p.
	set pitchLock to 90-p.
}

local tgt is GetTargetGeo().
set drawTGT to VECDRAW(
		V(0,0,0),
		{ return tgt:POSITION. },
		RED,"",5,true).
local terminalControl is MakeTerminalControl(tgt, SetPitch@, SetThrust@).
terminalControl().
UNTIL ABS(VERTICALSPEED) < minimalSpeed or GROUNDSPEED < minimalSpeed {
	terminalControl().
	WAIT 0.
}

run LandingV.