RUNONCEPATH("0:/lib/Debug").
RUNONCEPATH("0:/lib/Search/GoldenSearch").
RUNONCEPATH("0:/lib/Search/BinarySearch").

local realVal is 0.88.
local val is 0.
local cnt is 0.
local cmp is MakeSearchComponent( 1, 1/16, {parameter dA. set val to val + dA.}).
local function MetricG{
	PRINT "Trying value:" + ROUND(val,3) +" error: "+ROUND(val - realVal,3).
	set cnt to cnt+1.
	return ABS(val - realVal).
}
local function MetricB{
	PRINT "Trying value:" + ROUND(val,3) +" error: "+ROUND(val - realVal,3).
	set cnt to cnt+1.
	return val - realVal.
}
local gs is {GSearch(MetricG@,cmp).}.
local bs is {BSearch(MetricB@,cmp).}.

local function RunTest{
	parameter start, search.
	set val to start.
	set cnt to 0.
	PRINT "Start from: " + val.
	search().
	local succ is (ABS(val - realVal) < 1/16).
	if not succ {
		SET V0 TO GetVoice(0).
		V0:PLAY( NOTE( 440, 1) ).
	}
	print "Success: "+ succ + "   count: "+ cnt.
	WAIT 3.
}

RunTest(0,gs).
RunTest(0,bs).
RunTest(1,gs).
RunTest(1,bs).
RunTest(3,gs).
RunTest(3,bs).
