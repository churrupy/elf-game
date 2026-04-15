class_name IntroductionEvent extends EVENT

var SPEAKER: NPC
var TARGET:NPC
var TONE:String

func _init(speaker:NPC, target:NPC, tone:String = "neutral") -> void:
	#TICK = Global.TICKS
	#EXPIRES_ON = TICK + 50
	SPEAKER = speaker
	TARGET = target
	TONE = tone
	HEARABLE = true
	LOCATION = speaker.LOCATION
	TYPE = "converse"
	generate_tags()

func update_ticks() -> void:
	TICK = Global.TICKS
	EXPIRES_ON = TICK + 50

func generate_tags() -> void:
	TAGS.append(TONE)
	TAGS.append("social")

func is_equal(other_event: EVENT) -> bool:
	if self == other_event: return true
	if other_event is not IntroductionEvent: return false
	if SPEAKER != other_event.SPEAKER: return false
	if TARGET != other_event.TARGET: return false
	return true

func _to_string() -> String:
	var display_list: Array[String] = [
		"[{0}]".format([TICK]),
		SPEAKER.NAME,
		"introduced themselves to",
		TARGET.NAME,
		"in a {0} tone.".format([TONE])
	]

	var display_string:String = " ".join(display_list)
	return display_string

func process_involvement(npc:NPC) -> void:
	# only processes if npc knows both people
	if npc == SPEAKER:
		npc.add_witness_report(self, "participant") 
	if npc == TARGET:
		npc.add_witness_report(self, "witness")
		npc.add_relationship_memory(SPEAKER, "introduce")
	elif SPEAKER.ID in npc.RELATIONSHIPS:
		if TARGET.ID in npc.RELATIONSHIPS:
			#var report:WitnessReport =  .new(npc, self, 1)
			npc.add_witness_report(self, "witness")

func includes_npc(target:NPC) -> bool:
	return target == SPEAKER


func get_talk_menu_display() -> Wiki:

	var template_list: Array[String] = [
		"[{0}]".format([TICK]),
		"[[NPC:{0}]]".format([SPEAKER.ID]),
		"introduced themselves to",
		"[[NPC:{0}]]".format([TARGET.ID]),
		"in a [[TONE:{0}]] tone.".format([TONE])
	]

	var template_string: String = " ".join(template_list)
	var new_wiki: Wiki = Wiki.new(template_string)
	return new_wiki
