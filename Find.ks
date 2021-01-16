RUNONCEPATH("0:/lib/Defaults").
RUNONCEPATH("0:/lib/Rendezvous").

parameter fnc, h, m is 0, s is 0.

local fncList is lexicon(
	"chk", CheckRendezvousMetric@,
	"fnl", FinalApproach@,
	"rnd", MakeRendezvous@,
	"enc", MakeEncounter@
).

if fncList:HASKEY(fnc) {
	fncList[fnc](h,m,s).
}