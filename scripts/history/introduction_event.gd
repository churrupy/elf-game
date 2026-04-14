class_name IntroductionEvent extends EVENT

var SPEAKER: NPC
var TARGET:NPC
var TONE:String

func _init(speaker:NPC, target:NPC, tone:String = "") -> void:
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

func _to_string() -> String:
	var display_list: Array[String] = [
		"[EVENT]",
		SPEAKER.NAME,
		"introduced themselves to",
		TARGET.NAME,
		"in a %s tone." %TONE
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
