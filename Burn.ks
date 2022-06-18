SAS OFF.
RUNONCEPATH("0:/lib/Orbit").

parameter fnc is "brn", tgtBody is Mun, tgtPeriapsis is 25.
set tgtPeriapsis to tgtPeriapsis*1000.

local fncList is lexicon(
    "brn", {ExecuteBurn(NEXTNODE).},
	"enc", {
        local tc is NewEncounterThrustControl(tgtBody,tgtPeriapsis).
        BurnExecutor(ProgradeBurnControl(NEXTNODE,tc)).
    }
).

if fncList:HASKEY(fnc) {
    fncList[fnc]().
} else {
    PRINT fncList:KEYS.
}

SAS ON.