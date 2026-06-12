class_name SOCIAL_WEB extends RefCounted

var OWNER:NPC
var RELATIONSHIP_LIST:Array[RELATIONSHIP]

func _init(npc:NPC) -> void:
	OWNER = npc


func add_relationship(target:NPC) -> RELATIONSHIP:
	var new_relationship:RELATIONSHIP = RELATIONSHIP.new(OWNER, target)
	RELATIONSHIP_LIST.append(new_relationship)
	return new_relationship


func get_relationship(target:NPC) -> RELATIONSHIP:
	var index:int = RELATIONSHIP_LIST.find_custom(func(a): return a.TARGET == target)
	if index > -1:
		return RELATIONSHIP_LIST[index]
	else:
		return null

func get_relationship_list(npc_list:Array[NPC]) -> Array[RELATIONSHIP]:
	var rel_list:Array[RELATIONSHIP]
	for npc:NPC in npc_list:
		var rel:RELATIONSHIP = get_relationship(npc)
		if rel != null:
			rel_list.append(rel)
	return rel_list


func to_wiki() -> Wiki:
	print("social web to wiki")
	var new_wiki:Wiki = Wiki.new()
	new_wiki.add_header("RELATIONSHIPS")
	for rel:RELATIONSHIP in RELATIONSHIP_LIST:
		var rel_wiki:Wiki = rel.to_wiki()
		new_wiki.add_wiki(rel_wiki)
	return new_wiki