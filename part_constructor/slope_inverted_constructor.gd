# slope_inverted_constructor.gd
extends Resource
class_name SlopeInvertedConstructor

## 获取指定 Slope Inverted 零件的连接点数据
## @param part_name: 零件编号 (如 "3665", "2449")
func get_connection_data(part_name: String) -> Dictionary:
	var result := {
		"studs": [],
		"sockets": []
	}
	
	match part_name:
		# === 3665: Slope Inverted 2x1 ===
		# Studs: z: 1-2, (10, 24, 20z-10)
		# Sockets: (10, 0, 10) [单点]
		"3665":
			for z in range(1, 3):
				result["studs"].append({"pos": Vector3(10.0, 24.0, 20.0*z - 10.0)})
			result["sockets"].append({"pos": Vector3(10.0, 0.0, 10.0)})
		
		# === 2449: Slope Inverted 2x2 w/ Side Holes ===
		# Studs: z: 1-2, (10, 72, 20z-10)
		# Bottom Sockets: z: 1-1, (10, 0, 10)
		# Side Sockets: y: 1-3, (10, 20y+2, 0) → Y=22, 42, 62
		"2449":
			for z in range(1, 3):
				result["studs"].append({"pos": Vector3(10.0, 72.0, 20.0*z - 10.0)})
			
			# 底部 Socket (仅 z=1)
			result["sockets"].append({"pos": Vector3(10.0, 0.0, 10.0)})
			
			# 侧面 Socket (y: 1-3)
			for y in range(1, 4):
				result["sockets"].append({"pos": Vector3(10.0, 20.0*y + 2.0, 0.0)})
		
		_:
			push_error("SlopeInvertedConstructor: 未找到零件 '%s'" % part_name)
			return result
	
	return result