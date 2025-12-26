extends CanvasLayer

signal sceneChanged

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	CLogger.info("Initialized Scene Transitioner")

func change_scene(target: String) -> void:
	CLogger.info("Started changing scene...")
	
	$AnimationPlayer.play("dissolve")
	await $AnimationPlayer.animation_finished
	
	if not ResourceLoader.exists(target):
		CLogger.error("Scene file does not exist: %s" % target)
	
	var err := OK
	err = get_tree().change_scene_to_file(target)
	if err != OK:
		CLogger.error("Failed to change scene to: %s (Error code: %d)" % [target, err])
	
	$AnimationPlayer.play_backwards("dissolve")
	
	sceneChanged.emit()
	CLogger.info("Changed scene to: %s" % target)
