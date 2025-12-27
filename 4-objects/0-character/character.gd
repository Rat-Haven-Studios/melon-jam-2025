extends CharacterBody2D


var currState = STATE.MOVING
@export var BASE_SPEED: int = 5

enum STATE {
	MOVING,
	TALKING
}


func _ready() -> void:
	pass
	# initialize talked to array


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if currState == STATE.MOVING:
		processMovement()
	move_and_slide()
	if Input.is_action_just_pressed("interact"):
		CLogger.action("Player attempting interact")
	
func processMovement():
	var movement_vector: Vector2 = get_movement_vector()
	var direction: Vector2 = movement_vector.normalized()
	self.velocity = direction * self.BASE_SPEED

func get_movement_vector() -> Vector2:
	var x_movement = Input.get_action_strength("right") - Input.get_action_strength("left")
	var y_movement = Input.get_action_strength("down") - Input.get_action_strength("up")
	return Vector2(x_movement, y_movement)
