RUNONCEPATH("0:/lib/Debug").

function MakeRoverPoint{
	return lexicon(
		"Origin", { return ship:POSITION.},
		"Dir", { return ship:FACING.},
		"Geo", { return ship:GEOPOSITION.}
	).
}

function MakeWaypointControl{
	parameter gp, pw is 0.
	
	local localBody is gp:BODY.
	local upArrowLenght is 2000.
	local originHeight is 500.
	
	local drawGP is VECDRAW(
		{ return gp:POSITION.},
		UpArrow@,
		RED,"",1,true).
	local drawRT is VECDRAW(
		CHOOSE pw:Origin IF pw <> 0 ELSE V(0,0,0),
		{ return Origin() - pw:Origin().},
		RED,"",1,pw <> 0).
	
	function SetPrevWP{
		parameter wp.
		set pw to wp.
		if pw <> 0 {
			set drawRT:STARTUPDATER to pw:Origin.
			set drawRT:SHOW to true.
		} else {
			set drawRT:SHOW to false.
		}
	}
	function Origin{
		local th is gp:TERRAINHEIGHT.
		return (gp:ALTITUDEPOSITION(th+originHeight)).
	}
	function UpArrow{
		return (gp:ALTITUDEPOSITION(upArrowLenght) - gp:ALTITUDEPOSITION(0)).
	}
	
	function SetColor{ 
		parameter clr. 
		set drawGP:COLOR to clr. 
		set drawRT:COLOR to clr.
	}
	function Highlighted{
		parameter h is true.
		if h SetColor(RED).
		else SetColor(GREEN).
	}
	
	function Dir{
		if pw = 0 return ship:FACING.
		
		local vct is gp:ALTITUDEPOSITION(0)-pw:Geo():ALTITUDEPOSITION(0).
		if vct:SQRMAGNITUDE < 1
			return pw:Dir().
		
		return LOOKDIRUP(vct, gp:ALTITUDEPOSITION(0) - localBody:POSITION).
	}
	
	function MoveP{
		parameter d,l.
		
		local upv is gp:POSITION - localBody:POSITION.
		local fV is VXCL(upv,d):NORMALIZED*l.
		set gp to localBody:GEOPOSITIONOF(gp:POSITION+fv).
	}
	
	function Shown{
		parameter s.
		set drawGP:SHOW to s. 
		set drawRT:SHOW to s.
	}
	
	return lexicon(
		"Origin", Origin@,
		"Highlighted", Highlighted@,
		"Shown", Shown@,
		"Color", SetColor@,
		
		"SetPrevWP", SetPrevWP@,
		"Dir", Dir@,
		"Move", MoveP@,
		"Geo", { return gp.}
	).
}
