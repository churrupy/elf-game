class_name HungerGoal extends ACTION



var FOOD_ITEM:ITEM

var FULL_HUNGER:bool = false
var HAS_FOOD:bool = false

var IMPOSSIBLE:bool = false

func _init(engine, owner:NPC) -> void:
	# i hope this works lol
	# no scoring needed for this
	ID = "snack"
	ENGINE = engine
	OWNER = owner
	# TARGET = target
	#LOCATION = Vector2.INF
	CHATTABLE = false
	#super._init(engine, owner, target)

func score() -> HungerGoal:
	if OWNER.NEEDS["hunger"] < 50:
		SCORE = 10 + (100 - OWNER.NEEDS["hunger"])
		if OWNER.NEEDS["hunger"] < 20:
			SCORE += 20
	# SCORE = 100 - OWNER.NEEDS["hunger"]
	# if OWNER.NEEDS["hunger"] < 50:
	# 	SCORE += 10

	print("hunger score: ", SCORE)
	return self

func enter_state() -> void:
	print("entering: HungerGoal")
	if OWNER.NEEDS["hunger"] >= 80:
		FULL_HUNGER = true
		return
	
	HAS_FOOD = ENGINE.InventoryManager.inventory_has_tag(OWNER, "food")

func run() -> ActionResult:
	if FULL_HUNGER:
		return ActionResult.new("end")
	
	elif HAS_FOOD:
		# naughty, bad programmer, slap!
		print("food in inventory")
		var food_item:ITEM = ENGINE.InventoryManager.get_first_tagged_from_inventory(OWNER, "food")
		var new_action:ACTION = EatAction.new(ENGINE, OWNER).set_item(food_item)
		return ActionResult.new("action",  new_action)


	else:
		var new_action:ACTION = PickupAction.new(ENGINE, OWNER).set_tag("food")
		return ActionResult.new("add", new_action)



func _to_string() -> String:
	var str_list:Array[String] = [
		OWNER.NAME,
		"eats"
	]
	return " ".join(str_list)
