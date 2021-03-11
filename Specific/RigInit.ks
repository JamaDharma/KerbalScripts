RUNONCEPATH("0:/lib/Debug").
RUNONCEPATH("0:/lib/Storage").

local refuelMode is "RefuelMode".
local storage is LocalStorage().

storage:SetValue(refuelMode, true).
storage:SetValue("RigName", "MunRig").
set CORE:BOOTFILENAME to "0:/Specific/RigRefuelWatcher".
