RUNONCEPATH("0:/lib/Debug").
RUNONCEPATH("0:/lib/Targeting").
RUNONCEPATH("0:/lib/Rover/NavigationControl").
RUNONCEPATH("0:/lib/Rover/NavigationGUI").


local nc is MakeNavigationControl().
local gui is MakeNavigationGUI(nc).


gui:SHOW().
WAIT UNTIL false.