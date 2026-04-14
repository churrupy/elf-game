class_name EVENT extends RefCounted

var TICK: int
var EXPIRES_ON: int
var EXPIRED: bool = false
var SEEABLE: bool = false
var HEARABLE: bool = false
var LOCATION: Vector2
var TYPE: String
var TAGS: Array[String] # things npcs can react to

func includes_npc(target:NPC) -> bool:
	return false

func get_impression_of(pov: NPC, target: NPC) -> String:
	return ""

func is_equal() -> bool:
	return false

func _to_string() -> String:
	return ""
