# hips_0000.gd
extends RefCounted

const PREFIX := "hips_0000_"

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
	# 后层
	var pl3795_0 := _crpa("pl3795")
	var pl3795_1 := _crpa("pl3795")
	Opfu.pla(pl3795_0, Vector3.ZERO, x90 * y180)
	Opfu.stco(pl3795_1, pl3795_0, x90 * y180, 0, 0)

	# 夹层 球关节和孔
	var tebr3700_0 := _crpa("tebr3700")
	var br3004_0 := _crpa("br3004")
	var tebr57909b_0 := _crpa("tebr57909b")
	var tebr57909b_1 := _crpa("tebr57909b")
	Opfu.stco(tebr3700_0, pl3795_0, x90, 0, 7)
	Opfu.stco(br3004_0, pl3795_0, x90, 0, 6)
	Opfu.stco(tebr57909b_0, pl3795_0, x90 * y270, 0, 1)
	Opfu.stco(tebr57909b_1, pl3795_0, x90 * y270, 0, 9)

	# 正面  盖板
	var pl3795_2 := _crpa("pl3795")
	var pl3795_3 := _crpa("pl3795")
	Opfu.stco(pl3795_2, tebr57909b_1, x90 * y180, 11, 1)
	Opfu.stco(pl3795_3, pl3795_2, x90 * y180, 0, 0)

	# pin
	var tepi32556_0 := _crpa("tepi32556")
	Opfu.pnin(tepi32556_0, tebr3700_0, y0, 0, 1)
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

func get_anchor() -> Dictionary:
	return {
		"part": PREFIX + "br3004_0",
		"point": Vector3(20, 0, 20),
	}

func get_inpo() -> Array:
	return [
		# 0 左髋关节
		{ "part": PREFIX + "tebr57909b_0", "type": "ball_joints", "index": 0 },
		# 1 右髋关节
		{ "part": PREFIX + "tebr57909b_1", "type": "ball_joints", "index": 0 },
		# 2 上方轴 用于连接torso
		{ "part": PREFIX + "tepi32556_0", "type": "tips", "index": 1 },
	]