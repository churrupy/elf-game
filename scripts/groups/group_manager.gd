class_name GROUP_MANAGER extends Object

var GROUP_LIST:Array[GROUP]
var ENGINE

func _init(engine) -> void:
	ENGINE = engine


func create_group(npc_list:Array[NPC]) -> GROUP:
	var new_group: GROUP = GROUP.new(npc_list)
	GROUP_LIST.append(new_group)
	return new_group

func get_group(npc:NPC) -> GROUP:
	for g:GROUP in GROUP_LIST:
		if npc in g.PARTICIPANTS:
			return g
	return null



func is_in_same_group(npc1:NPC, npc2:NPC) -> bool:
	if npc1 == npc2: return true
	var group:GROUP = get_group(npc1)
	if group == null:
		return false
	return npc2 in group.PARTICIPANTS


func join_npc(joiner:NPC, joinee:NPC) -> GROUP:
	var joiner_group:GROUP = get_group(joiner)
	var joinee_group:GROUP = get_group(joinee)

	if joiner_group != null and joiner_group == joinee_group:
		return joiner_group

	if joiner_group != null:
		leave_group(joiner)

	if joinee_group == null:
		return create_group([joiner, joinee])
	else:
		joinee_group.PARTICIPANTS.append(joiner)
		return joinee_group




func leave_group(leaver:NPC) -> void:
	var npc_group:GROUP = get_group(leaver)
	if npc_group != null:
		var index:int = npc_group.PARTICIPANTS.find(leaver)
		if index > -1:
			npc_group.PARTICIPANTS.remove_at(index)
	
	

func update() -> void:
	# removes empty or groups with just one npc in it
	var clean_list:Array[GROUP]
	for g:GROUP in GROUP_LIST:
		if len(g.PARTICIPANTS) >= 2:
			clean_list.append(g)
	GROUP_LIST = clean_list

#region debug

func print_groups() -> void:
	for g:GROUP in GROUP_LIST:
		print(g)

#endregion
