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
	print("running filter")
	filtered_list = []
	for recipe_name:String in RECIPE_LIST.keys():
		var recipe:Dictionary = RECIPE_LIST[recipe_name]
		
		if CRAFTING_TYPE != "":
			if recipe["crafting_type"] != CRAFTING_TYPE: continue

		

		if NAME != "":
			if recipe_name != NAME: continue

		filtered_list.append(recipe)
	
	return filtered_list


func populate_journal(menu, engine, _subentry) -> void:
	menu.update_title("Recipes")

	run_filter()

	# if len(filtered_list) == 0:
	# 	run_filter()

	for r:Dictionary in filtered_list:
		var new_recipe:RECIPE = RECIPE.new(ENGINE, ENGINE.get_node("Player"), r["name"])
		# var display_recipe:RichTextLabel = new_recipe.create_display()
		var display:Wiki = new_recipe.to_wiki()
		menu.add_to_entry(display)
		display.finalize()

		# var display_recipe:RichTextLabel = new_recipe.create_display()
		# menu.add_to_entry(display_recipe)

		if new_recipe.CRAFTABLE:
			var craft_button:Button = Button.new()
			craft_button.text = new_recipe.DATA["verb"].capitalize() + " " + r["name"].capitalize()
			craft_button.connect("pressed", craft_recipe.bind(new_recipe))
			menu.bind_button_to_update(craft_button)
			#print("connected functions: ", craft_button.get_signal_connection_list())
			menu.add_to_entry(craft_button)


func craft_recipe(recipe:RECIPE) -> void:
	if !recipe.CRAFTABLE: return

	recipe.craft()
