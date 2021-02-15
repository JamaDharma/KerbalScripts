RUNONCEPATH("0:/lib/Debug").
function MakeRoverPoint{
	return lexicon(
		"ArrowTip", { return ship:POSITION.},
		"Dir", { return ship:FACING.},
		"Geo", { return ship:GEOPOSITION.}
	).
}
function MakeWaypointControl{
	parameter gp, pw is 0.
	
	local localBody is gp:BODY.
	
	local drawGP is VECDRAW(
		{ return gp:POSITION.},
		UpArrow@,
		RED,"",1,true).
	local drawRT is VECDRAW(
		CHOOSE pw:ArrowTip IF pw <> 0 ELSE V(0,0,0),
		{ return gp:POSITION - pw:Geo():POSITION.},
		RED,"",1,pw <> 0).
	
	function SetPrevWP{
		parameter wp.
		set pw to wp.
		if pw <> 0 {
			set drawRT:STARTUPDATER to pw:ArrowTip.
			set drawRT:SHOW to true.
		} else {
			set drawRT:SHOW to false.
		}
	}
	
	function UpArrow{
		return (gp:POSITION - localBody:POSITION)*0.0025.
	}
	
	function SetColor{ 
		parameter clr. 
		set drawGP:COLOR to clr. 
		set drawRT:COLOR to clr.
	}
	function Highlighted{
		parameter h.
		if h SetColor(RED).
		else SetColor(GREEN).
	}
	
	function Dir{
		if pw = 0 return ship:FACING.
		
		local vct is gp:POSITION-pw:Geo():POSITION.
		if vct:SQRMAGNITUDE < 0.1
			return pw:Dir().
		
		return LOOKDIRUP(vct, gp:POSITION - localBody:POSITION).
	}
	
	function MoveP{
		parameter d,l.
		
		local upv is gp:POSITION - localBody:POSITION.
		local fV is VXCL(upv,d):NORMALIZED*l.
		set gp to localBody:GEOPOSITIONOF(gp:POSITION+fv).
	}
	
	function Dispose{
		set drawGP:SHOW to false. 
		set drawRT:SHOW to false.
	}
	
	return lexicon(
		"ArrowTip", { return gp:POSITION + UpArrow().},
		"Highlighted", Highlighted@,
		"Dispose", Dispose@,
		"Color", SetColor@,
		
		"SetPrevWP", SetPrevWP@,
		"Dir", Dir@,
		"Move", MoveP@,
		"Geo", { return gp.}
	).
}
