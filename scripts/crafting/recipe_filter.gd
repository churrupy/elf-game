class_name RECIPE_FILTER extends RefCounted



var RECIPE_LIST:Dictionary[String, Dictionary] = {
	"dough": {
		"name": "dough",
		"crafting_type": "cooking",
		"verb": "make",
		"furniture": [
			"h_surface", 
		],
		"tools": [
			"bowl"
		],
		"ingredients": [
			"flour",
			"water"
		]
	},
	"bread": {
		"name": "bread",
		"crafting_type": "cooking",
		"verb": "bake",
		"furniture": [
			"oven"
		],
		"tools": [],
		"ingredients": [
			"dough"
		]
	}
}

var ENGINE

var CRAFTING_TYPE:String = ""
var NAME:String = ""

var filtered_list:Array[Dictionary]

func _init(engine) -> void:
	ENGINE = engine

func set_crafting_type(_type:String) -> RECIPE_FILTER:
	CRAFTING_TYPE = _type
	return self

func set_name(_name:String) -> RECIPE_FILTER:
	NAME = _name
	return self


func run_filter() -> Array[Dictionary]:
	for recipe_name:String in RECIPE_LIST.keys():
		var recipe:Dictionary = RECIPE_LIST[recipe_name]
		
		if CRAFTING_TYPE != "":
			if recipe["crafting_type"] != CRAFTING_TYPE: continue

		

		if NAME != "":
			if recipe_name != NAME: continue

		filtered_list.append(recipe)
	
	return filtered_list