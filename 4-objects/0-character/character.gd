class_name Character extends CharacterBody2D


@onready var seekingStairs: Area2D = $StairsDetector
@onready var interactionComponent = $InteractComponent
@export var WALKING_STAIRS_SPEED: int
@export var BASE_SPEED: int
var actionFlags: Dictionary
var currState = STATE.WALKING
var currSpeed: int
var currMask: Data.PlayerMasks = Data.PlayerMasks.BLANK

enum STATE {
	WALKING,
	TALKING
}

func _ready() -> void:
	Data.player = self
	currSpeed = BASE_SPEED
	seekingStairs.area_entered.connect(onStairsEntered)
	seekingStairs.area_exited.connect(onStairsExited)
	pass


# initialize talked to array
func onStairsEntered(area):
	currSpeed = WALKING_STAIRS_SPEED
func onStairsExited(area):
	currSpeed = BASE_SPEED

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if currState == STATE.TALKING:
		return
	
	processMovement()
	move_and_slide()
	if Input.is_action_just_pressed("swap"):
		swapMask()
	

func swapMask():
	CLogger.debug("I'm swappin my mfing mask")
	match self.currMask:
		Data.PlayerMasks.BLANK:
			# Do the animation
			currMask = Data.PlayerMasks.MAYORAL
		Data.PlayerMasks.MAYORAL:
			# Do the animation
			currMask = Data.PlayerMasks.POOR
		Data.PlayerMasks.POOR:
			# Do the animation
			currMask = Data.PlayerMasks.BLANK
	
func processMovement():
	var movement_vector: Vector2 = get_movement_vector()
	var direction: Vector2 = movement_vector.normalized()
	self.velocity = direction * self.currSpeed

func get_movement_vector() -> Vector2:
	var x_movement = Input.get_action_strength("right") - Input.get_action_strength("left")
	var y_movement = Input.get_action_strength("down") - Input.get_action_strength("up")
	return Vector2(x_movement, y_movement)
