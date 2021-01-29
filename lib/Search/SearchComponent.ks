function MakeSearchComponent{
	parameter defStep, minStep, changer.
	return lexicon(
		"DefaultStep", defStep,
		"MinimumStep", minStep,
		"Changer", changer
	).
}