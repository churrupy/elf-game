class_name WitnessReport extends RefCounted

var TICK:int
var EVENT_WITNESSED: EVENT
var WITNESS:NPC
var REACTION:int # 1, 0, -1
var EXPIRES_ON:int
var ROLE: String # whether participant, witness, or heard secondhand
var REACTIONS: Dictionary # saved for impressions
var SCORE: int = 0 # for action history


func _init(witness:NPC, event:EVENT, role:String) -> void:
	TICK = Global.TICKS
	WITNESS = witness
	EVENT_WITNESSED = event
	ROLE = role
	process_reaction()

func includes_npc(target:NPC) -> bool:
	return EVENT_WITNESSED.includes_npc(target)

func process_reaction() -> void:
	if ROLE == "participant": return
	for tag: String in EVENT_WITNESSED.TAGS:
		var opinion: int = WITNESS.get_opinion(tag)
		if opinion != 0:
			REACTIONS[tag] = opinion
			SCORE += opinion
