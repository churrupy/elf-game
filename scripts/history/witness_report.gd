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
	#TICK = Global.TICKS
	WITNESS = witness
	EVENT_WITNESSED = event
	ROLE = role
	process_reaction()

func update_ticks() -> void:
	TICK = Global.TICKS

func includes_npc(target:NPC) -> bool:
	return EVENT_WITNESSED.includes_npc(target)

func process_reaction() -> void:
	if ROLE == "participant": return
	for tag: String in EVENT_WITNESSED.TAGS:
		var opinion: int = WITNESS.get_opinion(tag)
		if opinion != 0:
			REACTIONS[tag] = opinion
			SCORE += opinion

func get_display_string() -> String:
	var event_string = str(EVENT_WITNESSED)
	var color: String = "white"
	if SCORE > 0:
		color = "green"
	elif SCORE < 0:
		color = "red"

	var _str = "[color={color}]{display}[/color]".format({
		"color": color,
		"display": event_string
	})

	return _str


func to_wiki() -> Wiki:
	var new_wiki:Wiki = EVENT_WITNESSED.to_wiki()
	if SCORE > 0:
		new_wiki.update_color(Color.GREEN)
	elif SCORE < 0:
		new_wiki.update_color(Color.RED)
	return new_wiki
