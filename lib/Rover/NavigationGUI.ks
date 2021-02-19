RUNONCEPATH("0:/lib/Debug").
RUNONCEPATH("0:/lib/Rover/CruiseInfo").

function MakeNavigationGUI{
	parameter nc.
	local stepSizeField is 0.
	LOCAL gui IS GUI(200).
	local function FillMain{
		parameter lo.
		LOCAL prevB is lo:ADDBUTTON("Prev").
		set prevB:ONCLICK to nc:SwitchWP:BIND(-1).
		LOCAL nextB is lo:ADDBUTTON("Next").
		set nextB:ONCLICK to nc:SwitchWP:BIND(1).
		lo:ADDSPACING(-1).
		LOCAL saveB is lo:ADDBUTTON("Save").
		set saveB:ONCLICK to {
			local lst is nc:GeoList().
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
	local function UpdStepSize{
		set stepSizeField:TEXT to ROUND(nc:StepSize()):TOSTRING.
	}
	local function FillScaleControl{
		parameter lo.
		LOCAL plusB is lo:ADDBUTTON(" + ").
		set plusB:ONCLICK to {nc:StepSize(nc:StepSize()*2).UpdStepSize().}.
		LOCAL minusB is lo:ADDBUTTON(" - ").
		set minusB:ONCLICK to {nc:StepSize(nc:StepSize()/2).UpdStepSize().}.
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
		LOCAL scaleF is subL:ADDTEXTFIELD(nc:StepSize():TOSTRING).
	//set scaleF:ONCONFIRM to {parameter txt. nc:StepSize(txt:TONUMBER(0)).UpdStepSize().}.
		set stepSizeField to scaleF.
	}
	FillInfo(gui:ADDVLAYOUT()).

	local function FillExit{
		parameter lo.
		lo:ADDSPACING(-1).
		LOCAL wB is lo:ADDBUTTON("Waypoints").
		set wB:ONCLICK to {nc:Shown(not nc:Shown()).}.
		LOCAL hB is lo:ADDBUTTON("Exit GUI").
		set hB:ONCLICK to {gui:HIDE().}.
	}
	FillExit(gui:ADDHLAYOUT()).
	
	return gui.
}
