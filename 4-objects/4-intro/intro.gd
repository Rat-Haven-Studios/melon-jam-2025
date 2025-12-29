extends Node2D

@onready var menuBtn: Button = $CanvasLayer/MarginContainer/VBoxContainer/MarginContainer/HBoxContainer/Button
@onready var startBtn: Button = $CanvasLayer/MarginContainer/VBoxContainer/MarginContainer/HBoxContainer/Button2

const MAIN_MENU: String = "res://1-main/Main.tscn"
const FIRST_LEVEL: String = "res://4-objects/2-level/FIRST_LEVEL.tscn"

func _ready() -> void:
	menuBtn.pressed.connect(onMenuBtnPressed)
	startBtn.pressed.connect(onStartBtnPressed)

func onMenuBtnPressed():
	SceneTransitioner.change_scene(MAIN_MENU)
	
func onStartBtnPressed():
	SceneTransitioner.change_scene(FIRST_LEVEL)
