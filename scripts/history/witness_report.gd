class_name WitnessReport extends RefCounted

var TICK:int
var EVENT_WITNESSED: EVENT
var WITNESS:NPC
var REACTION:int # 1, 0, -1
var EXPIRES_ON:int


func _init(witness:NPC, event:EVENT, reaction:int = 0) -> void:
	TICK = Global.TICKS
	WITNESS = witness
	EVENT_WITNESSED = event
	REACTION = reaction

func includes_npc(target:NPC) -> bool:
	return EVENT_WITNESSED.includes_npc(target)
