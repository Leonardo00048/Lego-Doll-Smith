# slope_constructor.gd
extends Resource
class_name SlopeConstructor

## 获取指定 Slope 零件的连接点数据
## @param part_name: 零件编号 (如 "85984", "3039")
func get_connection_data(part_name: String) -> Dictionary:
	var result := {
		"studs": [],
		"sockets": []
	}
	
	match part_name:
		# === 85984: Slope Curved 2x1 ===
		# Sockets: x: 1-2, (20x-10, 0, 10) | No studs
		"85984":
			for x in range(1, 3):
				result["sockets"].append({"pos": Vector3(20.0*x - 10.0, 0.0, 10.0)})
		
		# === 3039: Slope 2x2 ===
		# Studs: x: 1-2, (20x-10, 24, 10)
		# Sockets: x: 1-2, z: 1-2, (20x-10, 0, 20z-10)
		"3039":
			for x in range(1, 3):
				result["studs"].append({"pos": Vector3(20.0*x - 10.0, 24.0, 10.0)})
			for x in range(1, 3):
				for z in range(1, 3):
					result["sockets"].append({"pos": Vector3(20.0*x - 10.0, 0.0, 20.0*z - 10.0)})
		
		_:
			push_error("SlopeConstructor: 未找到零件 '%s'" % part_name)
			return result
	
	return result
