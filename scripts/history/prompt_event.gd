class_name PromptEvent extends EVENT

var SPEAKER:NPC
var TARGET:NPC
var TONE:String

func _init(speaker:NPC, target:NPC, tone:String = "neutral") -> void:
	TICK = Global.TICKS
	EXPIRES_ON = TICK + 50
	SPEAKER = speaker
	TARGET = target
	TONE = tone
	HEARABLE = true
	LOCATION = speaker.LOCATION
	TYPE = "converse"
	generate_tags()

func generate_tags() -> void:
	TAGS.append(TONE)
	TAGS.append("social")

func is_equal(other_event: EVENT) -> bool:
	if self == other_event: return true
	if other_event is not PromptEvent: return false
	if SPEAKER != other_event.SPEAKER: return false
	if TARGET != other_event.TARGET: return false
	return true

func _to_string() -> String:
	var display_list: Array[String] = [
		"[{0}]".format([TICK]),
		SPEAKER.NAME,
		"asks",
		TARGET.NAME,
		"their name"
	]

	if TONE != "":
		display_list += [
			"in a {0} tone.".format([TONE])		
		]

	var display_string:String = " ".join(display_list)
	return display_string

func process_involvement(npc:NPC) -> void:
	if npc == SPEAKER:
		npc.add_witness_report(self, "participant")
	else:
		if npc == TARGET:
			npc.requests_response(self)
		npc.add_witness_report(self, "witness")

func process_response() -> String:
	return "introduce"

func includes_npc(target:NPC) -> bool:
	return target == SPEAKER

func get_all_participants() -> Array[NPC]:
	return [SPEAKER]

func to_wiki() -> Wiki:
	var new_wiki: Wiki = Wiki.new()
	new_wiki.add_to_wiki("[{0}]".format([TICK]))
	new_wiki.add_to_wiki(SPEAKER.ID, "button", Color.WHITE, true)
	new_wiki.add_to_wiki("asks")
	new_wiki.add_to_wiki(TARGET.ID, "button", Color.WHITE, true)
	new_wiki.add_to_wiki("their name")
	
	if TONE != "":
		new_wiki.add_to_wiki("in a")
		new_wiki.add_to_wiki(TONE, "button")
		new_wiki.add_to_wiki("tone")
	return new_wiki
