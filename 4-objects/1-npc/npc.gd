class_name NPC extends CharacterBody2D

var talked: Dictionary = {
		Data.PlayerMasks.BLANK: false,
		Data.PlayerMasks.MAYORAL: false,
		Data.PlayerMasks.POOR: false
	}
var dialogueTrees: Dictionary = {}

enum STATE {
	WALKING,
	TALKING
}
var currState: STATE = STATE.WALKING
var moveDirection: Vector2
var prevPosition: Vector2
var wanderTime: float
var waitTime: float

const MAX_MAP_BORDER: Vector2 = Vector2(256, 256)
const MIN_MAP_BORDER: Vector2 = Vector2(0, 0)
@export var waitTimeMin: float = 2
@export var waitTimeMax: float = 10
@export var wanderTimeMin: float = 1
@export var wanderTimeMax: float = 7
@export var speed: int = 25
@export var characterID: Data.Characters
@export var npcname: String
@export var susLevel: int
@export var mapSprite: Texture2D
@export var dialogueSprite: Texture2D

@onready var interactable:= $InteractReceiverComponent
@onready var sprite: Sprite2D = $Sprite2D

func _ready() -> void:
	wanderTime = 0
	waitTime = randf_range(waitTimeMin, waitTimeMax)
	Data.CharacterObjects[characterID] = self
	
	if not mapSprite:
		CLogger.error("No map sprite on %s" % mapSprite)
	
	if not dialogueSprite:
		CLogger.error("No dialogue sprite on %s" % mapSprite)
		
	sprite.texture = mapSprite
	
	generateDialogueTrees()
	interactable.interact = _onInteract
	CLogger.info("Initialized %s" % npcname)
	roamBuilding()

func _process(delta):
	# They're talking
	if currState == STATE.TALKING:
		pass
	# They're walking
	elif wanderTime > 0:
		wanderTime -= delta
		self.velocity = moveDirection * (self.speed / 3)
		move_and_slide()
		if isExceedingMapBorder():
			wanderTime = 0
		if isProbablyHittingWall():
			CLogger.debug("I hit the wall" + str(self.velocity))
			wanderTime = 0
		prevPosition = self.global_position
	# They're stopping
	elif waitTime > 0 :
		waitTime -= delta
	# Mix it up now
	else:
		randomizeWander()
		chillOutTime()

func isExceedingMapBorder():
	var currX = self.global_position.x
	var currY = self.global_position.y
	return (currX > MAX_MAP_BORDER.x or currY > MAX_MAP_BORDER.y) or (currX < MIN_MAP_BORDER.x or currY < MIN_MAP_BORDER.y)

func isProbablyHittingWall():
	return velocity.x == 0 or velocity.y == 0

func chillOutTime():
	waitTime = randf_range(waitTimeMin, waitTimeMax)

func _onInteract():
	interactable.isInteractable = false
	converse(Data.player.currMask)
	interactable.isInteractable = true

func randomizeWander():
	moveDirection = Vector2(randf_range(-1, 1), randf_range(-1, 1)).normalized()
	wanderTime = randf_range(wanderTimeMin, wanderTimeMax)
	if moveDirection.x < 0:
		sprite.flip_h = true
	elif moveDirection.x > 0:
		sprite.flip_h = false
	else:
		pass
		

func roamBuilding():
	# I would want some sort of check to see if they NPC is going to a spot within the world border AND not intersecting with a wall
	# We can work that out later
	
	var randX = randi_range(0, 512)
	var randY = randi_range(0, 512)
	moveDirection = Vector2(randX, randY)

func converse(maskID: int):
	currState = STATE.TALKING
	CLogger.action("Starting conversation with %s (mask: %d)" % [npcname, maskID])
		
	var dialogueTree = dialogueTrees.get(maskID, {})
	if dialogueTree.is_empty():
		CLogger.error("No dialogue tree found for mask %d" % maskID)
		Data.player.currState = Data.player.STATE.WALKING
		currState = STATE.WALKING
		return
	
	var currentNodeID: String = "start"
	var conversationState: Dictionary = {}
	
	for flag in Data.player.actionFlags.keys():
		conversationState[flag] = Data.player.actionFlags[flag]
	
	if talked[maskID]:
		await DialogueUI.displayText(dialogueTree.talked_already, self)
		self.susLevel += 1
		currentNodeID = "talked_previously"
	elif dialogueTree.has("initial_greeting"):
		await DialogueUI.displayText(dialogueTree.initial_greeting, self)

	talked[maskID] = true
	
	while DialogueUI.ui.visible and currentNodeID != "":
		var node = dialogueTree.get("nodes", {}).get(currentNodeID, {})
		
		if node.is_empty():
			break
		
		if node.has("condition") and not evaluateCondition(node.condition, conversationState):
			currentNodeID = node.get("else", "")
			continue
		
		await DialogueUI.displayText(node.text, self)
		
		if not node.has("choices") or node.choices.is_empty():
			break
		
		var availableChoices = []
		for choice in node.choices:
			if not choice.has("condition") or evaluateCondition(choice.condition, conversationState):
				if choice.has("colored"):
					availableChoices.append([choice, true])
				else:
					availableChoices.append([choice, false])
		
		if availableChoices.is_empty():
			break
		
		var selectedChoice = await DialogueUI.presentChoices(availableChoices, self)
		
		if selectedChoice.has("sus_change"):
			susLevel += selectedChoice.sus_change
		
		if selectedChoice.has("set_flag"):
			conversationState[selectedChoice.set_flag] = true
			Data.player.actionFlags[selectedChoice.set_flag] = true
			CLogger.debug("Setting flag: %s" % selectedChoice.set_flag)
		
		currentNodeID = selectedChoice.get("next", "")
	
	# at this point, the conversation is over
	DialogueUI.hide()
	CLogger.action("Conversation ended with %s" % npcname)
	self.currState = STATE.WALKING
	Data.player.currState = Data.player.STATE.WALKING

func evaluateCondition(condition, conversationState: Dictionary) -> bool:
	if condition is String:
		if conversationState.has(condition):
			return conversationState[condition]
		if Data.player.actionFlags.has(condition):
			return Data.player.actionFlags[condition]
		return false
	
	if condition is Dictionary:
		var flag = condition.get("flag", "")
		var expectedState = condition.get("state", "true")
		
		var flagValue = false
		if conversationState.has(flag):
			flagValue = conversationState[flag]
		elif Data.player.actionFlags.has(flag):
			flagValue = Data.player.actionFlags[flag]
		
		if expectedState == "true":
			return flagValue == true
		elif expectedState == "false":
			return flagValue == false
		else:
			CLogger.error("Invalid condition state: %s" % expectedState)
			return false
	
	CLogger.error("Invalid condition format")
	return false

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
