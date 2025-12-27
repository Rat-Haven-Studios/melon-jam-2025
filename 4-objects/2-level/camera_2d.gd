extends Camera2D


var player = null

func _ready():
	findPlayer()

func _process(float):
	if player == null:
		CLogger.debug("Haven't found the player man")
		findPlayer()
	else:
		self. position = lerp(self.position, player.position, .1)

func findPlayer():
	CLogger.info("Camera finding player")

	player = get_tree().get_first_node_in_group("Player")
	
