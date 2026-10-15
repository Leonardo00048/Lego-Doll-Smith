# slope_curved_constructor.gd
extends Resource
class_name SlopeCurvedConstructor

## 获取指定 Slope/Curved 零件的连接点数据
## @param part_name: 零件编号 (如 "11477", "15068", "88930", "32803", "6215")
func get_connection_data(part_name: String) -> Dictionary:
	var result := {
		"studs": [],
		"sockets": []
	}
	
	match part_name:
		# === 11477: Slope Curved 2x1 ===
		# Socket分布: 0=(10,8,10), 1=(10,0,30) | No studs
		"11477":
			result["sockets"] = [
				{"pos": Vector3(10.0, 8.0, 10.0)},
				{"pos": Vector3(10.0, 0.0, 30.0)}
			]
		
		# === 15068: Slope Curved 2x2 ===
		# x=1 to 2 | z=1: (20x-10, 8, 10) | z=2: (20x-10, 0, 30) | No studs
		"15068":
			for x in range(1, 3):
				result["sockets"].append({"pos": Vector3(20.0*x - 10.0, 8.0, 10.0)})
			for x in range(1, 3):
				result["sockets"].append({"pos": Vector3(20.0*x - 10.0, 0.0, 30.0)})
		
		# === 88930: Slope Curved 2x4 ===
		# x=1 to 4, z=1 to 2 | (20x-10, 0, 20z-10) | No studs
		"88930":
			for x in range(1, 5):
				for z in range(1, 3):
					result["sockets"].append({"pos": Vector3(20.0*x - 10.0, 0.0, 20.0*z - 10.0)})
		
		# === 32803: Slope Curved 2x2 w/ Studs ===
		# x=1 to 2 | z=1: (20x-10, 8, 10) | z=2: (20x-10, 16, 30) | No sockets
		"32803":
			for x in range(1, 3):
				result["studs"].append({"pos": Vector3(20.0*x - 10.0, 8.0, 10.0)})
			for x in range(1, 3):
				result["studs"].append({"pos": Vector3(20.0*x - 10.0, 16.0, 30.0)})
		
		# === 6215: Slope Brick 2x2 ===
		# Studs: x=1 to 2, z=1 to 2 | (20x-10, 24, 20z-10)
		# Sockets: x=1 to 2, z=1 to 3 | (20x-10, 0, 20z-10)
		"6215":
			for x in range(1, 3):
				for z in range(1, 3):
					result["studs"].append({"pos": Vector3(20.0*x - 10.0, 24.0, 20.0*z - 10.0)})
			for x in range(1, 3):
				for z in range(1, 4):
					result["sockets"].append({"pos": Vector3(20.0*x - 10.0, 0.0, 20.0*z - 10.0)})
		
		_:
			push_error("SlopeCurvedConstructor: 未找到零件 '%s'" % part_name)
			return result
	
	return result