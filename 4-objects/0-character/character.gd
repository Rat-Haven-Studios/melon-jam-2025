class_name Character extends CharacterBody2D

var actionFlags: Dictionary

var currState = STATE.WALKING
@export var BASE_SPEED: int = 5
@onready var interactionComponent = $InteractComponent

enum STATE {
	WALKING,
	TALKING
}

func _ready() -> void:
	Data.player = self
	pass
	# initialize talked to array

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if currState == STATE.WALKING:
		processMovement()
		move_and_slide()
	

	
func processMovement():
	var movement_vector: Vector2 = get_movement_vector()
	var direction: Vector2 = movement_vector.normalized()
	self.velocity = direction * self.BASE_SPEED

func get_movement_vector() -> Vector2:
	var x_movement = Input.get_action_strength("right") - Input.get_action_strength("left")
	var y_movement = Input.get_action_strength("down") - Input.get_action_strength("up")
	return Vector2(x_movement, y_movement)
