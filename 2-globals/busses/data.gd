extends Node

var player: Character
var level

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
	THE_FLAPPER
}

# Maybe could simply use groups instead?
var CharacterObjects: Dictionary = {
	
}
