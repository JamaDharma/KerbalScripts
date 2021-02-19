RUNONCEPATH("0:/lib/Debug").
RUNONCEPATH("0:/lib/Rover/WaypointControl").

function MakeNavigationControl{
	parameter gpList is list().
	if gpList:LENGTH = 0
		gpList:ADD(ship:GEOPOSITION).
	
	local wpts is list(MakeWaypointControl(gpList[0],MakeRoverPoint())).
	local curWp is 0.
	FROM {local i is 1.} UNTIL i = gpList:LENGTH STEP {set i to i+1.} DO {
		AddWP(gpList[i]).
	}
	
	local stepSizeValue is 1000.
	function StepSize{
		parameter scl is 0.
		if scl > 0
			set stepSizeValue to scl.
		return stepSizeValue.
	}
	
	function AddWP{
		local wpp is wpts[curWp].
		parameter gp is wpp:Geo().
		
		local cwp is MakeWaypointControl(gp,wpp).
		wpp:Highlighted(false).
		
		set curWp to curWp+1.
		if curWp < wpts:LENGTH
			wpts[curWp]:SetPrevWP(cwp).
		
		wpts:INSERT(curWp,cwp).
	}
	function SwitchWP{
		parameter di.
		
		local i is curWp + di.
		
		if i < 0 or i >= wpts:LENGTH return false.
		
		wpts[curWp]:Highlighted(false).
		set curWp to i.
		wpts[curWp]:Highlighted(true).
		return true.
	}
	function MoveF{
		parameter sign.
		local wp is wpts[curWp].
		wp:MOVE(wp:Dir():FOREVECTOR,StepSize()*sign).
	}
	function MoveR{
		parameter sign.
		local wp is wpts[curWp].
		wp:MOVE(wp:Dir():STARVECTOR,StepSize()*sign).
	}
	function MakeGeoList{
		local result is list().
		for wp in wpts {
			result:ADD(wp:Geo()).
		}
		return result.
	}
	local shownState is TRUE.
	function Shown{
		parameter s is shownState.
		if s <> shownState {
			set shownState to s.
			for wp in wpts {
				wp:Shown(shownState).
			}
		}
		return shownState.
	}
	local this is lexicon(
		"SwitchWP",SwitchWP@,
		"AddWP",AddWP@,
		"StepSize",StepSize@,
		"MoveF",MoveF@,
		"MoveR",MoveR@,
		"Shown",Shown@,
		"GeoList",MakeGeoList@
	).
	return this.
}
