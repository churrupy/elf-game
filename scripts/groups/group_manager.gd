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


#region debug
func print_groups() -> void:
	for npc_id:String in GROUPS.keys():
		var group = GROUPS[npc_id]
		print(group)


#endregion
