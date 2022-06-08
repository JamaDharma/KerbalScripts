function Notify {
	parameter text, clr, dTime is 5, textSize is 40.
	HUDTEXT(text, dTime, 2, textSize, clr, true).
}
//prints name-value
function NPrint {
	parameter s,n.
	parameter p is 3.
	PRINT s + ": " + ROUND(n,p).
}
//prints many bare name-value pairs
function NPrintMany {
	parameter s0, n0.
	local result is s0 + ":" + ROUND(n0,1) + "; ".
	UNTIL false {
		parameter s is "end", n is "end".
		if n = "end" BREAK.
		set result to result + s + ":" + ROUND(n,1) + "; ".
	}.
	PRINT result.
}
//prints lexicon of name-value pairs
function NPrintL {
	parameter l.
	parameter p is 1.
	local result is "".
	FOR s IN l:KEYS {
		set result to result + s + ":" + ROUND(l[s],p) + "; ".
	}.
	PRINT result.
}
//prints list
function NPrintE {
	parameter enum.
	parameter p is 2.
	local itr is enum:ITERATOR.
	UNTIL not itr:NEXT(){
		if itr:VALUE:isType("Scalar")
			PRINT "["+itr:INDEX+"]"+ROUND(itr:VALUE,p).
		else
			PRINT "["+itr:INDEX+"]"+itr:VALUE.
	}
}
function WaitKey{
	wait until terminal:input:haschar().
	terminal:input:clear().
}