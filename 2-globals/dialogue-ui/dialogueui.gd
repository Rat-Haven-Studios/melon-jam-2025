extends Node

@onready var btnContainer: VBoxContainer = $UI/VBoxContainer/HBoxContainer/VBoxContainer/MarginContainer/Panel/HBoxContainer/VBoxContainer
@onready var nameTextBox: Label = $UI/VBoxContainer/HBoxContainer/VBoxContainer/MarginContainer2/Panel/MarginContainer/Label
@onready var responseTextBox: Label = $UI/VBoxContainer/MarginContainer/Panel/MarginContainer/Label
@onready var ui: CanvasLayer = $UI

signal text_displayed
signal choice_selected(choice: Dictionary)

func _ready():
	ui.visible = false

func show():
	if not ui.visible:
		ui.visible = true

func display_text(text: String, npc: NPC):
	show()
	print("[NPC]: ", text)
	responseTextBox.text = text
	await get_tree().create_timer(5.0).timeout
	text_displayed.emit()

func present_choices(choices: Array, npc: NPC) -> Dictionary:
	# Clear any existing buttons first
	for child in btnContainer.get_children():
		child.queue_free()
	
	var selected_choice = null
	
	print("Choices:")
	for i in range(choices.size()):
		print("  %d. %s" % [i + 1, choices[i].text])
		
		# Create new button
		var btn: Button = Button.new()
		btn.text = choices[i].text
		
		# Connect button to signal
		btn.pressed.connect(func(): 
			selected_choice = choices[i]
		)
		
		# Add button to container
		btnContainer.add_child(btn)
	
	# Wait for player to select a choice
	while selected_choice == null:
		await get_tree().process_frame
	
	return selected_choice
