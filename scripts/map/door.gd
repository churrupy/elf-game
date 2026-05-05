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
	wall = _wall
	var dir:Array = directions[wall]
	#print(wall)
	OPEN_TEXTURE = "res://models/doors/door_" + dir[0] + ".png"
	CLOSED_TEXTURE = "res://models/doors/door_" + dir[1] + ".png"
	open()
	#print("door")
	#print(texture)
	ID = tile.ID
	NAME = tile.NAME
	LOCATION = loc
	DATA = Constants.FURNITURE["door"]
	add_loc_label()
	#super._init("door", loc)


func open() -> void:
	#print("setting door texture")
	#print(OPEN_TEXTURE)
	#print(CLOSED_TEXTURE)
	texture = load(OPEN_TEXTURE)
	opened = true

func close() -> void:
	texture = load(CLOSED_TEXTURE)
	opened = false
