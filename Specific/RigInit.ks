RUNONCEPATH("0:/lib/Debug").
RUNONCEPATH("0:/lib/Storage").

local storage is LocalStorage().
storage:SetValue("RefuelMode", true).
storage:SetValue("RigName", "MunRig").
storage:Save().

set CORE:BOOTFILENAME to "/Specific/RigRefuelWatcher.ks".

REBOOT.