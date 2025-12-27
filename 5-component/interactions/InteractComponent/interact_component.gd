extends Node2D

var  interactables: Array[Area2D] = []
var canInteract: bool = true
var currentlyInteracting: bool = false
@onready var area:Area2D = $Area2D
@onready var label:Label = $Label

func _ready():
	area.area_entered.connect(onAreaEntered)
	area.area_exited.connect(onAreaExited)

func _process(_delta):
	if interactables and canInteract:
		interactables.sort_custom(_sortByNearest)
		if interactables[0].isInteractable:
			label.text = interactables[0].interactString
			label.show()
	else:
		label.hide()
	
func _input(event: InputEvent) -> void:
	if event.is_action_pressed("interact") and canInteract and interactables:
		canInteract = false
		
		await interactables[0].interact.call()
		label.hide()
		
		
		canInteract = true
func _sortByNearest(area1: Area2D, area2:Area2D):
	var area1_dist = global_position.distance_to(area1.global_position)
	var area2_dist = global_position.distance_to(area2.global_position)
	return area1_dist < area2_dist
	
func onAreaEntered(area: Area2D):
	interactables.push_back(area)

func onAreaExited(area: Area2D):
	interactables.erase(area)
