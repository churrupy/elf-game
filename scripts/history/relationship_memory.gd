class_name RelationshipMemory extends RefCounted

var TICK:int
var OWNER:NPC
var TARGET:NPC
var MEMORY_ID: String
var EXPIRES_ON: int
var SCORE:int


func _init(owner:NPC, target:NPC, memory_id:String, score:int) -> void:
	TICK = Global.TICKS
	OWNER = owner
	TARGET = target
	MEMORY_ID = memory_id
	SCORE = score
	EXPIRES_ON = TICK + 100