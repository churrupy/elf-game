class_name ConversationEvent extends EVENT

var PARTICIPANTS: Array[NPC]


func _init(participants:Array[NPC]) -> void:
	TICK = Global.TICKS
	EXPIRES_ON = TICK + 50
	PARTICIPANTS = participants
	PARTICIPANTS.sort_custom(func(a,b): return b.NAME < a.NAME)
	SEEABLE = true
	LOCATION = participants[0].LOCATION # figure this out later
	TYPE = "converse"
	generate_tags()


func generate_tags() -> void:
	TAGS.append("social")

func is_equal(other_event: EVENT) -> bool:
	if self == other_event: return true
	if other_event is not ConversationEvent: return false
	if PARTICIPANTS == other_event.PARTICIPANTS: 
		return true
	return false

func _to_string() -> String:
	var names:Array = PARTICIPANTS.map(func(npc): return npc.NAME)
	names[-1] = "and " + names[-1]
	var name_string: String = "[" + str(TICK) + "]" + ", ".join(names) + " talk together."
	return name_string



func process_involvement(npc:NPC) -> void:
	if npc in PARTICIPANTS:
		npc.add_witness_report(self, "participant")
	else:
		npc.add_witness_report(self, "witness")



func includes_npc(target:NPC) -> bool:
	return target in PARTICIPANTS

func get_all_participants() -> Array[NPC]:
	return PARTICIPANTS
	

func to_wiki() -> Wiki:
	var new_wiki: Wiki = Wiki.new()
	new_wiki.add_to_wiki("[{0}]".format([TICK]))
	for i in range(0, len(PARTICIPANTS)):
		if i == len(PARTICIPANTS) -1:
			new_wiki.add_to_wiki("and")
		elif i != 0:
			new_wiki.add_to_wiki(",")
		var npc: NPC = PARTICIPANTS[i]
		new_wiki.add_to_wiki(npc.ID, "button")
		
	new_wiki.add_to_wiki("talk together")
	return new_wiki
