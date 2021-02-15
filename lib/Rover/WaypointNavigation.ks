RUNONCEPATH("0:/lib/Debug").
RUNONCEPATH("0:/lib/Targeting").
RUNONCEPATH("0:/lib/Ship/RoverCruiseInfo").

local function MakeWaypointControl{
	parameter gp, pw is 0.
	
	local localBody is gp:BODY.
	local drawGP is VECDRAW(
		{ return gp:POSITION.},
		UpArrow@,
		RED,"",1,true).
	
	local drawRT is VECDRAW(
		CHOOSE pw["UpArrowP"] IF pw <> 0 ELSE V(0,0,0),
		{ return gp:POSITION - pw:Geo():POSITION.},
		RED,"",1,pw <> 0).
	
	function UpArrow{
		return (gp:POSITION - localBody:POSITION)*0.0025.
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
	
	return lexicon(
		"Move", MoveP@,
		"UpArrowP", { return gp:POSITION + UpArrow().},
		"Dir", Dir@,
		"Color", { parameter clr. set drawGP:COLOR to clr. set drawRT:COLOR to clr.},
		"Geo", { return gp.}
	).
}
local function MakeNavigationControl{
	local wpts is list(MakeWaypointControl(ship:GEOPOSITION)).
	local curWp is wpts:LENGTH-1.
	AddWP().
	
	function StepScale{
		parameter scl is 0.
		return 1000.
	}
	
	function AddWP{
		local wp is wpts[curWp].
		wpts:ADD(MakeWaypointControl(wp:Geo(),wp)).
		set curWp to wpts:LENGTH-1.
		wp:Color(GREEN).
	}
	function SwitchWP{
		parameter di.
		
		local i is curWp + di.
		
		if i < 0 or i >= wpts:LENGTH return false.
		
		wpts[curWp]:Color(GREEN).
		set curWp to i.
		wpts[curWp]:Color(RED).
		return true.
	}
	function MoveF{
		parameter sign.
		local wp is wpts[curWp].
		wp:MOVE(wp:Dir():FOREVECTOR,StepScale()*sign).
	}
	function MoveR{
		parameter sign.
		local wp is wpts[curWp].
		wp:MOVE(wp:Dir():STARVECTOR,StepScale()*sign).
	}
	function MakeGeoList{
		local result is list().
		for wp in wpts {
			result:ADD(wp:Geo()).
		}
		return result.
	}
	local this is lexicon(
		"SwitchWP",SwitchWP@,
		"AddWP"	,AddWP@,
		"MoveF"	,MoveF@,
		"MoveR"	,MoveR@,
		"GeoList",MakeGeoList@
	).
	return this.
}


local nc is MakeNavigationControl().

LOCAL gui IS GUI(200).
local function FillMain{
	parameter lo.
	LOCAL prevB is lo:ADDBUTTON("Prev").
	set prevB:ONCLICK to nc:SwitchWP:BIND(-1).
	LOCAL nextB is lo:ADDBUTTON("Next").
	set prevB:ONCLICK to nc:SwitchWP:BIND(1).
	lo:ADDSPACING(-1).
	LOCAL saveB is lo:ADDBUTTON("Save").
	set saveB:ONCLICK to {
		local lst is nc:GeoList().
		lst:ADD(GetTargetGeo()).
		WriteCruiseRoute(lst).
	}.
}
FillMain(gui:ADDHLAYOUT()).

local function FillDirControl{
	parameter lo.

	local subL is lo:ADDVLAYOUT().
	subL:ADDSPACING(-1).
	LOCAL lB is subL:ADDBUTTON("Left").
	set lB:ONCLICK to nc:MoveR:BIND(-1).
	subL:ADDSPACING(-1).

	set subL to lo:ADDVLAYOUT().
	LOCAL fB is subL:ADDBUTTON("Fwrd").
	set fB:ONCLICK to nc:MoveF:BIND(1).
	LOCAL addB is subL:ADDBUTTON("Add").
	set addB:ONCLICK to nc:AddWP.
	LOCAL bB is subL:ADDBUTTON("Back").
	set bB:ONCLICK to nc:MoveF:BIND(-1).

	set subL to lo:ADDVLAYOUT().
	subL:ADDSPACING(-1).
	LOCAL rB is subL:ADDBUTTON("Rght").
	set rB:ONCLICK to nc:MoveR:BIND(1).
	subL:ADDSPACING(-1).
}
local function FillScaleControl{
	parameter lo.
	LOCAL plusB is lo:ADDBUTTON(" + ").
	LOCAL minusB is lo:ADDBUTTON(" - ").
}
local function FillControl{
	parameter lo.
	FillDirControl(lo:ADDHLAYOUT()).
	lo:ADDSPACING(-1).
	FillScaleControl(lo:ADDVLAYOUT()).
}
FillControl(gui:ADDHLAYOUT()).

local function FillInfo{
	parameter lo.
	local subL is lo:ADDHLAYOUT().
	LOCAL latL is subL:ADDLABEL("LAT").
	subL:ADDSPACING(-1).
	LOCAL latF is subL:ADDTEXTFIELD(" ").

	set subL to lo:ADDHLAYOUT().
	LOCAL lngL is subL:ADDLABEL("LNG").
	subL:ADDSPACING(-1).
	LOCAL lngF is subL:ADDTEXTFIELD(" ").
	
	set subL to lo:ADDHLAYOUT().
	LOCAL scaleL is subL:ADDLABEL("Scale").
	subL:ADDSPACING(-1).
	LOCAL scaleF is subL:ADDTEXTFIELD("1000").
}
FillInfo(gui:ADDVLAYOUT()).

local function FillExit{
	parameter lo.
	lo:ADDSPACING(-1).
	LOCAL bB is lo:ADDBUTTON("Exit").
}
FillExit(gui:ADDHLAYOUT()).

gui:SHOW().
WAIT UNTIL false.