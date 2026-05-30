class_name PickupItemGoal extends ACTION

var NEED:String = ""

# func _init(engine, owner) -> void:
# 	ENGINE = engine
# 	OWNER = owner


func score() -> void:
	var need:float = OWNER.NEEDS[NEED]/100
	SCORE = 1 - (need * need)

func run() -> ActionResult:
	if "target_need" not in OWNER.BLACKBOARD:
		return ActionResult.new("fail")

	var target_need:String = OWNER.BLACKBOARD["target_need"]
	# check that an applicable item is not current in the NPC's inventory
	if ENGINE.InventoryManager.inventory_can_refresh(OWNER, target_need):
		return ActionResult.new("success")

	var current_room:ROOM = ENGINE.Map.get_room(OWNER.LOCATION)
	var inventory_list:Array[INVENTORY] = INVENTORY_FILTER.new(ENGINE).set_list().set_room(current_room).set_fulfills_need(target_need).run_filter()

	if len(inventory_list) == 0:
		add_action(LeaveRoomAction)
		return ActionResult.new("continue")

	inventory_list.sort_custom(func(a,b): return a.OWNER.LOCATION.distance_to(OWNER.LOCATION) < b.OWNER.LOCATION.distance_to(OWNER.LOCATION))
	var chosen_inventory:INVENTORY = inventory_list[0]
	var chosen_item:ITEM = chosen_inventory.get_first_fulfills(target_need)
	OWNER.BLACKBOARD["target_tile"] = chosen_inventory.OWNER
	OWNER.BLACKBOARD["target_item"] = chosen_item
	
	var action_list:Array[GDScript] = [
		PickupAction,
		MoveToTileAction
	]

	for action_class:GDScript in action_list:
		add_action(action_class)

	return ActionResult.new("continue")
	


#func run() -> ActionResult:
	#print("PickupItemGoal for ", NEED)
	## does not run continuously until succeeding, just succeeds and moves on
	#return ActionResult.new("running")


func _to_string() -> String:
	var str_list:Array[String] = [
		OWNER.NAME,
		"is picking up someting"
	]

	return " ".join(str_list)
