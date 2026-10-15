# hand_left_0000.gd
extends RefCounted

const PREFIX := "hand_left_0000_"

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
	var plmo14704_0 := _crpa("plmo14704")
	Opfu.pla(plmo14704_0, Vector3.ZERO, y90*x90*y180)

	var pl3023_0 := _crpa("pl3023")
	var pl2420_0 := _crpa("pl2420")
	Opfu.skco(pl3023_0, plmo14704_0, y90*x90*y90, 1, 0)
	Opfu.skco(pl2420_0, plmo14704_0, y90*x90*y270, 0, 1)

	var slcu15068_0 := _crpa("slcu15068")
	var slcu11477_0 := _crpa("slcu11477")
	Opfu.stco(slcu15068_0, pl3023_0, y90*x90, 1, 0)
	Opfu.stco(slcu11477_0, pl2420_0, y90*x90, 0, 1)

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
		# 0 关节窝
		{ "part": PREFIX + "plmo14704_0", "type": "ball_sockets", "index": 0 },	

	]
