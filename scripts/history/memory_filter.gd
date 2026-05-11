class_name MEMORY_FILTER extends RefCounted

# var ENGINE

var OWNER:NPC
var memory_list:Array[MEMORY]

var mandatory_npcs:Array[NPC]
var illegal_npcs:Array[NPC]

var room:ROOM
var action_type:String

var filtered_list:Array[MEMORY]


func _init(owner:NPC) -> void:
	OWNER = owner
	memory_list = OWNER.MEMORIES

func must_have_npc(npc:NPC) -> MEMORY_FILTER:
	mandatory_npcs.append(npc)
	return self

func cannot_have(npc:NPC) -> MEMORY_FILTER:
	illegal_npcs.append(npc)
	return self

func in_room(_room:ROOM) -> MEMORY_FILTER:
	room = _room
	return self

func remembered_action(type:String) -> MEMORY_FILTER:
	action_type = type
	return self


func run_filter() -> Array[MEMORY]:
	for mem:MEMORY in memory_list:
		if mem.EVENT_ROOM != room: continue

		if type_string(typeof(mem.EVENT_ACTION)) != action_type: continue

		var involved_npcs: Array[NPC] = mem.EVENT_ACTION.involved_npcs()
		for npc:NPC in mandatory_npcs:
			if npc not in involved_npcs: continue

		for npc:NPC in involved_npcs:
			if npc in illegal_npcs: continue

		filtered_list.append(mem)

	return filtered_list
