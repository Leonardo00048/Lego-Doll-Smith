# technique_axle_constructor.gd
extends Resource
class_name TechniqueAxleConstructor

## 获取指定轴类零件的连接点数据
## @param part_name: 零件编号 (如 "43093")
func get_connection_data(part_name: String) -> Dictionary:
	var result := {
		"sockets": [],
		"studs": [],
		"hole": [],
		"tip": [],        # ✅ 轴端面专用数组
		"ball_joints": []
	}
	
	match part_name:
		# === 43093: Technic, Axle 2L ===
		# 长度: 2L = 40 LDU | 走向: Y轴 | 起点: (10, 0, 10)
		"43093":
			result["tips"] = [
				{"pos": Vector3(10.0, 0.0, 10.0)},   # tip[0]: 底部端面
				{"pos": Vector3(10.0, 40.0, 10.0)}   # tip[1]: 顶部端面
			]
		
		_:
			push_error("TeaxConstructor: 未找到轴类零件 '%s'" % part_name)
			return result
	
	return result
