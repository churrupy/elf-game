class_name ConversationEvent extends EVENT

var PARTICIPANTS: Array[NPC]


func _init(participants:Array[NPC]) -> void:
	TICK = Global.TICKS
	EXPIRES_ON = TICK + 50
	PARTICIPANTS = participants
	SEEABLE = true
	LOCATION = participants[0].LOCATION # figure this out later
	TYPE = "converse"
	generate_tags()

func generate_tags() -> void:
	TAGS.append("social")

func _to_string() -> String:
	var names:Array[String] = PARTICIPANTS.map(func(npc): return npc.NAME)
	names[-1] = "and " + names[-1]
	var name_string: String = "[EVENT]" + ", ".join(names) + " talk together."
	return name_string

func process_involvement(npc:NPC) -> void:
	if npc in PARTICIPANTS:
		npc.add_witness_report(self, "participant")
	for p:NPC in PARTICIPANTS:
		if p.ID not in npc.RELATIONSHIPS.keys():
			return

	npc.add_witness_report(self, "witness")

func process_reaction_old(npc:NPC) -> void:
	if npc in PARTICIPANTS: 
		npc.add_witness_report(self, "participant")
	# if npc knows everyone in participants, make a neutral witness report
	for p:NPC in PARTICIPANTS:
		if p.ID not in npc.RELATIONSHIPS.keys():
			return

	npc.add_witness_report(self, "witness")


func includes_npc(target:NPC) -> bool:
	return target in PARTICIPANTS
	