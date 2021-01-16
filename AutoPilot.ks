RUNONCEPATH("0:/lib/Debug").
RUNONCEPATH("0:/lib/Targeting").

local targetLock is false.
local selectedTarget is "nothing".
local function ToggleTargetLock{
	if targetLock {
		UNLOCK compasLock.
		set targetLock to false.
		set compasLock to Compas().
		PRINT "Compass unlocked!".
		return.
	}
	
	local tgt is GetTarget().
	if tgt:LENGTH = 0 return.
	
	set selectedTarget to tgt[0].
	LOCK compasLock to selectedTarget:HEADING.
	set targetLock to true.
	PRINT "Compass locked to target!".
}

local function SetCompas{
	parameter cmp.
	if targetLock { PRINT "Compass locked!". return. }
	set compasLock to cmp.
}

function Compas {
	return MOD(360-SHIP:BEARING,360).
}

function SetDefaults{
	SetCompas(Compas()).
	set pitchLock to 0.
	set rollLock to 0.
	NPrint("Heading",compasLock).
	NPrint("Pitch",pitchLock).
	NPrint("Roll",rollLock).
}

set exit to false.

WHEN terminal:input:haschar THEN {
	local ch is terminal:input:getchar().
	if ch = "w" {
		set pitchLock to MAX(pitchLock - 0.2, -30).
		NPrint("Pitch down",pitchLock).
	} else if ch = "s" {
		set pitchLock to MIN(pitchLock + 0.2, 30).
		NPrint("Pitch up",pitchLock).
	} else if ch = "a" {
		SetCompas(compasLock - 0.5).
		NPrint("New left heading",compasLock).
	} else if ch = "d" {
		SetCompas(compasLock + 0.5).
		NPrint("New right heading",compasLock).
	} else if ch = "q" {
		set rollLock to rollLock + 1.
		NPrint("Roll left",rollLock).
	} else if ch = "e" {
		set rollLock to rollLock - 1.
		NPrint("Roll right",rollLock).
	} else if ch = terminal:input:HOMECURSOR {
		ToggleTargetLock().
	} else if ch = terminal:input:ENDCURSOR {
		set exit to true.
	} else {
		SetDefaults().
		NPrint("New heading",compasLock).
	}
	return true.
}


CLEARSCREEN.

SetDefaults().

SAS OFF.

LOCK STEERING TO HEADING(compasLock,pitchLock,rollLock).

WAIT UNTIL exit.

SAS ON.