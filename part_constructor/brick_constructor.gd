# brick_constructor.gd
extends Resource
class_name BrickConstructor

## 获取指定零件的连接点数据
## @param part_name: 零件名称 (如 "3005", "3245b")
func get_connection_data(part_name: String) -> Dictionary:
	# === 1. 定义 Brick 特有参数表 (仅读取Excel A~E列) ===
	var params := {
		"3005":  {"gx": 1, "gz": 1, "h": 3},
		"3004":  {"gx": 2, "gz": 1, "h": 3},
		"3245b": {"gx": 2, "gz": 1, "h": 6},  # 视为普通Brick，高度6LU
		"2357":  {"gx": 2, "gz": 2, "h": 3},
		"3622":  {"gx": 3, "gz": 1, "h": 3},
		"3010":  {"gx": 4, "gz": 1, "h": 3},
		"3009":  {"gx": 6, "gz": 1, "h": 3},
		"3003":  {"gx": 2, "gz": 2, "h": 3},
		"3002":  {"gx": 3, "gz": 2, "h": 3},
		"3001":  {"gx": 4, "gz": 2, "h": 3},
		"2456":  {"gx": 6, "gz": 2, "h": 3}
	}
	
	if not params.has(part_name):
		push_error("未找到Brick零件参数: %s" % part_name)
		return {"sockets": [], "studs": []}
	
	var p = params[part_name]

	
	# === 2. 通用公式硬编码 (F列规则) ===
	# Stud Y = 8 * height_lu (新规则)
	var stud_y :float = 8.0 * p.h
	var sockets := []
	var studs := []	
	# 遍历顺序: X优先递增 → Z递增 (0-based索引)
	for x in range(1, p.gx + 1):
		for z in range(1, p.gz + 1):
			# Socket: (20x-10, 0, 20z-10)
			sockets.append({
				"pos": Vector3(20.0 * x - 10.0, 0.0, 20.0 * z - 10.0),
				"dir": "Y_POS"
			})
			
			# Stud: (20x-10, 8*lu, 20z-10)
			studs.append({
				"pos": Vector3(20.0 * x - 10.0, stud_y, 20.0 * z - 10.0),
				"dir": "Y_POS"
			})
	
	return {"sockets": sockets, "studs": studs}
