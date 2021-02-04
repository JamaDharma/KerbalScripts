RUNONCEPATH("0:/lib/Rendezvous").

// Create a GUI window
LOCAL gui IS GUI(200).
local mainL is gui:ADDHLAYOUT().
LOCAL findB TO mainL:ADDBUTTON("Start search").
LOCAL updateB TO mainL:ADDBUTTON("Update info").
LOCAL timeLH IS mainL:ADDLABEL("Time, h:").
set timeLH:STYLE:WORDWRAP to false.
set timeLH:STYLE:ALIGN to "RIGHT".
set timeLH:STYLE:HSTRETCH to true.
LOCAL timeTFH TO mainL:ADDTEXTFIELD(" ").
set timeTFH:STYLE:WIDTH to 50.
set timeTFH:STYLE:ALIGN to "RIGHT".
LOCAL timeLM IS mainL:ADDLABEL(" m:").
LOCAL timeTFM TO mainL:ADDTEXTFIELD(" ").
set timeTFM:STYLE:WIDTH to 50.
set timeTFM:STYLE:ALIGN to "RIGHT".

local infoL is gui:ADDHLAYOUT().
LOCAL distL IS infoL:ADDLABEL("Distance:").
LOCAL distV IS infoL:ADDLABEL("0").
LOCAL timeL IS infoL:ADDLABEL("Time:").
LOCAL timeV IS infoL:ADDLABEL("0").
LOCAL burnL IS infoL:ADDLABEL("Burn:").
LOCAL burnV IS infoL:ADDLABEL("0").
local function FillInfo{
	local t is MinimalSeparationTime(timeTFH:TEXT:TONUMBER(0),timeTFM:TEXT:TONUMBER(0)).
	set distV:TEXT to ROUND(Separation(t),1):TOSTRING.
	set timeV:TEXT to ToTime(t).
	set burnV:TEXT to ROUND(DVTotal(t),1):TOSTRING.
	local ts is t-time.
	set timeTFH:TEXT to FLOOR(ts:SECONDS/3600):TOSTRING.
	set timeTFM:TEXT to ts:MINUTE:TOSTRING.
}
set updateB:ONCLICK TO FillInfo@.

local selectL is gui:ADDHLAYOUT().
LOCAL fnlRB IS selectL:ADDRADIOBUTTON("Fnl", true).
LOCAL rndRB IS selectL:ADDRADIOBUTTON("Rnd", false).
LOCAL encRB IS selectL:ADDRADIOBUTTON("Enc", false).

LOCAL exitL is gui:ADDHLAYOUT().
LOCAL statusL is exitL:ADDLABEL("").
exitL:ADDSPACING(-1).
LOCAL exitB is exitL:ADDBUTTON("EXIT").
set exitB:STYLE:WIDTH to 100.

local fncList is lexicon(
	"chk", CheckRendezvousMetric@,
	"fnl", FinalApproach@,
	"rnd", MakeRendezvous@,
	"enc", MakeEncounter@
).

// Show the GUI.
gui:SHOW().

UNTIL exitB:TAKEPRESS {
	if findB:TAKEPRESS {
		local fnc is selectL:RADIOVALUE.
		if fncList:HASKEY(fnc) {
			set statusL:TEXT to "Searching...".
			fncList[fnc](timeTFH:TEXT:TONUMBER(0),timeTFM:TEXT:TONUMBER(0),0).
			FillInfo().
			set statusL:TEXT to "Search finished!".
		}
	}
	WAIT 0.25.
}

CLEARGUIS().