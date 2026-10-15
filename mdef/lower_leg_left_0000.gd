# lower_leg_left_0000.gd
extends RefCounted

const PREFIX := "lower_leg_left_0000_"

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
	Opfu.pla(pl3020_0, Vector3.ZERO, x90*y90)

	var tebr57909b_0 := _crpa("tebr57909b")
	var tebr67696_0 := _crpa("tebr67696")
	Opfu.stco(tebr57909b_0, pl3020_0, x90*y90, 0, 4) 
	Opfu.stco(tebr67696_0, pl3020_0, x90*y270, 0, 3) 

	var ti87079_0 := _crpa("ti87079")
	Opfu.stco(ti87079_0, tebr67696_0, x90*y90, 0, 3)

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
		# 0 上球关节
		{ "part": PREFIX + "tebr57909b_0", "type": "ball_joints", "index": 0 },
		# 1 下关节窝
		{ "part": PREFIX + "tebr67696_0", "type": "ball_sockets", "index": 0 },

	]
