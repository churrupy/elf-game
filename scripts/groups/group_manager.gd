class_name GROUP_MANAGER extends Object

var GROUP_LIST: Dictionary[String, GROUP]
var ENGINE

func _init(engine) -> void:
	ENGINE = engine

func create_group(npc:NPC) -> GROUP:
	var new_group:GROUP = GROUP.new()
	GROUP_LIST[npc.ID] = new_group
	return new_group

func create_group_from_list(npc_list:Array) -> GROUP:
	var new_group: GROUP = GROUP.new()
	for npc:NPC in npc_list:
		GROUP_LIST[npc.ID] = new_group
	return new_group

# func create_group(npc:NPC) -> GROUP:
# 	var new_group: GROUP = GROUP.new(npc)
# 	GROUPS[npc.ID] = new_group
# 	return new_group

# func create_group_from_list(npc_list:Array) -> GROUP:
# 	# really gotta figure out a better way to do this lol
# 	var new_group: GROUP = create_group(npc_list[0])
# 	for npc:NPC in npc_list:
# 		join_npc(npc, npc_list[0])
		
# 	return new_group


func get_group(npc:NPC) -> GROUP:
	var npc_group: GROUP = GROUP_LIST[npc.ID]
	return npc_group



func is_conversing(npc:NPC) -> bool:
	var npc_group:GROUP = get_group(npc)
	for id:String in GROUP_LIST.keys():
		var checked_group:GROUP = GROUP_LIST[id]
		if checked_group == npc_group and id != npc.ID:
			return true
	return false
	# if len(npc_group.PARTICIPANTS) == 1:
	# 	return false
	# elif len(npc_group.PARTICIPANTS) == 0:
	# 	push_error("Npc not in their own group!")
	# 	return false
	# else:
	# 	return true

func is_in_same_group(npc1:NPC, npc2:NPC) -> bool:
	if npc1 == npc2: return true
	var group1:GROUP = get_group(npc1)
	var group2:GROUP = get_group(npc2)
	return group1==group2


func get_group_participants(npc:NPC) -> Array[String]:
	var _group:GROUP = get_group(npc)
	var npc_list:Array[String]
	for id:String in GROUP_LIST.keys():
		var checked_group:GROUP = GROUP_LIST[id]
		if checked_group == _group:
			npc_list.append(id)

	return npc_list

func get_group_participants_from_group(_group:GROUP) -> Array[String]:
	var npc_list:Array[String]
	for id:String in GROUP_LIST.keys():
		if _group == GROUP_LIST[id]:
			npc_list.append(id)
	return npc_list

# func get_group_participants(npc:NPC) -> Array[NPC]:
# 	var npc_group:GROUP = get_group(npc)
# 	return npc_group.PARTICIPANTS

func join_npc(joiner:NPC, joinee:NPC) -> GROUP:
	# var joined_group:GROUP = get_group(joinee)
	var joined_group_participants = get_group_participants(joinee)

	var new_group:GROUP = GROUP.new()
	GROUP_LIST[joiner.ID] = new_group
	for id:String in joined_group_participants:
		GROUP_LIST[id] = new_group

	return new_group



# func join_npc(joiner:NPC, joinee:NPC) -> void:
# 	if is_in_same_group(joiner, joinee): return
# 	print(joiner, " is joining ", joinee)

# 	leave_group(joiner)
# 	# changing the group composition de facto makes a new group
# 	var new_group:GROUP = get_group(joinee).duplicate()
# 	new_group.PARTICIPANTS.append(joiner)

# 	var center:Vector2 = new_group.get_location()
# 	for npc:NPC in new_group.PARTICIPANTS:
# 		GROUPS[npc.ID] = new_group
# 		var direction:Vector2 = center - npc.LOCATION
# 		npc.update_direction(direction)
	
	
func leave_group(leaver:NPC) -> GROUP:
	var new_group:GROUP = GROUP.new()
	GROUP_LIST[leaver.ID] = new_group
	return new_group


# func leave_group(leaver:NPC) -> void:
# 	if !is_conversing(leaver): return
# 	print(leaver, " is leaving group")
# 	var old_group:GROUP = get_group(leaver).duplicate()
	
# 	var index: int = old_group.PARTICIPANTS.find(leaver)
# 	if index > -1:
# 		old_group.PARTICIPANTS.remove_at(index)

# 	var center:Vector2 = old_group.get_location()
# 	for npc:NPC in old_group.PARTICIPANTS:
# 		GROUPS[npc.ID] = old_group
# 		var direction:Vector2 = center - npc.LOCATION
# 		npc.update_direction(direction)

# 	var new_group = GROUP.new(leaver)
# 	GROUPS[leaver.ID] = new_group
# 	#ENGINE.History.add_leave_event(leaver,new_group)


#region debug
# func print_groups() -> void:
# 	for npc_id:String in GROUPS.keys():
# 		var group = GROUPS[npc_id]
# 		print(group)

func print_groups() -> void:
	var checked_groups:Array[GROUP]
	for id:String in GROUP_LIST.keys():
		var _group:GROUP = GROUP_LIST[id]
		if _group not in checked_groups:
			var npc:NPC = Global.NPCS[id]
			var participants:Array[String] = get_group_participants(npc)
			print(participants)
			checked_groups.append(_group)

#endregion
