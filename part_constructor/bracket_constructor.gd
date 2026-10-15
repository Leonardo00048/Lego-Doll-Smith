# bk_constructor.gd
extends Resource
class_name BracketConstructor

## 获取指定 Bracket 零件的连接点数据
## @param part_name: 零件编号 (如 "44728")
func get_connection_data(part_name: String) -> Dictionary:
	var result := {
		"studs": [],
		"sockets": []
	}
	
	match part_name:
		# === 44728: Plate, Modified 2x2 with Bracket ===
		# 顶 Studs: x=1-2, z=1 | (20x-10, 8, 10) → idx 0, 1
		# 侧 Studs: x=1-2, z=1-2 | (20x-10, 20z-10, 24) → idx 2, 3, 4, 5
		# Sockets: 仅顶部 | (20x-10, 0, 10) → idx 0, 1
		"44728":
			# 1. 顶部 Studs (idx 0, 1)
			for x in range(1, 3):
				result["studs"].append({"pos": Vector3(20.0*x - 10.0, 40.0, 10.0)})
			
			# 2. ✅ 侧面 Studs (idx 2, 3, 4, 5) - Z+方向, Y/Z平面分布
			#    遍历顺序: 先X后Z，确保与坐标描述一致
			for x in range(1, 3):
				for y in range(1, 3):
					result["studs"].append({"pos": Vector3(20.0*x - 10.0, 20.0*y - 10.0, 24.0)})
			
			# 3. 底部 Sockets (仅顶部有连接点, idx 0, 1)
			for x in range(1, 3):
				result["sockets"].append({"pos": Vector3(20.0*x - 10.0, 32.0, 10.0)})
		
		_:
			push_error("BracketConstructor: 未找到零件 '%s'" % part_name)
			return result
	
	return result
