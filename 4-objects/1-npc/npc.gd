class_name NPC extends CharacterBody2D

var npcname: String
var characterID: Data.Characters
var susLevel: int

var talked: Dictionary # which mask they've talked to
var dialogueTrees: Dictionary

var moveDirection: Vector2
var wanderTime: float

@export var mapSprite: Texture2D
@export var dialogueSprite: Texture2D
@onready var interactable:= $InteractReceiverComponent
func _init(characterID: Data.Characters, npcname: String, susLevel: int):
	talked = {
		Data.PlayerMasks.BLANK: false,
		Data.PlayerMasks.MAYORAL: false,
		Data.PlayerMasks.POOR: false
	}
	
	dialogueTrees = {
		
	}
	
	self.characterID = characterID
	self.npcname = npcname
	self.susLevel = susLevel
	
	Data.CharacterObjects[characterID] = self
	# add to a characters group instead?
	
	generateDialogueTrees()
	CLogger.info("Initialized %s" % npcname)

func _ready() -> void:
	interactable.interact = _onInteract
	roamBuilding()

func _onInteract():
	interactable.isInteractable = false
	converse(0)
	interactable.isInteractable = true
	
func roamBuilding():
	# I would want some sort of check to see if they NPC is going to a spot within the world border AND not intersecting with a wall
	# We can work that out later
	
	var randX = randi_range(0, 512)
	var randY = randi_range(0, 512)
	CLogger.debug("Normalized Version = " + str(Vector2(randX, randY).normalized()))
	CLogger.debug("Regular Version = " + str(Vector2(randX, randY)))
	moveDirection = Vector2(randX, randY)
	
func getDialogueTree(mask: Data.PlayerMasks) -> Dictionary:
	return dialogueTrees.get(mask, {})

func getDialogueNode(mask: Data.PlayerMasks, node_id: String) -> Dictionary:
	var tree = getDialogueTree(mask)
	return tree.get("nodes", {}).get(node_id, {})

func converse(maskID: int):
	CLogger.action("Starting conversation with %s (mask: %d)" % [npcname, maskID])
	
	var dialogueTree = dialogueTrees.get(maskID, {})
	if dialogueTree.is_empty():
		CLogger.warn("No dialogue tree found for mask %d" % maskID)
		return
	
	talked[maskID] = true
	
	if dialogueTree.has("initial_greeting"):
		await DialogueUI.display_text(dialogueTree.initial_greeting, self)
	
	var current_node_id = "start"
	var conversation_state = {}  # Track flags/variables during conversation
	
	while current_node_id != "":
		var node = dialogueTree.get("nodes", {}).get(current_node_id, {})
		
		if node.is_empty():
			break
		
		# Check conditions (optional)
		if node.has("condition") and not evaluate_condition(node.condition, conversation_state):
			current_node_id = node.get("else", "")
			continue
		
		await DialogueUI.display_text(node.text, self)
		
		if node.choices.is_empty():
			break
		
		# Filter choices by conditions
		var available_choices = []
		for choice in node.choices:
			if not choice.has("condition") or evaluate_condition(choice.condition, conversation_state):
				available_choices.append(choice)
		
		if available_choices.is_empty():
			break
		
		var selected_choice = await DialogueUI.present_choices(available_choices, self)
		
		if selected_choice.has("sus_change"):
			susLevel += selected_choice.sus_change
		
		# Set flags
		if selected_choice.has("set_flag"):
			conversation_state[selected_choice.set_flag] = true
		
		current_node_id = selected_choice.get("next", "")

func evaluate_condition(condition: String, state: Dictionary) -> bool:
	# Simple condition evaluation
	# e.g., "has_key" checks if state.has("has_key")
	return state.get(condition, false)

func generateDialogueTrees():
	dialogueTrees = {}
	for mask in Data.PlayerMasks.values():
		var path = "res://0-assets/dialogue/%s/%d.json" % [Data.Characters.keys()[characterID], mask]
		
		if not ResourceLoader.exists(path):
			CLogger.error("File %s does not exist" % path)
			continue
			
		var tree = parseDialogueFile(path)
		if tree:
			dialogueTrees[mask] = tree
			CLogger.info("Loaded dialogue for %s, mask %d" % [npcname, mask])
		else:
			CLogger.error("Failed to load dialogue tree for %s, mask %d" % [npcname, mask])
		
		parseDialogueFile(path)
		#CLogger.debug(path)
		
func parseDialogueFile(path: String):
	var file = FileAccess.open(path, FileAccess.READ)
	if not file:
		CLogger.error("Failed to open dialogue file: %s" % path)
		return {}
	
	var json_string = file.get_as_text()
	file.close()
	
	var json = JSON.new()
	var error = json.parse(json_string)
	
	if error != OK:
		CLogger.error("Failed to parse JSON in %s: %s" % [path, json.get_error_message()])
		return {}
	
	return json.data
