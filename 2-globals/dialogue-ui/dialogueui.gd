# DialogueUI.gd (autoload)
extends Node

signal text_displayed
signal choice_selected(choice: Dictionary)

func display_text(text: String, npc: NPC):
	# Show dialogue box with text
	# You'll implement your actual UI here
	print("[NPC]: ", text)
	await get_tree().create_timer(1.0).timeout  # Simulate reading time
	text_displayed.emit()

func present_choices(choices: Array, npc: NPC) -> Dictionary:
	# Show choice buttons to player
	print("Choices:")
	for i in range(choices.size()):
		print("  %d. %s" % [i + 1, choices[i].text])
	
	# Wait for player to select (this is simplified)
	# In reality, connect to button signals
	await get_tree().create_timer(0.5).timeout
	var selected_index = 0  # Player's choice
	
	return choices[selected_index]
