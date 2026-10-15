# plate_constructor.gd
extends Resource
class_name PlateConstructor

## 获取指定零件的连接点数据
## @param part_name: 零件名称 (如 "3024", "3031")
func get_connection_data(part_name: String) -> Dictionary:
	# === 1. 定义 Plate 特有参数表 (仅读取Excel A~C列) ===
	var params := {
		"3024":  {"gx": 1, "gz": 1},
		"3023":  {"gx": 2, "gz": 1},
		"3623":  {"gx": 3, "gz": 1},
		"3710":  {"gx": 4, "gz": 1},
		"78329": {"gx": 5, "gz": 1},
		"3666":  {"gx": 6, "gz": 1},
		"3022":  {"gx": 2, "gz": 2},
		"2420":  {"gx": 2, "gz": 2},   # cn1, 可用点位由外部索引保证
		"3021":  {"gx": 3, "gz": 2},
		"3020":  {"gx": 4, "gz": 2},
		"3795":  {"gx": 6, "gz": 2},
		"77844": {"gx": 3, "gz": 3},   # cn1, 可用点位由外部索引保证
		"11212": {"gx": 3, "gz": 3},
		"3031":  {"gx": 4, "gz": 4},   # 基础件，纳入Plate构造
		"2639":  {"gx": 4, "gz": 4},   # cn2, 可用点位由外部索引保证
		"3032":  {"gx": 6, "gz": 4},
		"3035":  {"gx": 8, "gz": 4},
		"3030":  {"gx": 10, "gz": 4}
	}
	
	if not params.has(part_name):
		push_error("未找到Plate零件参数: %s" % part_name)
		return {"sockets": [], "studs": []}
	
	var p = params[part_name]
	var sockets := []
	var studs := []
	
	# === 2. 通用公式硬编码 ===
	# Stud Y 统一固定为 8 LDU
	var stud_y := 8.0
	
	# 遍历顺序: X优先递增 → Z递增 (0-based索引)
	for x in range(1, p.gx + 1):
		for z in range(1, p.gz + 1):
			# Socket: (20x-10, 0, 20z-10)
			sockets.append({
				"pos": Vector3(20.0 * x - 10.0, 0.0, 20.0 * z - 10.0),
				"dir": "Y_POS"
			})
			
			# Stud: (20x-10, 8, 20z-10)
			studs.append({
				"pos": Vector3(20.0 * x - 10.0, stud_y, 20.0 * z - 10.0),
				"dir": "Y_POS"
			})
	
	return {"sockets": sockets, "studs": studs}
