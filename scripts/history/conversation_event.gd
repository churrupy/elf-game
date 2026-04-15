class_name ConversationEvent extends EVENT

var PARTICIPANTS: Array[NPC]


func _init(participants:Array[NPC]) -> void:
	#TICK = Global.TICKS
	#EXPIRES_ON = TICK + 50
	PARTICIPANTS = participants
	PARTICIPANTS.sort_custom(func(a,b): return b.NAME < a.NAME)
	SEEABLE = true
	LOCATION = participants[0].LOCATION # figure this out later
	TYPE = "converse"
	generate_tags()

func update_ticks() -> void:
	TICK = Global.TICKS
	EXPIRES_ON = TICK + 50

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
	

func get_talk_menu_display() -> Wiki:
	var p_list: Array[String] = ["[{0}]".format([TICK])]
	for p:NPC in PARTICIPANTS:
		var _str = "[[NPC:{0}]]".format([p.ID])
		p_list.append(_str)
	p_list.append("talk together")
	var template_string: String = " ".join(p_list)
	var new_wiki: Wiki = Wiki.new(template_string)
	return new_wiki
