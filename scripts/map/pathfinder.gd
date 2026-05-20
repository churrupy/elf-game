class_name Pathfinder extends RefCounted

var ENGINE
var START:Vector2
var END:Vector2

var PATH:Array[Vector2] = []

func _init(engine) -> void:
	ENGINE = engine

func set_start(loc:Vector2) -> Pathfinder:
	START = loc
	return self

func set_end(loc:Vector2) -> Pathfinder:
	END = loc
	return self

func find_path() -> Array[Vector2]:
	# a* (hopefully)
	if START == END:
		print("PAthfinding: START and END are same location")
		push_error("Pathfinding: START and END are same location")
		return []

	var initial_node:PathNode = PathNode.new(START, END)

	var queue: Array[PathNode] = [initial_node]
	var visited: Array[Vector2] = []
	# var parent_dict: Dictionary = {}

	var current:PathNode

	while len(queue) > 0:
		queue.sort_custom(func(a,b): return a.get_estimated_cost() < b.get_estimated_cost())
		current = queue.pop_front()

		if current.LOCATION == END:
			PATH.append(current.LOCATION)
			while current.LOCATION != START:
				print("current: ", current)
				print("start: ", START)
				print("end: ", END)
				print("PATH: ", PATH)
				current = current.PARENT
				print("new current: ", current)
				# current = parent_dict[current]
				PATH.append(current.LOCATION)
			return PATH
		for neighbor in get_neighbors(current.LOCATION):
			if neighbor in visited:
				continue
			# check if neighbor is in queue
			# if it is in queue, check if current is a better parent than its PARENT
			var found_match:bool = false
			for q:PathNode in queue:
				if q.LOCATION == neighbor:
					found_match = true
					q.update_parent(current)
			if !found_match:
				var new_node:PathNode = PathNode.new(neighbor, END, current)
				queue.append(new_node)

			visited.append(neighbor)
			
			# parent_dict[neighbor] = current
	push_error("pathfind fail")
	print("pathfind fail")
	return []




func find_path_breadth_first() -> Array[Vector2]:
	# print("PATHFINDING CHECK")
	if START == END:
		print("PAthfinding: START and END are same location")
		push_error("Pathfinding: START and END are same location")
		return []
	
	var queue: Array[Vector2] = [START]
	var visited: Array[Vector2] = [START]
	var parent_dict: Dictionary = {}

	var current: Vector2

	while len(queue) > 0:
		# print("queueuee: ", queue)
		current = queue.pop_front()
		if current == END:
			PATH.append(current)
			while current != START:
				current = parent_dict[current]
				PATH.append(current)
			return PATH
		for neighbor in get_neighbors(current):
			if neighbor in visited:
				continue
			visited.append(neighbor)
			queue.append(neighbor)
			parent_dict[neighbor] = current
	push_error("pathfind fail")
	print("pathfind fail")
	return []

func length() -> int:
	return len(PATH)

func get_neighbors(loc:Vector2) -> Array[Vector2]:
	# print("getting neighbors of: ", loc)
	var tile_filter:TILE_FILTER = TILE_FILTER.new(ENGINE).set_list().in_range_of(loc,1.5).is_passable()
	tile_filter.run_filter()
	var loc_list:Array[Vector2] = tile_filter.convert_to_loc()
	# print("neighbors: ", loc_list)
	return loc_list

func validate() -> bool:
	# checks if each step is still passable
	if len(PATH) == 0: return false
	var tile_list:Array[TILE] = TILE_FILTER.new(ENGINE).set_list_from_vector(PATH).run_filter()
	if len(tile_list) == len(PATH):
		return true
	return false


func validate_from_npc(npc:NPC) -> bool:
	# print("validation")
	if len(PATH) == 0: return false
	var visible_tiles:Array[TILE] = TILE_FILTER.new(ENGINE).set_list_from_vector(PATH).in_range_of(npc.LOCATION, 10).in_arc_of(npc.DIRECTION).run_filter()
	var passable_tiles:Array[TILE] = TILE_FILTER.new(ENGINE).set_list(visible_tiles).in_range_of(npc.LOCATION, 10).is_passable().run_filter()
	# print("visible tiles: ", visible_tiles)
	# print("passable: ", passable_tiles)
	if len(visible_tiles) == len(passable_tiles):
		return true
	return false


func next_step() -> Vector2:
	if len(PATH) > 0:
		return PATH.pop_back()
	else:
		return Vector2.INF

func _to_string() -> String:
	var str_list:Array[String] = [
		"Start: ",
		ENGINE.prettify_vector(START),
		", End: ",
		ENGINE.prettify_vector(END),
		". PATH: ",
		str(PATH)
	]
	return "".join(str_list)
