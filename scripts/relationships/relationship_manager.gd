class_name RELATIONSHIP_MANAGER extends RefCounted

var ENGINE
# var RELATIONSHIP_LIST:Array[RELATIONSHIP]
var WEB_LIST:Array[SOCIAL_WEB]

func _init(engine) -> void:
	ENGINE = engine

func create_web(npc:NPC) -> void:
	var new_web:SOCIAL_WEB = SOCIAL_WEB.new(npc)
	WEB_LIST.append(new_web)


func get_web(npc:NPC) -> SOCIAL_WEB:
	var index:int = WEB_LIST.find_custom(func(a): return a.OWNER == npc)
	if index > -1:
		return WEB_LIST[index]
	else:
		return null
	
func create_relationship(subject:NPC, target:NPC) -> RELATIONSHIP:
	var sub_web:SOCIAL_WEB = get_web(subject)
	var new_rel:RELATIONSHIP = sub_web.add_relationship(target)
	return new_rel

func get_relationship(npc:NPC, target:NPC) -> RELATIONSHIP:
	var npc_web:SOCIAL_WEB = get_web(npc)
	var rel:RELATIONSHIP = npc_web.get_relationship(target)
	return rel

func get_relationship_list(npc:NPC, target_list:Array[NPC]) -> Array[RELATIONSHIP]:
	var rel_list:Array[RELATIONSHIP]
	for target:NPC in target_list:
		var rel:RELATIONSHIP = get_relationship(npc, target)
		if rel == null:
			rel = get_phantom_relationship(npc, target)
		rel_list.append(rel)
	return rel_list

func get_phantom_relationship(npc:NPC, target:NPC) -> RELATIONSHIP:
	return RELATIONSHIP.new(npc, target)
