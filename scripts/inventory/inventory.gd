class_name INVENTORY extends RefCounted

var OWNER: Node
var ITEMS: Array[ITEM] = []


func _init(owner:Node) -> void:
	OWNER = owner

func count_item(item:String) -> int:
	var count:int = 0
	for i:ITEM in ITEMS:
		if i.NAME == item:
			count += 1
	return count

func count_tag(tag:String) -> int:
	var count:int = 0
	for i:ITEM in ITEMS:
		if tag in i.DATA["tags"]:
			count += 1
	return count

func get_all_tags() -> Array[String]:
	var tag_list: Array[String] = []
	for item: ITEM in ITEMS:
		tag_list += item.TAGS
	return tag_list

func get_all_needs() -> Array[String]:
	var needs_list:Array[String]
	for i:ITEM in ITEMS:
		if "refreshes" in i.DATA:
			var refreshed_need:String = i.DATA["refreshes"]
			if refreshed_need not in needs_list:
				needs_list.append(refreshed_need)
	return needs_list

func can_refresh(_need:String) -> bool:
	for i:ITEM in ITEMS:
		var item_data:Dictionary = i.DATA
		if "refreshes" in item_data.keys():
			if item_data["refreshes"] == _need:
				return true

	return false

func get_first_fulfills(_need:String) -> ITEM:
	for i:ITEM in ITEMS:
		var item_data:Dictionary = i.DATA
		if "refreshes" in item_data.keys():
			if item_data["refreshes"] == _need:
				return i
	return null

func get_all_items_tagged_with(tag:String) -> Array[ITEM]:
	var item_list:Array[ITEM]
	for i:ITEM in ITEMS:
		if i.has_tag(tag) and i not in item_list:
			item_list.append(i)
	return item_list


func get_summary() -> Array:
	var summary:Array
	var repeat_items:Array[String]

	for i:ITEM in ITEMS:
		if i.TYPE in repeat_items: continue
		var dict:Dictionary = {
			"item": i,
			"count": count_item(i.NAME)
		}
		summary.append(dict)
		repeat_items.append(i.TYPE)

	return summary

func to_wiki() -> Wiki:
	var new_wiki:Wiki = Wiki.new()
	new_wiki.add_header("INVENTORY")
	var inventory_summary: Array = get_summary()
	for i:Dictionary in inventory_summary:
		new_wiki.add_indented_newline()
		new_wiki.add_button(i["item"])
		new_wiki.add_text("x" + str(i["count"]))
	return new_wiki




func _to_string() -> String:
	var item_strings = ", ".join(ITEMS)
	var str_list: Array[String] = [
		OWNER.NAME,
		"has",
		item_strings,
		"in their inventory."
	]
	return " ".join(str_list)
