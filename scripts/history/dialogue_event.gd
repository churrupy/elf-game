class_name DialogueEvent extends EVENT

var SPEAKER:NPC
var TOPIC:String
var OPINION:int
var TONE:String




func _init(speaker:NPC, topic:String, opinion:int, tone:String = "neutral") -> void:
	TICK = Global.TICKS
	EXPIRES_ON = TICK + 50
	SPEAKER = speaker
	TOPIC = topic
	OPINION = opinion
	TONE = tone
	HEARABLE = true
	LOCATION = speaker.LOCATION
	TYPE = "converse"
	generate_tags()


func generate_tags() -> void:
	TAGS.append(TONE)
	TAGS.append("social")
	
	if OPINION > 0:
		TAGS.append("likes_{0}".format([TOPIC]))
	elif OPINION < 0:
		TAGS.append("dislikes_{0}".format([TOPIC]))

func is_equal(other_event:EVENT) -> bool:
	if self == other_event: return true
	if other_event is not DialogueEvent: return false
	if SPEAKER != other_event.SPEAKER: return false
	if TOPIC != other_event.TOPIC: return false
	if OPINION != other_event.OPINION: return false
	return true

func _to_string() -> String:

	var opinion_dict:Dictionary = {
		1: "praised {0}",
		0: "commented on {0}",
		-1: "mocked {0}",

	}
	var opinion_string: String
	if OPINION > 0: 
		opinion_string = opinion_dict[1]
	elif OPINION == 0:
		opinion_string = opinion_dict[0]
	else:
		opinion_string = opinion_dict[-1]
	#var npc:NPC = Global.NPCS[SPEAKER_ID]
	var display_list: Array[String] = [
		"[{0}]".format([TICK]),
		SPEAKER.NAME,
		opinion_string.format([TOPIC]),
		"in a {0} tone.".format([TONE])
	]
	var display_string = " ".join(display_list)
	return display_string

func get_talk_menu_display_old() -> Wiki:
	var opinion_dict:Dictionary = {
		1: "praised [[TOPIC:{0}]]",
		0: "commented on [[TOPIC:{0}]]",
		-1: "mocked [[TOPIC:{0}]]",
	}

	var opinion_string: String
	if OPINION > 0: 
		opinion_string = opinion_dict[1]
	elif OPINION == 0:
		opinion_string = opinion_dict[0]
	else:
		opinion_string = opinion_dict[-1]

	var template_list: Array[String] = [
		"[{0}]".format([TICK]),
		"[[NPC:{0}]]".format([SPEAKER.ID]),
		opinion_string.format([TOPIC]),
		"in a [[TONE:{0}]] tone.".format([TONE])
	]
	var template_string: String = " ".join(template_list)
	#var new_wiki: Wiki = Wiki.new(template_string)
	var new_wiki: Wiki = Wiki.new()
	return new_wiki

func get_talk_menu_display() -> Wiki:
	var new_wiki: Wiki = Wiki.new()
	new_wiki.add_to_wiki("[{0}]".format([TICK]))
	new_wiki.add_to_wiki(SPEAKER.ID, "button", Color.WHITE, true)
	var opinion_dict:Dictionary = {
		1: "praised",
		0: "commented on",
		-1: "mocked",
	}
	if OPINION > 0: 
		new_wiki.add_to_wiki(opinion_dict[1])
	elif OPINION == 0:
		new_wiki.add_to_wiki(opinion_dict[0])
	else:
		new_wiki.add_to_wiki(opinion_dict[-1])

	new_wiki.add_to_wiki(TOPIC, "button")
	new_wiki.add_to_wiki("in a")
	new_wiki.add_to_wiki(TONE, "button")
	new_wiki.add_to_wiki("tone.")

	return new_wiki



func process_involvement(npc:NPC) -> void:
	# does two things (if applicable):
	# creates a witness report
	# creates a relationship memory (whatever i want to call that)
	if npc == SPEAKER: 
		npc.add_witness_report(self, "participant")

	var npc_opinion: int = npc.does_share_opinion(TOPIC, OPINION)

	if npc_opinion == 0:
		return
	elif npc_opinion == 1:
		# shares opinion
		npc.add_witness_report(self, "witness")

		var memory_id:String = "share like"
		if OPINION < 0:
			memory_id = "share dislike"
		
		npc.add_relationship_memory(SPEAKER, memory_id)
	else:
		#opposite opinions
		#var report:WitnessReport = WitnessReport.new(npc, self, -1)
		npc.add_witness_report(self, "witness")

		var memory_id:String = "likes something I hate"
		if OPINION < 0:
			memory_id = "hates something I like"
		npc.add_relationship_memory(SPEAKER, memory_id)

func includes_npc(target:NPC) -> bool:
	if target == SPEAKER: return true
	return false
