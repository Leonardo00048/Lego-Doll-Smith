# technique_brick_constructor.gd
extends Resource
class_name TechniqueBrickConstructor

## 获取指定零件的连接点数据
## @param part_name: 零件名称 (如 "3700", "57909")
func get_connection_data(part_name: String) -> Dictionary:
	var result := {
		"sockets": [],
		"studs": [],
		"holes": [],
		"ball_joints": [],
		"ball_sockets": [],
	}
	
	match part_name:
		# === 3700: 2x1 Brick, h=3, Z向圆孔 ===
		"3700":
			# 顶凸点 & Socket (2x1, h=3)
			for x in range(1, 3):
				var pos_top := Vector3(20.0*x - 10.0, 24.0, 10.0)
				result["studs"].append({"pos": pos_top, "dir": "Y_POS"})
				result["sockets"].append({"pos": Vector3(pos_top.x, 0.0, pos_top.z), "dir": "Y_POS"})
			
			# 圆孔 Pin Hole (Z轴贯穿)
			result["holes"] = [
				{"pos": Vector3(20.0, 14.0, 0.0), "dir": "Z_AXIS"},
				{"pos": Vector3(20.0, 14.0, 20.0), "dir": "Z_AXIS"}
			]

		# === 57909: 2x2 Brick, h=3, X+球关节 + Y向十字轴孔 ===
		"57909b":
			# 顶凸点 & Socket (2x2, h=3)
			for x in range(1, 3):
				for z in range(1, 3):
					var pos_top := Vector3(20.0*x - 10.0, 24.0, 20.0*z - 10.0)
					result["studs"].append({"pos": pos_top, "dir": "Y_POS"})
					result["sockets"].append({"pos": Vector3(pos_top.x, 0.0, pos_top.z), "dir": "Y_POS"})
			
			# 球关节 Ball Joint (X+面)
			result["ball_joints"] = [
				{"pos": Vector3(60.0, 12.0, 20.0), "dir": "X_POS"}
			]
			
			# 十字轴孔 Axle Hole (Y轴贯穿)
			result["holes"] = [
				{"pos": Vector3(20.0, 0.0, 20.0), "dir": "Y_AXIS"},
				{"pos": Vector3(20.0, 24.0, 20.0), "dir": "Y_AXIS"}
			]

		# === 67696: 2x2 Brick, h=3, X+球关节窝 + Y向十字轴孔 ===
		"67696":
			# 顶凸点 & Socket (2x2, h=3)
			for x in range(1, 3):
				for z in range(1, 3):
					var pos_top := Vector3(20.0*x - 10.0, 24.0, 20.0*z - 10.0)
					result["studs"].append({"pos": pos_top, "dir": "Y_POS"})
					result["sockets"].append({"pos": Vector3(pos_top.x, 0.0, pos_top.z), "dir": "Y_POS"})
			
			# 球关节 Ball Joint (X+面)
			result["ball_sockets"] = [
				{"pos": Vector3(60.0, 12.0, 20.0), "dir": "X_POS"}
			]
			
			# 十字轴孔 Axle Hole (Y轴贯穿)
			result["holes"] = [
				{"pos": Vector3(20.0, 0.0, 20.0), "dir": "Y_AXIS"},
				{"pos": Vector3(20.0, 24.0, 20.0), "dir": "Y_AXIS"}
			]
		_:
			push_error("未找到Technique,Brick零件: %s" % part_name)
			return result
	
	return result
