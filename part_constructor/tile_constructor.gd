# tile_constructor.gd
extends Resource
class_name TileConstructor

## 获取指定 tile 零件的连接点数据
## @param part_name: 零件编号 (如 "2431", "69729", "87079")
func get_connection_data(part_name: String) -> Dictionary:
	var result := {
		"studs": [],      # ✅ tile 无 Studs，强制返回空数组
		"sockets": []
	}
	
	match part_name:
		# === 2431: tile 4x1 ===
		# x: 1-4, z: 1-1 | Socket: (20x-10, 0, 20z-10)
		"2431":
			for x in range(1, 5):
				for z in range(1, 2):
					result["sockets"].append({"pos": Vector3(20.0*x - 10.0, 0.0, 20.0*z - 10.0)})
		
		# === 69729: tile 6x2 ===
		# x: 1-6, z: 1-2 | Socket: (20x-10, 0, 20z-10)
		"69729":
			for x in range(1, 7):
				for z in range(1, 3):
					result["sockets"].append({"pos": Vector3(20.0*x - 10.0, 0.0, 20.0*z - 10.0)})
		
		# === 87079: tile 4x2 ===
		# x: 1-4, z: 1-2 | Socket: (20x-10, 0, 20z-10)
		"87079":
			for x in range(1, 5):
				for z in range(1, 3):
					result["sockets"].append({"pos": Vector3(20.0*x - 10.0, 0.0, 20.0*z - 10.0)})
		
		_:
			push_error("tileConstructor: 未找到零件 '%s'" % part_name)
			return result
	
	return result
