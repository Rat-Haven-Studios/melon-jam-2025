extends Node

#signal text_displayed
signal choice_selected(choice: Dictionary)

@onready var btnContainer: VBoxContainer = $UI/VBoxContainer/HBoxContainer/VBoxContainer/MarginContainer/VBoxContainer
@onready var nameTextBox: Label = $UI/VBoxContainer/HBoxContainer/VBoxContainer/MarginContainer2/Panel/Label
@onready var responseTextBox: Label = $UI/VBoxContainer/MarginContainer/Panel/HBoxContainer/MarginContainer/Label
@onready var arrow: TextureRect = $UI/VBoxContainer/MarginContainer/Panel/HBoxContainer/MarginContainer2/TextureRect
@onready var ui: CanvasLayer = $UI
@onready var displaySpritre: TextureRect = $UI/VBoxContainer/HBoxContainer/VBoxContainer2/MarginContainer2/TextureRect
@onready var killBtn: Button = $UI/VBoxContainer/HBoxContainer/VBoxContainer2/MarginContainer/Button

var selected_choice = null
var char_timer: float = 0.04
var currentNPC

func _ready():
	killBtn.pressed.connect(murderBtnPressed)
	hide()

func _input(event):
	if event is InputEventKey and event.pressed and not event.echo:
		if currentNPC != null and event.keycode == KEY_M:
			killBtn.pressed.emit()
			return
		
		var keyCode = event.keycode
		if keyCode >= KEY_1 and keyCode <= KEY_9:
			var choiceIndex = keyCode - KEY_1 # conver to 0 index
			if choiceIndex < btnContainer.get_child_count():
				var btn: Button = btnContainer.get_child(choiceIndex)
				btn.pressed.emit()

func murderBtnPressed():
	if currentNPC != null:
		Data.killed = currentNPC.characterID
	# Change their sprite
	displaySpritre.texture = currentNPC.dialogueKilledSprite
	# Wait some time
	# Play my sound
	AudiManny.playSFX(preload("res://0-assets/sfx/gunshot.mp3"))
	await get_tree().create_timer(2)
	AudiManny.playSFX(preload("res://0-assets/sfx/dead/Death Sound.mp3"))
	await get_tree().create_timer(4)
	
	hide()
	SceneTransitioner.change_scene("res://4-objects/3-ending/EndingScene.tscn")

func show():
	if not ui.visible:
		ui.visible = true

func hide():
	if ui.visible:
		ui.visible = false
		
	for btn in btnContainer.get_children():
		btn.queue_free()
	
	currentNPC = null

func displayText(text: String, npc: NPC):
	show()
	CLogger.log("npc", text)
	
	currentNPC = npc
	displaySpritre.texture = npc.dialogueSprite
	nameTextBox.text = npc.npcname
	responseTextBox.text = ""
	
	var cntr = 0
	for aChar in text:
		if not ui.visible:
			return
		
		if Input.is_action_pressed("alternate"):
			responseTextBox.text += text.substr(cntr)
			CLogger.debug("Skipping current dialogue...")
			break
		else:
			await get_tree().create_timer(char_timer).timeout
			if cntr % 2 == 0: # play SFX every other
				AudiManny.playSFX(preload("res://0-assets/sfx/button/hovered.ogg"))
			if npc.dialogueSpriteTalk and cntr % 6 <= 3:
				displaySpritre.texture = npc.dialogueSpriteTalk
			else:
				displaySpritre.texture = npc.dialogueSprite
			cntr += 1
			responseTextBox.text += aChar

	displaySpritre.texture = npc.dialogueSprite
	# wait for the user to continue...
	arrow.visible = true
	while not Input.is_action_just_pressed("interact"):
		await get_tree().process_frame
	arrow.visible = false
	currentNPC = null

func presentChoices(choices: Array, npc: NPC) -> Dictionary:
	for child in btnContainer.get_children():
		child.queue_free()
	
	currentNPC = npc
	selected_choice = null  # Reset selection
	
	CLogger.log("choice", " ".join(choices))
	for i in range(choices.size()):
		var btn: Button = Button.new()
		
		var choiceText: String = choices[i][0].text
		var colored: bool = choices[i][1]
		
		if colored:
			btn.add_theme_color_override("font_color", Color("6FAF8E"))
			btn.add_theme_color_override("font_hover_color", Color("5E9E7D"))
			CLogger.debug("Expected COLORED BUTTON")
		
		btn.text = "  %d.\t %s" % [i + 1, choiceText]
		btn.alignment = HORIZONTAL_ALIGNMENT_LEFT
		btn.autowrap_mode = TextServer.AUTOWRAP_WORD
		btn.pressed.connect(_onChoiceButtonPressed.bind(choices[i][0]))
		btnContainer.add_child(btn)
	
	while selected_choice == null:
		await get_tree().process_frame
	
	currentNPC = null
	return selected_choice

func _onChoiceButtonPressed(choice: Dictionary):
	CLogger.action("Player selected: %s" % choice.text)
	selected_choice = choice
	
	for child in btnContainer.get_children():
		child.queue_free()
	
	choice_selected.emit(choice)
