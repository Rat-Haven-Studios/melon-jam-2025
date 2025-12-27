extends Control

@onready var playButton: Button = $PanelContainer/VBoxContainer/ButtonMarginContainer/VBoxContainer/MarginContainer/PlayButton
@onready var howToPlayButton: Button = $PanelContainer/VBoxContainer/ButtonMarginContainer/VBoxContainer/ButtonVBox/HowToPlayButton
@onready var settingsButton: Button = $PanelContainer/VBoxContainer/ButtonMarginContainer/VBoxContainer/ButtonVBox/SettingsButton
@onready var quitButton: Button = $PanelContainer/VBoxContainer/ButtonMarginContainer/VBoxContainer/ButtonVBox/QuitButton
@onready var creditsButton: Button = $PanelContainer/VBoxContainer/ButtonMarginContainer/VBoxContainer/ButtonVBox/CreditsButton

const FIRST_LEVEL: String = "res://4-objects/2-level/FIRST_LEVEL.tscn"
const HOW_TO_PLAY: String = ""
const CREDITS: String = ""

func _ready() -> void:
	playButton.pressed.connect(onPlayButtonPressed)
	settingsButton.pressed.connect(onSettingsButtonButtonPressed)
	quitButton.pressed.connect(onQuitButtonPressed)
	howToPlayButton.pressed.connect(onHowToPlayButtonPressed)
	creditsButton.pressed.connect(onCreditsButtonPressed)
	CLogger.info("Main Scene Initialized")

func onPlayButtonPressed() -> void:
	SceneTransitioner.change_scene(FIRST_LEVEL)
	CLogger.action("Play button pressed. Starting the game")

func onHowToPlayButtonPressed() -> void:
	SceneTransitioner.change_scene(HOW_TO_PLAY)
	CLogger.action("How to play pressed...")

func onSettingsButtonButtonPressed() -> void:
	SettingsMenu.get_child(0).toggleMenu()

func onCreditsButtonPressed() -> void:
	SceneTransitioner.change_scene(CREDITS)
	CLogger.action("Credits button pressed...")

func onQuitButtonPressed() -> void:
	get_tree().quit()
