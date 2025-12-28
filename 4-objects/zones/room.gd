extends Area2D

var guestInRoom: Array[NPC] = []
var playerIsInRoom: bool = false

func _ready():
	body_entered.connect(onAreaEntered)
	body_exited.connect(onAreaExited)

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("swap") and playerIsInRoom:
		alertGuestOfMaskSwap()
		
		
func alertGuestOfMaskSwap():
	var comboNames = "Guests who saw the swap: "
	for guest in guestInRoom:
		guest.hasSeenPlayerSwapMask = true
		comboNames += guest.name + " & "
	CLogger.info(comboNames.left(comboNames.length() - 2))
func onAreaEntered(body: CharacterBody2D):
	if body is NPC:
		guestInRoom.append(body)
		debugPrintGuestInRoom()
	elif body is Character:
		CLogger.info("Player has entered " + str(self.name))
		playerIsInRoom = true
func onAreaExited(body: CharacterBody2D):
	if body is NPC:
		guestInRoom.erase(body)
		debugPrintGuestInRoom()
	elif body is Character:
		CLogger.info("Player has left " + str(self.name))
		playerIsInRoom = false

func debugPrintGuestInRoom():
	CLogger.debug("Guests in " + str(self.name) + " | " + str(guestInRoom))
