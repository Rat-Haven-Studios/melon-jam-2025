extends CharacterBody2D

func _process(_delta):
	self.velocity = Vector2(0, 1).normalized() * 25
	move_and_slide()
