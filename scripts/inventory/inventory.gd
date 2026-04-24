class_name INVENTORY extends RefCounted

var OWNER: Node
var ITEMS: Array[ITEM] = []


func _init(owner:Node) -> void:
	OWNER = owner

func get_all_tags() -> Array[String]:
	print(OWNER)
	var tag_list: Array[String]
	for item: ITEM in ITEMS:
		print(item)
		tag_list += item.TAGS
	return tag_list

func _to_string() -> String:
	var item_strings = ", ".join(ITEMS)
	var str_list: Array[String] = [
		OWNER.NAME,
		"has",
		item_strings,
		"in their inventory."
	]
	return " ".join(str_list)
