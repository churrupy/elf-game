class_name INVENTORY extends RefCounted

var OWNER: Node
var ITEMS: Array[ITEM]


func _init(owner:Node) -> void:
    OWNER = owner

