class_name GROUP extends RefCounted

var PARTICIPANTS: Array[NPC]
var CURRENT_TOPIC:MEMORY_FILTER


func _init(npc_list:Array[NPC]) -> void:
	PARTICIPANTS = npc_list.duplicate()

func _to_string() -> String:
	var location:Vector2 = get_location()
	var names:Array = PARTICIPANTS.map(func(npc): return npc.NAME)
	names[-1] = "and " + names[-1]
	var str_list:Array[String] = [
		", ".join(names),
		"are gathered together at",
		str(location)
	]

	return " ".join(str_list)


func participants_to_string() -> String:
	var _str:String = ""
	for i in range(0,len(PARTICIPANTS)):
		var npc:NPC = PARTICIPANTS[i]
		if i == len(PARTICIPANTS) - 1:
			_str += "and " + npc.NAME
		else:
			_str += npc.NAME + ", "
	return _str

func to_wiki() -> Wiki:
	if len(PARTICIPANTS) == 0:
		print("empty group! shouldn't happen")
		push_error("empty group")
		return null
	elif len(PARTICIPANTS) == 1:
		return null
	var new_wiki: Wiki = Wiki.new()
	new_wiki.add_to_wiki("[{0}]".format([Global.TICKS]))
	for i in range(0, len(PARTICIPANTS)):
		if i == len(PARTICIPANTS) -1:
			new_wiki.add_to_wiki("and")
		elif i != 0:
			new_wiki.add_to_wiki(",")
		var npc: NPC = PARTICIPANTS[i]
		new_wiki.add_to_wiki(npc.ID, "button")
	new_wiki.add_to_wiki("talk together at")
	new_wiki.add_to_wiki(str(get_location()))
	return new_wiki
	

func sort() -> void:
	PARTICIPANTS.sort_custom(func(a,b): return a.NAME < b.NAME)


func get_location() -> Vector2:
	# the most average location
	var x: int = 0
	var y: int = 0

	for p:NPC in PARTICIPANTS:
		x += p.LOCATION[0]
		y += p.LOCATION[1]

	x = x/len(PARTICIPANTS)
	y = y/len(PARTICIPANTS)

	var average_location:Vector2 = Vector2(x,y)
	return average_location


func is_equal(other_group:GROUP) -> bool:
	sort()
	other_group.sort()
	return PARTICIPANTS == other_group.PARTICIPANTS
