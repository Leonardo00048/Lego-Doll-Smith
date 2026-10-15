# brick_round_constructor.gd
extends Resource
class_name BrickRoundConstructor

## 获取指定 Brick, Round 零件的连接点数据
## @param part_name: 零件编号 (如 "3941")
func get_connection_data(part_name: String) -> Dictionary:
	var result := {
		"studs": [],
		"sockets": [],
		"holes": []          # ✅ Y轴贯穿孔专用Key
	}
	
	match part_name:
		# === 3941: Brick, Round 2x2 ===
		# Studs/Sockets: 与标准2x2 Brick完全相同 (h=3)
		# Holes: Y轴贯穿，基准面 (20,0,20) & (20,24,20)
		"3941":
			for x in range(1, 3):
				for z in range(1, 3):
					result["studs"].append({"pos": Vector3(20.0*x - 10.0, 24.0, 20.0*z - 10.0)})
					result["sockets"].append({"pos": Vector3(20.0*x - 10.0, 0.0, 20.0*z - 10.0)})
			
			# ✅ Y轴贯穿孔：按Y升序排列，idx0=底部入口，idx1=顶部出口
			result["holes"] = [
				{"pos": Vector3(20.0, 0.0, 20.0)},    # hole[0]: Y=0 基准面
				{"pos": Vector3(20.0, 24.0, 20.0)}    # hole[1]: Y=24 基准面
			]
		
		_:
			push_error("BrickRoundConstructor: 未找到零件 '%s'" % part_name)
			return result
	
	return result
