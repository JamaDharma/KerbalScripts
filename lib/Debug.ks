function NPrint {
	parameter s,n.
	parameter p is 3.
	PRINT s + ": " + ROUND(n,p).
}

function WaitKey{
	wait until terminal:input:haschar().
	terminal:input:clear().
}