extends Node

# Simple custom logger. 

# CLogger.log("state", what changed state) 	-> [STATE]  Player changed state
# CLogger.error(why it failed)				-> [ERROR]  X went wrong

var debug_enabled := true
var disabled := false

func _ready():
	info("Initialized CLogger")

func _log(tag: String, msg: String):
	if not disabled:
		print("%-8s | %s" % [tag, msg])

func log(tag: String, msg: String):
	var formatted_tag := "[%s]" % tag.to_upper()
	_log(formatted_tag, msg)

func error(msg: String):
	push_error(msg)
	_log("[ERROR]", msg)

func debug(msg: String):
	if debug_enabled:
		_log("[DEBUG]", msg)

func action(msg: String):
	_log("[ACTION]", msg)

func info(msg: String):
	_log("[INFO]", msg)
