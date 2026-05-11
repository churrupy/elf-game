class_name GROUP_MANAGER extends Object

var GROUPS: Dictionary[String, GROUP]
var ENGINE

func _init(engine) -> void:
	ENGINE = engine

func create_group(npc:NPC) -> void:
	var new_group: GROUP = GROUP.new(npc)
	GROUPS[npc.ID] = new_group

func get_group(npc:NPC) -> GROUP:
	var npc_group: GROUP = GROUPS[npc.ID]
	return npc_group

func is_conversing(npc:NPC) -> bool:
	var npc_group:GROUP = get_group(npc)
	if len(npc_group.PARTICIPANTS) == 1:
		return false
	elif len(npc_group.PARTICIPANTS) == 0:
		push_error("Npc not in their own group!")
		return false
	else:
		return true

func is_in_same_group(npc1:NPC, npc2:NPC) -> bool:
	var group1:GROUP = get_group(npc1)
	var group2:GROUP = get_group(npc2)
	return group1==group2

func get_group_participants(npc:NPC) -> Array[NPC]:
	var npc_group:GROUP = get_group(npc)
	return npc_group.PARTICIPANTS


func join_npc(joiner:NPC, joinee:NPC) -> void:
	if is_in_same_group(joiner, joinee): return
	print(joiner, " is joining ", joinee)

	leave_group(joiner)
	# changing the group composition de facto makes a new group
	var new_group:GROUP = get_group(joinee).duplicate()
	new_group.PARTICIPANTS.append(joiner)

	var center:Vector2 = new_group.get_location()
	for npc:NPC in new_group.PARTICIPANTS:
		GROUPS[npc.ID] = new_group
		var direction:Vector2 = center - npc.LOCATION
		npc.update_direction(direction)
	
	#old_group.queue_free()
	#ENGINE.History.add_join_event(joiner, new_group)

	



func leave_group(leaver:NPC) -> void:
	if !is_conversing(leaver): return
	print(leaver, " is leaving group")
	var old_group:GROUP = get_group(leaver).duplicate()
	
	var index: int = old_group.PARTICIPANTS.find(leaver)
	if index > -1:
		old_group.PARTICIPANTS.remove_at(index)

	var center:Vector2 = old_group.get_location()
	for npc:NPC in old_group.PARTICIPANTS:
		GROUPS[npc.ID] = old_group
		var direction:Vector2 = center - npc.LOCATION
		npc.update_direction(direction)

	var new_group = GROUP.new(leaver)
	GROUPS[leaver.ID] = new_group
	#ENGINE.History.add_leave_event(leaver,new_group)

func introduce_self(speaker:NPC) -> bool:
	# returns true if speaker knows everyone
	var group:GROUP = get_group(speaker)
	for npc:NPC in group.PARTICIPANTS:
		if !speaker.knows_npc(npc):
			var added1:bool = ENGINE.History.add_statement_event(speaker, npc)	
			var added2:bool = ENGINE.History.add_prompt_event(speaker, npc)
			if added1 and added2: return false
			break
	return true



func respond_to_topic(speaker:NPC) -> void:
	# add conversation event
	print("responding to topic")
	var group:GROUP = get_group(speaker)
	#ENGINE.History.add_conversation_event(group)

	var new_topic: String = Dialogue.get_next_topic(group.CURRENT_TOPIC)
	var opinion: int = speaker.OPINIONS[new_topic]
	group.CURRENT_TOPIC = new_topic
	#ENGINE.History.add_dialogue_event(speaker, new_topic, opinion)

	

#region debug
func print_groups() -> void:
	for npc_id:String in GROUPS.keys():
		var group = GROUPS[npc_id]
		print(group)


#endregion
