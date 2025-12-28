extends Area2D

var guestInRoom: Array[NPC] = []
var playerIsInRoom: bool = false

func _ready():
	body_entered.connect(onAreaEntered)
	body_exited.connect(onAreaExited)
	CLogger.debug(str(guestInRoom))

func _input(event: InputEvent) -> void:
	if event.is_action("swap") and playerIsInRoom:
		CLogger.debug("Alerting guest of the swap right now")
		alertGuestOfMaskSwap()
		
		
func alertGuestOfMaskSwap():
	for guest in guestInRoom:
		guest.seenPlayerSwapMask = true
	
func onAreaEntered(body: CharacterBody2D):
	if body is NPC:
		CLogger.debug(str(body) + str(body))
		guestInRoom.append(body)
		CLogger.debug(str(guestInRoom))
	elif body is Character:
		CLogger.debug("Player has entered my room :)")
		playerIsInRoom = true
func onAreaExited(body: CharacterBody2D):
	if body is NPC:
		CLogger.debug((str(body)))
		CLogger.debug(str(guestInRoom))
		guestInRoom.erase(body)
	elif body is Character:
		CLogger.debug("Player has left my room :(")
		playerIsInRoom = false
