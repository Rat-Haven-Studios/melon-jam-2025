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
	
func converse(maskID: int):
	CLogger.action("Starting conversation with %s (mask: %d)" % [npcname, maskID])
		
	var dialogueTree = dialogueTrees.get(maskID, {})
	if dialogueTree.is_empty():
		CLogger.error("No dialogue tree found for mask %d" % maskID)
		return
	
	var currentNodeID: String = "start"
	var conversationState: Dictionary = {}
	
	if talked[maskID]:
		await DialogueUI.displayText(dialogueTree.talked_already, self)
		self.susLevel += 1
		currentNodeID = ""
	elif dialogueTree.has("initial_greeting"):
		await DialogueUI.displayText(dialogueTree.initial_greeting, self)

	talked[maskID] = true
	
	while currentNodeID != "":
		var node = dialogueTree.get("nodes", {}).get(currentNodeID, {})
		
		if node.is_empty():
			break
		
		# Check conditions
		if node.has("condition") and not evaluateCondition(node.condition, conversationState):
			currentNodeID = node.get("else", "")
			continue
		
		await DialogueUI.displayText(node.text, self)
		
		if node.choices.is_empty():
			break
		
		var availableChoices = []
		for choice in node.choices:
			if not choice.has("condition") or evaluateCondition(choice.condition, conversationState):
				availableChoices.append(choice)
		
		if availableChoices.is_empty():
			break
		
		var selectedChoice = await DialogueUI.presentChoices(availableChoices, self)
		
		if selectedChoice.has("sus_change"):
			susLevel += selectedChoice.sus_change
		
		if selectedChoice.has("set_flag"):
			conversationState[selectedChoice.set_flag] = true
			Data.player.actionFlags[selectedChoice.set_flag] = true
			print(conversationState)
		
		currentNodeID = selectedChoice.get("next", "")
	
	# at this point, the conversation is over
	DialogueUI.hide()
	CLogger.action("Conversation ended with %s" % npcname)
	Data.player.currState = Data.player.STATE.WALKING

func evaluateCondition(condition: String, state: Dictionary) -> bool:
	# "has_key" checks if state.has("has_key")
	return state.get(condition, false)

func getDialogueTree(mask: Data.PlayerMasks) -> Dictionary:
	return dialogueTrees.get(mask, {})

func getDialogueNode(mask: Data.PlayerMasks, node_id: String) -> Dictionary:
	var tree = getDialogueTree(mask)
	return tree.get("nodes", {}).get(node_id, {})

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
