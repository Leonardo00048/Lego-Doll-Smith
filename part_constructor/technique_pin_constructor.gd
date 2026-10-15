# technique_pin_constructor.gd
extends Resource
class_name TechniquePinConstructor

## 获取指定销类零件的连接点数据
## @param part_name: 零件编号 (如 "32556")
func get_connection_data(part_name: String) -> Dictionary:
	var result := {
		"sockets": [],
		"studs": [],
		"holes": [],
		"tips": [],        # ✅ 销端面专用数组
		"ball_joints": []
	}
	
	match part_name:
		# === 32556: Technic, Pin 3L ===
		# 长度: 3L = 60 LDU | 走向: Y轴 | 起点: (10, 0, 10)
		"32556":
			result["tips"] = [
				{"pos": Vector3(10.0, 0.0, 10.0)},   # tip[0]: 底部端面 (绝对起点)
				{"pos": Vector3(10.0, 60.0, 10.0)}   # tip[1]: 顶部端面 (非对称累加)
			]
		
		_:
			push_error("TepiConstructor: 未找到销类零件 '%s'" % part_name)
			return result
	
	return result
