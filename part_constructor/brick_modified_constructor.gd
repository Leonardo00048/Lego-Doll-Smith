# brick_modified_constructor.gd
extends Resource
class_name BrickModifiedConstructor

## 获取指定零件的连接点数据
## @param part_name: 零件名称 (如 "3700", "22885")
func get_connection_data(part_name: String) -> Dictionary:
	var sockets := []
	var studs := []
	
	match part_name:
		# === 11211: 2x1 Brick, h=3, Z+面有2个侧凸点 ===
		"11211":
			# 顶凸点 (Top Studs): Index 0, 1
			for x in range(1, 3):
				studs.append({"pos": Vector3(20.0*x - 10.0, 24.0, 20.0*x - 10.0), "dir": "Y_POS"}) 
				# ⚠️ 注意：3700是2x1，z固定为1
				studs[-1]["pos"] = Vector3(20.0*x - 10.0, 24.0, 10.0)
			
			# Socket: 与顶凸点同位置，Y=0
			for s in studs:
				sockets.append({"pos": Vector3(s["pos"].x, 0.0, s["pos"].z), "dir": "Y_POS"})
			
			# 侧凸点 (Side Studs): Z+面, Index 2, 3
			# 公式: (20x-10, 12, 20), x∈{1,2}
			for x in range(1, 3):
				studs.append({"pos": Vector3(20.0*x - 10.0, 12.0, 20.0), "dir": "Z_POS"})

		# === 22885: 2x1x2 Brick, h=6, 底面2x1, Z+面有4个侧凸点 ===
		"22885":
			# 顶凸点: Index 0, 1 (仅顶层 y=2)
			for x in range(1, 3):
				studs.append({"pos": Vector3(20.0*x - 10.0, 40.0, 10.0), "dir": "Y_POS"})
			
			# Socket: Y=0
			for s in studs:
				sockets.append({"pos": Vector3(s["pos"].x, 0.0, s["pos"].z), "dir": "Y_POS"})
			
			# 侧凸点: Z+面, y∈{1,2}, Index 2~5
			# 公式: (20x-10, 20y-10, 20)
			#递增规则已修改
			for x in range(1, 3):
				for y in range(1, 3):
					studs.append({"pos": Vector3(20.0*x - 10.0, 20.0*y - 10.0, 20.0), "dir": "Z_POS"})

		_:
			push_error("未找到Brick,Modified零件: %s" % part_name)
			return {"sockets": [], "studs": []}
	
	return {"sockets": sockets, "studs": studs}
