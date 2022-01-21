function Notify {
	parameter text, clr, dTime is 5, textSize is 40.
	HUDTEXT(text, dTime, 2, textSize, clr, true).
}
function NPrint {
	parameter s,n.
	parameter p is 3.
	PRINT s + ": " + ROUND(n,p).
}
function NPrintL {
	parameter l.
	parameter p is 1.
	local result is "".
	FOR s IN l:KEYS {
		set result to result + s + ":" + ROUND(l[s],p) + "; ".
	}.
	PRINT result.
}
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