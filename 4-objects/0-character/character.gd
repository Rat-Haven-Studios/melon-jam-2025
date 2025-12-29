class_name Character extends CharacterBody2D


@onready var seekingStairs: Area2D = $StairsDetector
@onready var interactionComponent = $InteractComponent
@export var WALKING_STAIRS_SPEED: int
@export var BASE_SPEED: int

@onready var neutralMask: Sprite2D = $SpriteContainer/NeutralMaskSprite
@onready var mayorMask: Sprite2D = $SpriteContainer/MayorMaskSprite
@onready var poorMask: Sprite2D = $SpriteContainer/PoorMaskSprite
@onready var spriteContainer: Node2D = $SpriteContainer

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
func onStairsEntered(_area):
	currSpeed = WALKING_STAIRS_SPEED
func onStairsExited(_area):
	currSpeed = BASE_SPEED

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if currState == STATE.TALKING:
		return
	
	processMovement()
	move_and_slide()

	
func processMovement():
	var movement_vector: Vector2 = get_movement_vector()
	var direction: Vector2 = movement_vector.normalized()
	self.velocity = direction * self.currSpeed

func get_movement_vector() -> Vector2:
	var x_movement = Input.get_action_strength("right") - Input.get_action_strength("left")
	var y_movement = Input.get_action_strength("down") - Input.get_action_strength("up")
	if x_movement < 0:
		spriteContainer.scale = Vector2(-1.0, 1.0)
	elif x_movement > 0:
		spriteContainer.scale = Vector2(1.0, 1.0)
	else:
		pass
	return Vector2(x_movement, y_movement)
