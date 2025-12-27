class_name Character extends CharacterBody2D

var actionFlags: Dictionary

var currState = STATE.WALKING
@onready var seekingStairs: Area2D = $StairsDetector
@export var BASE_SPEED: int
@export var WALKING_STAIRS_SPEED: int
var currSpeed: int
@onready var interactionComponent = $InteractComponent

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
	if currState == STATE.WALKING:
		processMovement()
		move_and_slide()
	

	
func processMovement():
	var movement_vector: Vector2 = get_movement_vector()
	var direction: Vector2 = movement_vector.normalized()
	self.velocity = direction * self.currSpeed

func get_movement_vector() -> Vector2:
	var x_movement = Input.get_action_strength("right") - Input.get_action_strength("left")
	var y_movement = Input.get_action_strength("down") - Input.get_action_strength("up")
	return Vector2(x_movement, y_movement)
