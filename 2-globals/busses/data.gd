extends Node

var prevFlags
var player: Character
var level
var killed # will be null or from characters enum

enum PlayerMasks {
	BLANK,
	MAYORAL,
	POOR
}

enum Characters {
	BANDIT_KING, 
	PRIMEAPE,
	TIKI,
	FOXY,
	FROGGER,
	JACK_RABBIT,
	THE_HARE,
	THE_FLAPPER,
	NONE
}

# Maybe could simply use groups instead?
var CharacterObjects: Dictionary = {
	
}
