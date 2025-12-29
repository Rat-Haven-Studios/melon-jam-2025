extends Node2D

@onready var menuBtn: Button = $CanvasLayer/MarginContainer/VBoxContainer/MarginContainer/HBoxContainer/home

const MAIN_MENU: String = "res://1-main/Main.tscn"

func _ready() -> void:
	menuBtn.pressed.connect(onMenuBtnPressed)

func onMenuBtnPressed():
	SceneTransitioner.change_scene(MAIN_MENU)
