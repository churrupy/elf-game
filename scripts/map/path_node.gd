class_name PathNode extends RefCounted

# https://www.datacamp.com/tutorial/a-star-algorithm

var LOCATION:Vector2
var COST:float #g(n)
var HEURESTIC:float # h(n)
# var ESTIMATED_COST:float # f(n)

var PARENT:PathNode


func _init(loc:Vector2, end:Vector2, parent:PathNode = null) -> void:
	LOCATION = loc
	update_parent(parent)
	HEURESTIC = loc.distance_to(end)

func update_parent(parent:PathNode) -> void:
	if parent == null:
		PARENT = null
		COST = 0
		return
	var new_cost:float = parent.COST + parent.LOCATION.distance_to(LOCATION)
	# technically diagonals are the same distance as laterals, but this stops them from boinging across the map
	if (PARENT == null) or (new_cost < COST):
		PARENT = parent
		COST = new_cost
	# elif PARENT == null:
	# 	PARENT = parent
	# 	COST = PARENT.COST + PARENT.distance_to(LOCATION)
	# elif (PARENT == null) or (parent.COST + 1 < COST):
	# 	PARENT = parent
	# 	COST = PARENT.COST + PARENT.distance_to(LOCATION)

func get_estimated_cost() -> float:
	return COST + HEURESTIC

func _to_string() -> String:
	var str_list:Array[String] = [
		str(LOCATION),
		": $",
		str(snappedf(get_estimated_cost(), 0.001))
	]
	return " ".join(str_list)
