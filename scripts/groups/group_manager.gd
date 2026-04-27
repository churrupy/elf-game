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
	# if npc1 not in npc_group.PARTICIPANTS:
	# 	push_error("Npc not in their own group!")
	# 	return false
	# if npc2 not in npc_group.PARTICIPANTS:
	# 	return false
	# return true

func get_group_participants(npc:NPC) -> Array[NPC]:
	var npc_group:GROUP = get_group(npc)
	return npc_group.PARTICIPANTS


func join_npc(joiner:NPC, joinee:NPC) -> void:
	if is_in_same_group(joiner, joinee): return
	print(joiner, " is joining ", joinee)
	var old_group:GROUP = get_group(joiner)
	# changing the group composition de facto makes a new group
	var new_group:GROUP = get_group(joinee).duplicate()
	for p:NPC in new_group.PARTICIPANTS:
		GROUPS[p.ID] = new_group
	new_group.PARTICIPANTS.append(joiner)
	#old_group.queue_free()
	GROUPS[joiner.ID] = new_group
	ENGINE.History.add_join_event(joiner, new_group)

func leave_group(leaver:NPC) -> void:
	if !is_conversing(leaver): return
	print(leaver, " is leaving group")
	var group:GROUP = get_group(leaver).duplicate()
	
	var index: int = group.PARTICIPANTS.find(leaver)
	if index > -1:
		group.PARTICIPANTS.remove_at(index)

	for p:NPC in group.PARTICIPANTS:
		GROUPS[p.ID] = group

	var new_group = GROUP.new(leaver)
	GROUPS[leaver.ID] = new_group
	ENGINE.History.add_leave_event(leaver,group)
	

#region debug
func print_groups() -> void:
	for npc_id:String in GROUPS.keys():
		var group = GROUPS[npc_id]
		print(group)


#endregion
