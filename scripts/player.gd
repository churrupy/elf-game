class_name Player extends Node2D

var ID:String = "player"

var NAME:String = "Casey"

var LOCATION: Vector2
var CURRENT_ACTION: IdleGoal
var NEEDS: Dictionary
var COLOR: Color = Color(1,1,1)


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass

func _process(delta:float) -> void:
	return

func populate_journal(menu, engine, _subentry) -> void:
	menu.update_title(NAME)

	var title:Label = Label.new()
	title.text = "INVENTORY"
	menu.add_to_entry(title)
	
	var inventory:INVENTORY = engine.InventoryManager.get_inventory_of("player")
	var inventory_wiki:Wiki = inventory.to_wiki()
	menu.add_to_entry(inventory_wiki)
	# var inventory_summary:Array = inventory.get_summary()
	# for i:Dictionary in inventory_summary:
	# 	var new_display:RichTextLabel = i["item"].create_display(i["count"])
	# 	menu.add_to_entry(new_display)
