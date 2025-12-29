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
		label.text = "You selected wrong..."
	else:
		CLogger.info("Player won!")
		label.text = "You correctly identified and killed the traitor!"

	menuBtn.pressed.connect(onMenuBtnPressed)
	quitBtn.pressed.connect(onQuitBtnPressed)

func onMenuBtnPressed():
	SceneTransitioner.change_scene(MAIN_MENU)
	
func onQuitBtnPressed():
	get_tree().quit()
