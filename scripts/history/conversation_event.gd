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
	

func get_talk_menu_display_old() -> Wiki:
	var p_list: Array[String] = ["[{0}]".format([TICK])]
	for p:NPC in PARTICIPANTS:
		var _str = "[[NPC:{0}]]".format([p.ID])
		p_list.append(_str)
	p_list.append("talk together")
	var template_string: String = " ".join(p_list)
	#var new_wiki: Wiki = Wiki.new(template_string)
	var new_wiki: Wiki = Wiki.new()
	return new_wiki


# func get_talk_menu_display() -> Wiki:
# 	var template_list: Array[WikiBit]
# 	for i in range(0, len(PARTICIPANTS)):
# 		var npc: NPC = PARTICIPANTS[i]
# 		var new_bit:WikiBit = WikiBit.new(npc.NAME, "button")
# 		new_bit.IS_NPC = true
# 		template_list.append(new_bit)
# 		if i == len(PARTICIPANTS) -1:
# 			new_bit = WikiBit.new("and")
# 			template_list.append(new_bit)
# 	var new_bit: WikiBit = WikiBit.new("talk together")
# 	template_list.append(new_bit)


func get_talk_menu_display() -> Wiki:
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
