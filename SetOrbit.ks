RUNONCEPATH("0:/lib/Orbit").

parameter fnc, value.

local apsisList is lexicon(
	"ap", SetApoapsis@,
	"pe", SetPeriapsis@,
	"pa", SetPeriapsis@
).
local timeList is lexicon(
	"period", SetPeriodByApoapsis@
).

SAS OFF.
if apsisList:HASKEY(fnc) {
	apsisList[fnc](value*1000).
}
if timeList:HASKEY(fnc) {
	timeList[fnc](value*3600).
}
SAS ON.