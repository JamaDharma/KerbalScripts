RUNONCEPATH("0:/lib/Storage").

parameter key, val.

local str is ShipTypeStorage().

str:SetValue(key,val).
str:Save().