# plate_modified_constructor.gd
extends Resource
class_name PlateModifiedConstructor

## 获取指定 Plate, Modified 零件的连接点数据
## @param part_name: 零件编号 (如 "44728", "14704", "14417")
func get_connection_data(part_name: String) -> Dictionary:
	var result := {
		"studs": [],
		"sockets": [],
		"ball_joints": [],      # ✅ 球关节专用Key
		"ball_sockets": []      # ✅ 球关节窝专用Key
	}
	
	match part_name:
		# === 14704: Plate, Modified 2x2 with Ball Socket ===
		# Studs/Sockets: 同标准2x2 Plate | Ball Socket: (20, 4, 5)
		"14704":
			for x in range(1, 3):
				result["studs"].append({"pos": Vector3(20.0*x - 10.0, 8.0, 10.0)})
			for x in range(1, 3):
				result["sockets"].append({"pos": Vector3(20.0*x - 10.0, 0.0, 10.0)})
			result["ball_sockets"] = [
				{"pos": Vector3(20.0, 4.0, 30.0), "dir": "X_POS"}
			]
		
		# === 14417: Plate, Modified 2x2 with Ball Joint ===
		# Studs/Sockets: 同标准2x2 Plate | Ball Joint: (20, 4, 5)
		"14417":
			for x in range(1, 3):
				result["studs"].append({"pos": Vector3(20.0*x - 10.0, 8.0, 10.0)})
			for x in range(1, 3):
				result["sockets"].append({"pos": Vector3(20.0*x - 10.0, 0.0, 10.0)})
			result["ball_joints"] = [
				{"pos": Vector3(20.0, 4.0, 30.0)}   # ✅ 球关节，无方向字段
			]
		
		_:
			push_error("PlmoConstructor: 未找到零件 '%s'" % part_name)
			return result
	
	return result
