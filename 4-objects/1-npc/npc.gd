@abstract
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

func _ready():
	roamBuilding()

func roamBuilding():
	# I would want some sort of check to see if they NPC is going to a spot within the world border AND not intersecting with a wall
	# We can work that out later
	
	var randX = randi_range(0, 512)
	var randY = randi_range(0, 512)
	CLogger.debug("Normalized Version = " + str(Vector2(randX, randY).normalized()))
	CLogger.debug("Regular Version = " + str(Vector2(randX, randY)))
	moveDirection = Vector2(randX, randY)
	
	

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
