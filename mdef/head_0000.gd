# head_0000.gd
extends RefCounted

const PREFIX := "head_0000_"

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
	# PAS1 _crpa3941
	var brro3941_0 := _crpa("brro3941")
	Opfu.pla(brro3941_0, Vector3.ZERO, y0)
	
	# 脖子和头部底座
	var brro3941_1 := _crpa("brro3941")
	var brro3941_2 := _crpa("brro3941")
	var br3001_0 := _crpa("br3001")
	Opfu.stco(brro3941_1, brro3941_0, y0, 0, 0)
	Opfu.stco(brro3941_2, brro3941_1, y0, 0, 0)
	Opfu.stco(br3001_0, brro3941_2, y0, 2, 0)
	#br3001 Y- 0 2 4 6

	# 侧脸底座	
	var brmo22885_1 := _crpa("brmo22885")
	var brmo22885_0 := _crpa("brmo22885")
	#left
	Opfu.skco(brmo22885_0, br3001_0, y90, 0, 7)
	#22885_0 X- 3 5up
	#right
	Opfu.skco(brmo22885_1, br3001_0, y270, 0, 0) 
	#22885_1 X- 5 3up

	# 侧脸
	var slcu88930_0 := _crpa("slcu88930")
	var slcu88930_1 := _crpa("slcu88930")
	var brmo22885_2 := _crpa("brmo22885")
	var brmo22885_3 := _crpa("brmo22885")
	#left
	Opfu.stco(slcu88930_0, brmo22885_0, y90*x90, 6, 5) 
	#right
	Opfu.stco(slcu88930_1, brmo22885_1, y270*x90, 0, 3) 
	#left		
	Opfu.skco(brmo22885_2, slcu88930_0, y90, 3, 0) 
	#right
	Opfu.skco(brmo22885_3, slcu88930_1, y270, 3, 4) 	

	#中脸
	var br3004_0 := _crpa("br3004")
	var br2357_0 := _crpa("br2357")	
	var br3245b_0 := _crpa("br3245b")
	var br3004_1 := _crpa("br3004")
	var br2357_1 := _crpa("br2357")
	var br3245b_1 := _crpa("br3245b")
	#left
	Opfu.stco(br2357_0, brmo22885_2, y270, 1, 1)
	#br2357_0 view Y- 1 0up
	Opfu.stco(br3004_0, br2357_0, y270, 0, 0)
	#3004_0 view Y- 0 up	
	Opfu.stco(br3245b_0, brmo22885_2, y0, 1, 0)	
	#right
	Opfu.stco(br2357_1, brmo22885_3, y0, 2, 0)
	Opfu.stco(br3004_1, br2357_1, y270, 0, 0)
	Opfu.stco(br3245b_1, brmo22885_3, y0, 0, 1)

	#下巴
	var br3245b_2 := _crpa("br3245b")
	var slcu32803_0 := _crpa("slcu32803")
	var slcu32803_1 := _crpa("slcu32803")
	#left
	Opfu.skco(br3245b_2, br3245b_0, y0, 1, 0)
	#right
	Opfu.skco(slcu32803_0, br3245b_2, y90, 0, 1)
	#mid
	Opfu.skco(slcu32803_1, br3245b_2, y270, 1, 0)

	# Forehead
	var br3009_0 := _crpa("br3009")
	var br2456_0 := _crpa("br2456")
	Opfu.stco(br3009_0, br3004_1, y0, 0, 1)
	Opfu.stco(br2456_0, br3004_1, y0, 1, 0)	

	# Ears
	var brmo22885_4 := _crpa("brmo22885")
	var brmo22885_5 := _crpa("brmo22885")
	var pl3023_0 := _crpa("pl3023")
	var pl3023_1 := _crpa("pl3023")
	var pl3023_2 := _crpa("pl3023")
	var pl3023_3 := _crpa("pl3023")
	var slcu15068_0 := _crpa("slcu15068")
	var slcu15068_1 := _crpa("slcu15068")
	#left 
	Opfu.skco(pl3023_0, br2456_0, y270, 1, 10)
	Opfu.skco(brmo22885_4, pl3023_0, y90, 0, 1)
	Opfu.stco(pl3023_2, brmo22885_4, y90*x90, 0, 3)
	Opfu.stco(slcu15068_0, pl3023_2, y90*x90, 0, 0)
	#right 
	Opfu.skco(pl3023_1, br2456_0, y270, 1, 0)
	Opfu.skco(brmo22885_5, pl3023_1, y270, 0, 0)
	Opfu.stco(pl3023_3, brmo22885_5, y270*x90, 0, 3)
	Opfu.stco(slcu15068_1, pl3023_3, y270*x90, 0, 0)

	# back head
	var br2456_1 := _crpa("br2456")
	var br3004_2 := _crpa("br3004")
	var br3004_3 := _crpa("br3004")
	var slin3665_0 := _crpa("slin3665")
	var slin3665_1 := _crpa("slin3665")
	var pl3020_0 := _crpa("pl3020")
	var pl3020_1 := _crpa("pl3020")
	Opfu.stco(br2456_1, pl3023_1, y0, 1, 0)
	#br2456_1 2x6
	#left
	Opfu.skco(br3004_2, br2456_1, y90, 0, 10)
	Opfu.skco(slin3665_0, br3004_2, y180, 0, 0)
	#right
	Opfu.skco(br3004_3, br2456_1, y90, 0, 0)
	Opfu.skco(slin3665_1, br3004_3, y180, 0, 0)
	#mid
	Opfu.skco(pl3020_0, br2456_1, y0, 1, 2)
	Opfu.skco(pl3020_1, pl3020_0, y0, 0, 0)	

	# back head 2
	var slin2449_0 := _crpa("slin2449")
	var slin2449_1 := _crpa("slin2449")
	var slin2449_2 := _crpa("slin2449")
	var slin2449_3 := _crpa("slin2449")
	var pl3623_0 := _crpa("pl3623")
	var pl3623_1 := _crpa("pl3623")
	var pl3023_4 := _crpa("pl3023")
	var br3009_1 := _crpa("br3009")	
	Opfu.skco(slin2449_0, pl3020_1, y180, 0, 7)
	Opfu.skco(slin2449_1, pl3020_1, y180, 0, 5)
	Opfu.skco(slin2449_2, pl3020_1, y180, 0, 3)
	Opfu.skco(slin2449_3, pl3020_1, y180, 0, 1)
	Opfu.skco(pl3623_0, slin2449_0, y270, 0, 0)
	Opfu.skco(pl3623_1, slin2449_3, y270, 0, 0)
	Opfu.skco(pl3023_4, slin2449_2, y0, 0, 0)
	Opfu.stco(br3009_1, br3004_3, y0, 0, 1)	

	# Top
	var slcu6215_0 := _crpa("slcu6215")
	var slcu6215_1 := _crpa("slcu6215")
	var slcu6215_2 := _crpa("slcu6215")
	var pl3795_0 := _crpa("pl3795")
	var pl3795_1 := _crpa("pl3795")
	var pl3666_0 := _crpa("pl3666")
	var pl3666_1 := _crpa("pl3666")
	var slcu15068_2 := _crpa("slcu15068")
	var slcu15068_3 := _crpa("slcu15068")
	var slcu15068_4 := _crpa("slcu15068")
	Opfu.stco(slcu6215_0, br3009_0, y0, 2, 0)
	Opfu.stco(slcu6215_1, br3009_0, y0, 2, 2)
	Opfu.stco(slcu6215_2, br3009_0, y0, 2, 4)
	Opfu.stco(pl3795_0, br2456_1, y0, 0, 0)
	Opfu.stco(pl3795_1, pl3795_0, y0, 0, 0)
	Opfu.stco(pl3666_0, pl3795_1, y0, 0, 1)
	Opfu.stco(pl3666_1, br3009_1, y0, 0, 0)
	Opfu.stco(slcu15068_2, pl3795_1, y180, 0, 10)
	Opfu.stco(slcu15068_3, pl3795_1, y180, 0, 6)
	Opfu.stco(slcu15068_4, pl3795_1, y180, 0, 2)

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
		# 0 脖子
		{ "part": PREFIX + "brro3941_0", "type": "holes", "index": 1 },
	]
