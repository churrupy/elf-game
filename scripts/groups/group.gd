class_name GROUP extends RefCounted

var PARTICIPANTS: Array[NPC]
var CURRENT_TOPIC:MEMORY_FILTER


func _init(first_owner:NPC) -> void:
	PARTICIPANTS.append(first_owner)
	sort()
	CURRENT_TOPIC = MEMORY_FILTER.new()

func _to_string() -> String:
	var location: Vector2 = get_location()
	if len(PARTICIPANTS) == 0:
		print("empty group! shouldn't happen")
		push_error("empty group")
		return ""
	elif len(PARTICIPANTS) == 1:
		var str_list: Array[String] = [
			"[{0}]".format([Global.TICKS]),
			PARTICIPANTS[0].NAME,
			"is standing at",
			str(location)
		]
		return " ".join(str_list)
	else:
		var names:Array = PARTICIPANTS.map(func(npc): return npc.NAME)
		names[-1] = "and " + names[-1]
		var str_list:Array[String] = [
			"[{0}]".format([Global.TICKS]),
			", ".join(names),
			"talk together at",
			str(location)
		]
		return " ".join(str_list)

func participants_to_string() -> String:
	var str = ""
	for i in range(0,len(PARTICIPANTS)):
		var npc:NPC = PARTICIPANTS[i]
		if i == len(PARTICIPANTS) - 1:
			str += "and " + npc.NAME
		else:
			str += npc.NAME + ", "
	return str

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
	PARTICIPANTS.sort_custom(func(a,b): return b.NAME < a.NAME)


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

func duplicate() -> GROUP:
	var new_group:GROUP = GROUP.new(PARTICIPANTS[0])
	new_group.PARTICIPANTS = PARTICIPANTS.duplicate()
	new_group.CURRENT_TOPIC = CURRENT_TOPIC
	return new_group
