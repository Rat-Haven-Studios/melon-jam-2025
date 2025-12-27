@abstract
class_name NPC extends CharacterBody2D

var npcname: String
var characterID: Data.Characters
var talked: Dictionary # which mask they've talked to
var susLevel: int

var moveDirection: Vector2
var wanderTime: float

@export var mapSprite: Texture2D
@export var dialogueSprite: Texture2D

var dialogueTree

func _init(characterID: Data.Characters, npcname: String, susLevel: int):
	talked = {
		Data.PlayerMasks.BLANK: false,
		Data.PlayerMasks.MAYORAL: false,
		Data.PlayerMasks.POOR: false
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
	var n: int = len(Data.PlayerMasks)
	for i in range(n):
		var path = "res://0-assets/dialogue/{0}/{1}.txt".format([characterID, i])
		CLogger.debug(path)
		
func parseDialogueFile():
	pass
