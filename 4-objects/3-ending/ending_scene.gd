extends Node2D

const killerID = Data.Characters.THE_HARE

@onready var menuBtn: Button = $CanvasLayer/MarginContainer/VBoxContainer/MarginContainer/HBoxContainer/Playagain
@onready var quitBtn: Button = $CanvasLayer/MarginContainer/VBoxContainer/MarginContainer/HBoxContainer/quit
@onready var label: Label = $CanvasLayer/MarginContainer/VBoxContainer/Label2

const MAIN_MENU: String = "res://1-main/Main.tscn"
const FIRST_LEVEL: String = "res://4-objects/2-level/FIRST_LEVEL.tscn"


func _ready() -> void:
	get_tree().paused = false
	var whoDied = Data.killed
	if whoDied == null:
		CLogger.error("Who Died was NULL")
		return
	
	if whoDied != killerID:
		CLogger.info("Player selected the wrong person")
		label.text = "You selected wrong...\n"
	else:
		CLogger.info("Player won!")
		label.text = "You correctly identified and killed the traitor!\n"
	
	if whoDied == Data.Characters.TIKI and Data.prevFlags.has("one_shot_ending"):
		label.text += "More than one shot..."
	elif whoDied == Data.Characters.TIKI and Data.prevFlags.has("tiki_betrayal") and not (Data.prevFlags.has("tiki_learns_betrayal")):
		label.text += "Vagrant down..."
	elif (whoDied == Data.Characters.THE_FLAPPER) and Data.prevFlags.has("she_yappin"):
		label.text += "No more yapping."
	elif (whoDied == Data.Characters.JACK_RABBIT) and Data.prevFlags.has("gay_bro_active"):
		label.text += "We're down one less bigot."
	elif whoDied == Data.Characters.BANDIT_KING and Data.prevFlags.has("maybe_mayor"):
		label.text += "You killed the Mayor..."
	elif (whoDied == Data.Characters.PRIMEAPE) and Data.prevFlags.has("agree_with_common_man_act"):
		label.text += "Four fingered bastard."
	
	CLogger.debug(str(Data.prevFlags))
	
	menuBtn.pressed.connect(onMenuBtnPressed)
	quitBtn.pressed.connect(onQuitBtnPressed)

func onMenuBtnPressed():
	SceneTransitioner.change_scene(MAIN_MENU)
	
func onQuitBtnPressed():
	get_tree().quit()
