HUDTEXT("Awaiting orders: "+CORE:PART:TAG, 5, 2, 15, red, false).
LOCAL messageBuffer IS CORE:MESSAGES.
messageBuffer:CLEAR().
UNTIL NOT messageBuffer:EMPTY { WAIT 1.}
RUNPATH(messageBuffer:POP():CONTENT).