RUNONCEPATH("0:/lib/Debug").
RUNONCEPATH("0:/lib/Targeting").
RUNONCEPATH("0:/lib/Surface/Surface").
RUNONCEPATH("0:/lib/Aircraft/Steering").

local targetLock is false.
local selectedTarget is "nothing".
local GetCompas is {RETURN compasLock.}.
local function ToggleTargetLock{
	if targetLock {
		set GetCompas to {RETURN compasLock.}.
		set targetLock to false.
		set compasLock to Compas().
		PRINT "Compass unlocked!".
		return.
	}
	
	local tgt is GetTarget().
	if tgt:LENGTH = 0 return.
	
	set selectedTarget to tgt[0].
	set GetCompas to {RETURN selectedTarget:HEADING.}.
	set targetLock to true.
	PRINT "Compass locked to target!".
}

local function SetCompas{
	parameter cmp.
	if targetLock { PRINT "Compass locked - heading not changed!". return. }
	set compasLock to cmp.
}

function Compas {
	return MOD(360-SHIP:BEARING,360).
}

function SetDefaults{
	SetCompas(Compas()).
	set pitchLock to ROUND(GetPitch()*5)/5.
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
	} else if ch = "i" {
		local dst is selectedTarget:DISTANCE.
		NPrintMany("Distance",dst,"ETA",dst/AIRSPEED).
	} else {
		SetDefaults().
		NPrint("New heading",compasLock).
	}
	return true.
}


CLEARSCREEN.

SetDefaults().

SAS OFF.

local dsc is NewDirSteeringController().
LOCK STEERING TO dsc(HEADING(GetCompas(),pitchLock,rollLock)).

UNTIL exit {
	if targetLock AND GlobeDistance(GEOPOSITION,selectedTarget) <  GROUNDSPEED*5  
		ToggleTargetLock().
}

SAS ON.

WAIT 1.