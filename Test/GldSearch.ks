RUNONCEPATH("0:/lib/Debug").
RUNONCEPATH("0:/lib/Search/GoldenSearch").

local realVal is 0.88.
local val is 0.
local cnt is 0.
local cmp is MakeSearchComponent( 1, 1/16, {parameter dA. set val to val + dA.}).
local function Metric{
	PRINT "Trying value:" + ROUND(val,3) +" error: "+ROUND(val - realVal,3).
	set cnt to cnt+1.
	return ABS(val - realVal).
}
PRINT "Start from: " + val.
GSearch(	Metric@,cmp).
print (ABS(val - realVal) < 1/16) + " count: "+ cnt.
WAIT 3.
set val to 1.
set cnt to 0.
PRINT "Start from: " + val.
GSearch(	Metric@,cmp).
print (ABS(val - realVal) < 1/16) + " count: "+ cnt.
WAIT 3.
set val to 3.
set cnt to 0.
PRINT "Start from: " + val.
GSearch(	Metric@,cmp).
print (ABS(val - realVal) < 1/16) + " count: "+ cnt.