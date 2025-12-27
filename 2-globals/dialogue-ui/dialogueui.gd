extends Node

@onready var btnContainer: VBoxContainer = $UI/VBoxContainer/HBoxContainer/VBoxContainer/MarginContainer/VBoxContainer
@onready var nameTextBox: Label = $UI/VBoxContainer/HBoxContainer/VBoxContainer/MarginContainer2/Panel/MarginContainer/Label
@onready var responseTextBox: Label = $UI/VBoxContainer/MarginContainer/Panel/MarginContainer/Label
@onready var ui: CanvasLayer = $UI

signal text_displayed
signal choice_selected(choice: Dictionary)

var selected_choice = null  # Store the selected choice

var char_timer: float = 0.04

func _ready():
	ui.visible = false

func show():
	if not ui.visible:
		#Data.level.visible = false
		ui.visible = true

func hide():
	if ui.visible:
		ui.visible = false
		#Data.level.visible = true

func finish_text():
	pass

func display_text(text: String, npc: NPC):
	show()
	CLogger.log("npc", text)
	
	nameTextBox.text = npc.npcname
	responseTextBox.text = ""
	
	# play SFX every other
	var cntr = 0
	for char in text:
		await get_tree().create_timer(char_timer).timeout
		if cntr % 2 == 0:
			AudiManny.playSFX(preload("res://0-assets/sfx/button/hovered.ogg"))
		cntr += 1
		responseTextBox.text += char

	await get_tree().create_timer(2.0).timeout  # Adjust timing as needed
	text_displayed.emit()

func present_choices(choices: Array, npc: NPC) -> Dictionary:
	# Clear any existing buttons first
	for child in btnContainer.get_children():
		child.queue_free()
	
	selected_choice = null  # Reset selection
	
	print("Choices:")
	for i in range(choices.size()):
		print("  %d. %s" % [i + 1, choices[i].text])
		
		# Create new button
		var btn: Button = Button.new()
		btn.text = choices[i].text
		
		# Connect button to callback function
		btn.pressed.connect(_on_choice_button_pressed.bind(choices[i]))
		
		# Add button to container
		btnContainer.add_child(btn)
	
	# Wait for player to select a choice
	while selected_choice == null:
		await get_tree().process_frame
	
	return selected_choice

# Callback function when a choice button is pressed
func _on_choice_button_pressed(choice: Dictionary):
	print("Player selected: ", choice.text)
	
	# Store the selected choice
	selected_choice = choice
	
	# Clear buttons after selection
	for child in btnContainer.get_children():
		child.queue_free()
	
	# Emit signal so other systems can react
	choice_selected.emit(choice)
