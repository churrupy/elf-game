class_name RelationshipMemory extends RefCounted

var TICK:int
var OWNER:NPC
var TARGET:NPC
var MEMORY_ID: String
var EXPIRES_ON: int
var SCORE:int
var DISPLAY: String


func _init(owner:NPC, target:NPC, memory_id:String) -> void:
	#TICK = Global.TICKS
	OWNER = owner
	TARGET = target
	MEMORY_ID = memory_id
	var memory_data: Dictionary = Dialogue.RELATIONSHIP_DETAILS[MEMORY_ID]
	SCORE = memory_data["score"]
	DISPLAY = memory_data["display"]
	#EXPIRES_ON = TICK + memory_data["duration"]
	update_ticks()

func update_ticks() -> void:
	# resets expiration
	TICK = Global.TICKS
	var memory_data: Dictionary = Dialogue.RELATIONSHIP_DETAILS[MEMORY_ID]
	EXPIRES_ON = TICK + memory_data["duration"]


func _to_string() -> String:
	var display_list: Array[String] = [
		DISPLAY,
		"[{score}]".format({"score": SCORE})
	]
	var display_string: String = " ".join(display_list)
	return display_string