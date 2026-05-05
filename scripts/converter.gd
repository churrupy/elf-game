class_name CONVERTER extends RefCounted

var ENGINE

var conversion_list:Array
var convert_from:String
var convert_to:String

var converstion_dict: Dictionary = {
    "npc" : [
        "location",
        "name",
        "current_action",
        "reserved_location",
        "inventory",
        "closest_adjacent",
    ],
    "location": [
        "all",
        "npcs",
        "tiles"
    ],
}

func _init(engine) -> void:
    ENGINE = engine


func set_list(list:Array) -> CONVERTER:
    conversion_list = list
    return self

func set_types(_convert_from:String, _convert_to:String) -> CONVERTER:
    convert_from = _convert_from
    convert_to = _convert_to
    return self


func run() -> Array:
    if convert_to == "location":
        return get_location()
    
    if convert_to == "name":
        return get_name()

    if convert_from == "npc":
        if convert_to == "current_action":
            return get_npc_actions()

        if convert_to = "reserved_location":
            return get_npc_reserved_loc()


#region general
func get_name() -> Array:
    var result_list: Array
    for item:Node in conversion_list:
        result_list.append(item.NAME)
    return result_list

func get_location() -> Array:
    var result_list: Array
    for item:Node in conversion_list:
        result_list.append(item.LOCATION)
    return result_list

#endregion general

#region npc
func get_npc_actions() -> Array:
    var result_list: Array
    for npc:NPC in conversion_list:
        var current_action: ACTION = npc.STATE_STACK.back()
        result_list.append(current_action)
    return result_list

func get_npc_reserved_loc() -> Array:
    var result_list: Array
    for npc:NPC in conversion_list:
        var current_action:ACTION = npc.STATE_STACK.back()
        result_list.append(current_action.LOCATION)
    return result_list

#endregion npc