extends Node

enum Music {
	MENU,
}

const MUSIC := {
#	Music.MENU: preload("res://0-assets/music/1main-menu.wav"),
	Music.MENU: preload("res://0-assets/music/139 Fireplace.mp3")
}

@onready var musicPlayer: AudioStreamPlayer = $MusicPlayer
@onready var SFXPlayer: AudioStreamPlayer = $SFXPlayer

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	musicPlayer.finished.connect(onFinished) # by default we want looping music
	playMusic(Music.MENU)
	CLogger.info("Initialized AudiManny")

func playMusic(track: Music) -> void:
	# AudiManny.playMusic(AudiManny.Music.MENU)
	if musicPlayer.stream == MUSIC[track]:
		return
	musicPlayer.stream = MUSIC[track];
	musicPlayer.play()
	CLogger.info("Playing music with id: [%s]" % track)

func stopMusic() -> void:
	musicPlayer.stop()
	CLogger.info("Stopped the music")

func playSFX(stream: AudioStream) -> void:
	# AudiManny.playSFX(preload("PATH"))
	
	# We create a new one so SFX have their own unique players and don't
	# conflict with each other / overwrite each other
	var p := AudioStreamPlayer.new()
	p.stream = stream
	add_child(p)
	p.play()
	p.finished.connect(p.queue_free)
	
	# CLogger.info("Playing SFX: %s" % stream.resource_path)

func onFinished() -> void:
	musicPlayer.play()
	CLogger.info("Looping current music stream")
