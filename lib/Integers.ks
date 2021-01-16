@LAZYGLOBAL off.

local num_lex   is lexicon().

num_lex:add("0", 0).
num_lex:add("1", 1).
num_lex:add("2", 2).
num_lex:add("3", 3).
num_lex:add("4", 4).
num_lex:add("5", 5).
num_lex:add("6", 6).
num_lex:add("7", 7).
num_lex:add("8", 8).
num_lex:add("9", 9).

function ReadInt {
	parameter s.
	local v is 0.
	for i IN s:split(""):sublist(1,s:length) {
		set v TO v * 10.
		if num_lex:haskey(i) { set v to v + num_lex[i]. }
	}
	return v.
}