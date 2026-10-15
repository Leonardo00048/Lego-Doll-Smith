# lower_arm_right_0000.gd
extends RefCounted

const PREFIX := "lower_arm_right_0000_"

var _local_counter: Dictionary = {}

var y0 = Quaternion(Vector3.UP, deg_to_rad(0.0))
var y270 = Quaternion(Vector3.UP, deg_to_rad(-90.0))
var x270 = Quaternion(Vector3.RIGHT, deg_to_rad(-90.0))
var y90 = Quaternion(Vector3.UP, deg_to_rad(90.0))
var x90 = Quaternion(Vector3.RIGHT, deg_to_rad(90.0))
var y180 = Quaternion(Vector3.UP, deg_to_rad(180.0))
var z90 = Quaternion(Vector3.FORWARD, deg_to_rad(90.0))
var z270 = Quaternion(Vector3.FORWARD, deg_to_rad(270.0))

func build(parent: Node3D) -> Node3D:
	var pl3020_0 := _crpa("pl3020")
	Opfu.pla(pl3020_0, Vector3.ZERO, y270*x90*y270)

	var tebr67696_0 := _crpa("tebr67696")
	Opfu.stco(tebr67696_0, pl3020_0, y270*x90*y90, 0, 3) 

	var br3004_0 := _crpa("br3004")
	var pl3023_0 := _crpa("pl3023")
	var pl3023_1 := _crpa("pl3023")
	var plmo14417_0 := _crpa("plmo14417")
	Opfu.stco(br3004_0, pl3020_0, y270*x90, 0, 5)
	Opfu.stco(pl3023_0, pl3020_0, y270*x90, 0, 7)
	Opfu.stco(pl3023_1, pl3023_0, y270*x90, 0, 0)
	Opfu.stco(plmo14417_0, pl3023_1, y270*x90, 0, 0)

	var ti87079_0 := _crpa("ti87079")
	Opfu.stco(ti87079_0, plmo14417_0, y270*x90*y270, 7, 0)

	return parent

func _crpa(part_name: String) -> String:
	if not _local_counter.has(part_name):
		_local_counter[part_name] = 0
	var seq: int = _local_counter[part_name]
	_local_counter[part_name] += 1

	var local_name := "%s_%d" % [part_name, seq]
	var full_name := PREFIX + local_name

	Opfu.crpa(part_name, full_name)
	return full_name

func get_inpo() -> Array:
	return [
		# 0 上关节窝
		{ "part": PREFIX + "tebr67696_0", "type": "ball_sockets", "index": 0 },	
		# 1 下球关节
		{ "part": PREFIX + "plmo14417_0", "type": "ball_joints", "index": 0 },

	]
