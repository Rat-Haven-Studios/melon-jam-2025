extends Node2D

const killerID = Data.Characters.THE_HARE

func _ready() -> void:
	var whoDied = Data.killed
	if whoDied == null:
		CLogger.error("Who Died was NULL")
		return
	
	if whoDied != killerID:
		CLogger.info("Player selected the wrong person")
	else:
		CLogger.info("Player won!")
