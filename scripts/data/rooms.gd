extends Node

var ROOM_TEMPLATES: Dictionary = {

"club": {
	"size": Vector2(11,10),
	"furniture":
		{
			"counter": [
				[Vector2(0,8), Vector2(4,8)]
			],
			"dance_floor": [
				[Vector2(2,2), Vector2(5,5)]
			],
			"table": [
				[Vector2(0,2), Vector2(0,2)],
				[Vector2(0,4), Vector2(0,4)],
				[Vector2(0,6), Vector2(0,6)]
			],
			"toilet": [
				[Vector2(10,0), Vector2(10,0)],
				[Vector2(10,2), Vector2(10,2)],
				[Vector2(10,4), Vector2(10,4)],
				[Vector2(10,6), Vector2(10,6)]
			],
			"wall": [
				[Vector2(7,0), Vector2(7,7)],
				[Vector2(9,1), Vector2(10,1)],
				[Vector2(9,3), Vector2(10,3)],
				[Vector2(9,5), Vector2(10,5)],
				[Vector2(9,7), Vector2(10,7)],
			]
		}
}

}

var TILES_TEMPLATES: Dictionary = {
"club": {
		"default": "empty",
		"size": [3,3],
		"special": {
			# bar
			[0,8]: "bar",
			[1,8]: "bar",
			[2,8]: "bar",
			[3,8]: "bar",
			[4,8]: "bar",

			#tables
			[0,2]: "table",
			[0,4]: "table",
			[0,6]: "table",
			
			[2,2]: "dance_floor",
			[2,3]: "dance_floor",
			[2,4]: "dance_floor",
			[2,5]: "dance_floor",

			[3,2]: "dance_floor",
			[3,3]: "dance_floor",
			[3,4]: "dance_floor",
			[3,5]: "dance_floor",

			[4,2]: "dance_floor",
			[4,3]: "dance_floor",
			[4,4]: "dance_floor",
			[4,5]: "dance_floor",

			[5,2]: "dance_floor",
			[5,3]: "dance_floor",
			[5,4]: "dance_floor",
			[5,5]: "dance_floor",

			#divider wall
			[7,0]: "wall",
			[7,1]: "wall",
			[7,2]: "wall",
			[7,3]: "wall",
			[7,4]: "wall",
			[7,5]: "wall",
			[7,6]: "wall",
			[7,7]: "wall",



			#toilets and stalls
			[10,0]: "toilet",
			[9,1]: "wall",
			[10,1]: "wall",

			[10,2]: "toilet",
			[9,3]: "wall",
			[10,3]: "wall",

			[10,4]: "toilet",			
			[9,5]: "wall",
			[10,5]: "wall",

			[10,6]: "toilet",
			[9,7]: "wall",
			[10,7]: "wall"
		},
		"ascii": '''
[S][S][S][S]
[S][D][D][B]
[S][D][D][B]
[S][S][B][B]
	'''
	}

}