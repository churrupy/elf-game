class_name DOOR extends TILE

var OPEN_TEXTURE:String
var CLOSED_TEXTURE:String
var opened: bool = true
var wall:String

var directions:Dictionary = {
	"up": ["left", "top"],
	"down": ["right", "top"],
	"left": ["top" ,"left"],
	"right": ["bottom", "right"]
}

func _init(loc:Vector2, tile:TILE, _wall:String) -> void:
	ID = tile.ID
	NAME = tile.NAME + " " + str(LOCATION)
	TYPE = "door"
	LOCATION = loc
	DATA = Constants.TILE_TEMPLATES["door"]
	FLOOR = TextureRect.new()
	add_child(FLOOR)
	FURNITURE = TextureRect.new()
	add_child(FURNITURE)
	add_loc_label()

	wall = _wall
	var dir:Array = directions[wall]
	OPEN_TEXTURE = "res://models/doors/door_" + dir[0] + ".png"
	CLOSED_TEXTURE = "res://models/doors/door_" + dir[1] + ".png"
	open()
	
	


func open() -> void:
	FURNITURE.texture = load(OPEN_TEXTURE)
	opened = true

func close() -> void:
	FURNITURE.texture = load(CLOSED_TEXTURE)
	opened = false

