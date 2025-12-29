extends Node

signal choice_selected(choice: Dictionary)

@onready var btnContainer: VBoxContainer = $UI/VBoxContainer/HBoxContainer/VBoxContainer/MarginContainer/VBoxContainer
@onready var nameTextBox: Label = $UI/VBoxContainer/HBoxContainer/VBoxContainer/MarginContainer2/Panel/Label
@onready var responseTextBox: Label = $UI/VBoxContainer/MarginContainer/Panel/HBoxContainer/MarginContainer/Label
@onready var arrow: Label = $UI/VBoxContainer/MarginContainer/Panel/HBoxContainer/MarginContainer2/Label
@onready var ui: CanvasLayer = $UI
@onready var displaySpritre: TextureRect = $UI/VBoxContainer/HBoxContainer/VBoxContainer2/MarginContainer2/TextureRect
@onready var killBtn: Button = $UI/VBoxContainer/HBoxContainer/VBoxContainer2/MarginContainer/Button

var selected_choice = null
var char_timer: float = 0.04
var currentNPC

var murdered: bool = false 

func _ready():
	killBtn.button_down.connect(murderBtnPressed)
	killBtn.disabled = false
	nameTextBox.text = ""
	
	murdered = false
	hide()

func _input(event):
	if murdered:
		return
		
	if event is InputEventKey and event.pressed and not event.echo:
		if currentNPC != null and event.keycode == KEY_M:
			killBtn.button_down.emit()
			return
		
		var keyCode = event.keycode
		if keyCode >= KEY_1 and keyCode <= KEY_9:
			var choiceIndex = keyCode - KEY_1
			if choiceIndex < btnContainer.get_child_count():
				var btn: Button = btnContainer.get_child(choiceIndex)
				btn.pressed.emit()

func murderBtnPressed():
	if currentNPC != null:
		Data.killed = currentNPC.characterID
	
	murdered = true
	
	killBtn.disabled = true
	
	for btn in btnContainer.get_children():
		btn.queue_free()
	
	displaySpritre.texture = currentNPC.dialogueKilledSprite
	#nameTextBox.text = ""
	responseTextBox.text = "Guah..sd.h"
	arrow.visible = false
	
	AudiManny.playSFX(preload("res://0-assets/sfx/gunshot.mp3"))	
	AudiManny.playSFX(preload("res://0-assets/sfx/dead/Death Sound.mp3"))
	await get_tree().create_timer(2.0).timeout
	
	hide()
	SceneTransitioner.change_scene("res://4-objects/3-ending/EndingScene.tscn")

func show():
	if not ui.visible:
		ui.visible = true
	killBtn.disabled = false

func hide():
	if ui.visible:
		ui.visible = false
		
	for btn in btnContainer.get_children():
		btn.queue_free()
	
	currentNPC = null
	murdered = false

func displayText(text: String, npc: NPC):
	show()
	CLogger.log("npc", text)
	
	currentNPC = npc
	displaySpritre.texture = npc.dialogueSprite
	nameTextBox.text = npc.npcname
	responseTextBox.text = ""
	
	var cntr = 0
	for aChar in text:
		arrow.text = "(X)"
		if not ui.visible or murdered:
			return
		
		if Input.is_action_pressed("alternate") and not murdered:
			responseTextBox.text += text.substr(cntr)
			CLogger.debug("Skipping current dialogue...")
			break
		else:
			await get_tree().create_timer(char_timer).timeout
			if murdered:
				return
			if cntr % 2 == 0:
				AudiManny.playSFX(preload("res://0-assets/sfx/button/hovered.ogg"))
			if npc.dialogueSpriteTalk and cntr % 6 <= 3 and not murdered:
				displaySpritre.texture = npc.dialogueSpriteTalk
			else:
				displaySpritre.texture = npc.dialogueSprite
			cntr += 1
			responseTextBox.text += aChar

	if murdered:
		return
		
	displaySpritre.texture = npc.dialogueSprite
	arrow.text = "(Z)"

	while not Input.is_action_just_pressed("interact") and not murdered:
	#arrow.visible = true
		await get_tree().process_frame
	
	currentNPC = null

func presentChoices(choices: Array, npc: NPC) -> Dictionary:
	for child in btnContainer.get_children():
		child.queue_free()
	
	currentNPC = npc
	selected_choice = null
	arrow.visible = false
	
	CLogger.log("choice", " ".join(choices))
	for i in range(choices.size()):
		var btn: Button = Button.new()
		
		var choiceText: String = choices[i][0].text
		var colored: bool = choices[i][1]
		
		if colored:
			btn.add_theme_color_override("font_color", Color("6FAF8E"))
			btn.add_theme_color_override("font_hover_color", Color("5E9E7D"))
			CLogger.debug("Expected COLORED BUTTON")
		
		btn.text = "  (%d)\t %s" % [i + 1, choiceText]
		btn.alignment = HORIZONTAL_ALIGNMENT_LEFT
		btn.autowrap_mode = TextServer.AUTOWRAP_WORD
		btn.pressed.connect(_onChoiceButtonPressed.bind(choices[i][0]))
		btnContainer.add_child(btn)
	
	while selected_choice == null and not murdered:
		await get_tree().process_frame
	
	if murdered:
		return {}
	
	arrow.visible = true
	currentNPC = null
	return selected_choice

func _onChoiceButtonPressed(choice: Dictionary):
	if murdered:
		return
		
	CLogger.action("Player selected: %s" % choice.text)
	selected_choice = choice
	
	for child in btnContainer.get_children():
		child.queue_free()
	
	choice_selected.emit(choice)
