# opfu.gd
extends Node

# === 全局状态管理 ===
var _part_counter: Dictionary = {}
var part_scenes: Dictionary = {}
var _constructors: Dictionary = {}
var _current_model_root: Node3D = null
var _model_prefixes: Array = []

func set_part_scenes(scenes: Dictionary) -> void:
	part_scenes = scenes
	print("📦 opfu: 已加载 %d 个零件场景资源" % scenes.size())

func set_constructors(constructors: Dictionary) -> void:
	_constructors = constructors
	print("🏗️ opfu: 已加载 %d 个零件构造器" % constructors.size())

func set_current_model_root(root: Node3D) -> void:
	_current_model_root = root

func _find_part(cr_name: String) -> Node3D:
	if _current_model_root:
		var n := _current_model_root.get_node_or_null(cr_name) as Node3D
		if n:
			return n
	return get_tree().root.get_node_or_null(cr_name) as Node3D



# ============================================================
# crpa
# ============================================================
func crpa(part_name: String, custom_name: String = "") -> String:
	var unique_name: String
	if custom_name.is_empty():
		if not _part_counter.has(part_name):
			_part_counter[part_name] = 0
		var seq: int = _part_counter[part_name]
		_part_counter[part_name] += 1
		unique_name = "%s_%d" % [part_name, seq]
	else:
		unique_name = custom_name

	var scene_res = part_scenes.get(part_name)
	if not scene_res:
		push_error("opfu.crpa: 未找到场景资源 '%s'" % part_name)
		return unique_name

	var instance = scene_res.instantiate()
	instance.name = unique_name
	instance.transform = Transform3D.IDENTITY

	if _current_model_root:
		_current_model_root.add_child(instance)
	else:
		get_tree().root.add_child(instance)

	print("🧱 crpa: %s" % unique_name)
	return unique_name

# ============================================================
# pla
# ============================================================
func pla(cr_name: String, pos: Vector3, rot_input: Variant = null) -> void:
	var node := _find_part(cr_name)
	if not node:
		push_error("opfu.pla: 零件 '%s' 不存在" % cr_name)
		return

	var final_rot: Quaternion = _parse_rotation(rot_input)
	node.transform = Transform3D(final_rot, pos)

	print("📍 pla: %s | Pos: %s" % [cr_name, pos])

# ============================================================
# stco / skco
# ============================================================
func skco(act_name: String, pas_name: String,
		  act_rot: Variant,
		  act_stud_idx: int, pas_sock_idx: int) -> void:
	_connect_uni(act_name, pas_name, act_rot, act_stud_idx, pas_sock_idx, true)

func stco(act_name: String, pas_name: String,
		  act_rot: Variant,
		  act_sock_idx: int, pas_stud_idx: int) -> void:
	_connect_uni(act_name, pas_name, act_rot, act_sock_idx, pas_stud_idx, false)

func _connect_uni(act_name: String, pas_name: String,
				  act_rot: Variant,
				  act_idx: int, pas_idx: int,
				  is_skco: bool) -> void:
	var act_node := _find_part(act_name)
	var pas_node := _find_part(pas_name)

	if not act_node or not pas_node:
		push_error("opfu._connect_uni: 零件不存在 act=%s, pas=%s" % [act_name, pas_name])
		return

	var act_data: Array = _get_connection_data(act_name, is_skco)
	var pas_data: Array = _get_connection_data(pas_name, !is_skco)

	if act_data.size() <= act_idx:
		push_error("opfu._connect_uni: ACT点位索引越界! part=%s idx=%d size=%d" %
				   [act_name, act_idx, act_data.size()])
		return

	if pas_data.size() <= pas_idx:
		push_error("opfu._connect_uni: PAS点位索引越界! part=%s idx=%d size=%d" %
				   [pas_name, pas_idx, pas_data.size()])
		return

	var act_local_anchor: Vector3 = (act_data[act_idx]["pos"] as Vector3)
	var pas_local_target: Vector3 = (pas_data[pas_idx]["pos"] as Vector3)

	var final_rot: Quaternion = _parse_rotation(act_rot)
	var target_world_pos := pas_node.transform * pas_local_target
	var final_pos := target_world_pos - final_rot * act_local_anchor

	act_node.transform = Transform3D(final_rot, final_pos)

	var op_type := "skco" if is_skco else "stco"
	print("🔗 %s: %s[%d] → %s[%d]" % [op_type, act_name, act_idx, pas_name, pas_idx])

# ============================================================
# pnin / pnon
# ============================================================
func pnin(act_name: String, pas_name: String,
		  rotation: Variant,
		  tip_idx: int, hole_idx: int) -> void:
	_connect_pin(act_name, pas_name, rotation, tip_idx, hole_idx, true)

func pnon(act_name: String, pas_name: String,
		  rotation: Variant,
		  tip_idx: int, hole_idx: int) -> void:
	_connect_pin(pas_name, act_name, rotation, tip_idx, hole_idx, false)

func _connect_pin(axle_name: String, hole_name: String,
				  rotation: Variant,
				  tip_idx: int, hole_idx: int,
				  is_insert: bool) -> void:
	var axle_node := _find_part(axle_name)
	var hole_node := _find_part(hole_name)

	if not axle_node or not hole_node:
		push_error("opfu._connect_pin: 零件不存在 axle=%s, hole=%s" % [axle_name, hole_name])
		return

	var axle_tips: Array = _get_pin_data(axle_name, "tips")
	var hole_refs: Array = _get_pin_data(hole_name, "holes")

	if axle_tips.size() <= tip_idx:
		push_error("opfu._connect_pin: 轴端面索引越界! part=%s idx=%d size=%d" %
				   [axle_name, tip_idx, axle_tips.size()])
		return

	if hole_refs.size() <= hole_idx:
		push_error("opfu._connect_pin: 孔参考面索引越界! part=%s idx=%d size=%d" %
				   [hole_name, hole_idx, hole_refs.size()])
		return

	var tip_local: Vector3 = (axle_tips[tip_idx]["pos"] as Vector3)
	var ref_local: Vector3 = (hole_refs[hole_idx]["pos"] as Vector3)

	var final_rot: Quaternion = _parse_rotation(rotation)
	var target_world_pos := hole_node.transform * ref_local
	var final_pos := target_world_pos - final_rot * tip_local

	axle_node.transform = Transform3D(final_rot, final_pos)

	print("🔗 %s: %s[tip%d] → %s[hole%d]" %
		  ["pnin" if is_insert else "pnon", axle_name, tip_idx, hole_name, hole_idx])



# ============================================================
# 旋转解析
# ============================================================
func _parse_rotation(rot_input: Variant) -> Quaternion:
	if rot_input == null:
		return Quaternion.IDENTITY
	elif rot_input is Quaternion:
		return rot_input
	elif rot_input is Basis:
		return rot_input.get_rotation_quaternion()
	elif rot_input is Transform3D:
		return rot_input.basis.get_rotation_quaternion()
	elif rot_input is Vector3:
		return Quaternion.from_euler(rot_input)
	else:
		push_error("opfu._parse_rotation: 不支持的旋转类型 %s" % typeof(rot_input))
		return Quaternion.IDENTITY

# ============================================================
# 构造器路由
# ============================================================
func _resolve_constructor(part_name: String) -> Dictionary:
	var clean_name := part_name

	# 1. 剥离模块前缀
	for prefix in _model_prefixes:
		if clean_name.begins_with(prefix):
			clean_name = clean_name.substr(prefix.length())
			break

	# 2. 去掉尾部 "_数字"
	var last_underscore := clean_name.rfind("_")
	if last_underscore != -1:
		var tail := clean_name.substr(last_underscore + 1)
		if tail.is_valid_int():
			clean_name = clean_name.substr(0, last_underscore)

	# 3. 最长前缀匹配
	var matched_prefix := ""
	for key in _constructors.keys():
		if clean_name.begins_with(key):
			if key.length() > matched_prefix.length():
				matched_prefix = key

	if matched_prefix.is_empty():
		push_error("opfu._resolve_constructor: 未识别前缀 '%s'" % clean_name)
		return {}

	return {
		"ctor": _constructors[matched_prefix],
		"base_name": clean_name.substr(matched_prefix.length()),
	}

func _get_connection_data(part_name: String, need_studs: bool) -> Array:
	var r := _resolve_constructor(part_name)
	if r.is_empty():
		return []
	var data: Dictionary = r["ctor"].get_connection_data(r["base_name"]) as Dictionary
	if data.is_empty():
		return []
	return data.get("studs", []) if need_studs else data.get("sockets", [])

func _get_pin_data(part_name: String, data_key: String) -> Array:
	var r := _resolve_constructor(part_name)
	if r.is_empty():
		return []
	var data: Dictionary = r["ctor"].get_connection_data(r["base_name"]) as Dictionary
	if data.is_empty():
		return []
	return data.get(data_key, [])

# ============================================================
# crmo: Create Model
# ============================================================
func crmo(mdef_path: String) -> Dictionary:
	var script := load(mdef_path) as GDScript
	if not script:
		push_error("opfu.crmo: 无法加载 MDEF '%s'" % mdef_path)
		return {}

	var model_name := mdef_path.get_file().get_basename()

	var prefix := model_name + "_"
	if not _model_prefixes.has(prefix):
		_model_prefixes.append(prefix)

	var model_root := Node3D.new()
	model_root.name = model_name
	model_root.transform = Transform3D.IDENTITY
	get_tree().root.add_child(model_root)

	var prev := _current_model_root
	_current_model_root = model_root

	var mdef = script.new()
	var result: Node3D = mdef.build(model_root)

	_current_model_root = prev

	if not result:
		push_error("opfu.crmo: MDEF '%s' 构建失败" % mdef_path)
		model_root.queue_free()
		return {}

	var anchor_info: Dictionary = {}
	if mdef.has_method("get_anchor"):
		anchor_info = mdef.get_anchor()

	var inpo_list: Array = []
	if mdef.has_method("get_inpo"):
		inpo_list = mdef.get_inpo()

	var model_data := {
		"root": result,
		"anchor_part": anchor_info.get("part", ""),
		"anchor_point": anchor_info.get("point", Vector3.ZERO),
		"inpo": inpo_list,
	}

	print("🧩 crmo: %s -> %s | INPO: %d" % [mdef_path, result.name, inpo_list.size()])
	return model_data
	
# ============================================================
# inco: 模块级通用接口连接
# ACT: Active Model, PAS: Passive Model
# ============================================================
func inco(act_data: Dictionary, pas_data: Dictionary, act_rot: Variant,
		  act_inpo_idx: int, pas_inpo_idx: int) -> void:
	var act_root: Node3D = act_data.get("root")
	var pas_root: Node3D = pas_data.get("root")

	if not act_root or not pas_root:
		push_error("opfu.inco: 模块根节点无效")
		return

	var act_inpo_list: Array = act_data.get("inpo", [])
	var pas_inpo_list: Array = pas_data.get("inpo", [])

	if act_inpo_idx < 0 or act_inpo_idx >= act_inpo_list.size():
		push_error("opfu.inco: ACT INPO 序号越界! idx=%d size=%d" %
				   [act_inpo_idx, act_inpo_list.size()])
		return

	if pas_inpo_idx < 0 or pas_inpo_idx >= pas_inpo_list.size():
		push_error("opfu.inco: PAS INPO 序号越界! idx=%d size=%d" %
				   [pas_inpo_idx, pas_inpo_list.size()])
		return

	var act_inpo: Dictionary = act_inpo_list[act_inpo_idx]
	var pas_inpo: Dictionary = pas_inpo_list[pas_inpo_idx]

	var act_inpa: String = act_inpo.get("part", "")
	var act_type: String = act_inpo.get("type", "")
	var act_pt_idx: int = act_inpo.get("index", -1)

	var pas_inpa: String = pas_inpo.get("part", "")
	var pas_type: String = pas_inpo.get("type", "")
	var pas_pt_idx: int = pas_inpo.get("index", -1)

	if act_inpa.is_empty() or pas_inpa.is_empty():
		push_error("opfu.inco: INPO 零件名为空 act=%s pas=%s" % [act_inpa, pas_inpa])
		return

	var act_inpa_node := act_root.get_node_or_null(act_inpa) as Node3D
	var pas_inpa_node := pas_root.get_node_or_null(pas_inpa) as Node3D

	if not act_inpa_node or not pas_inpa_node:
		push_error("opfu.inco: 接口零件不存在 acmo=%s, pamo=%s" % [act_inpa, pas_inpa])
		return

	# 取点位数据
	var act_pt = _get_inpo_point(act_inpa, act_type, act_pt_idx)
	var pas_pt = _get_inpo_point(pas_inpa, pas_type, pas_pt_idx)

	if act_pt == null or pas_pt == null:
		return

	var act_local: Vector3 = act_pt
	var pas_local: Vector3 = pas_pt

	var final_rot: Quaternion = _parse_rotation(act_rot)
	var target_world: Vector3 = pas_inpa_node.global_transform * pas_local

	var act_world_before: Vector3 = act_inpa_node.global_transform * act_local
	var act_in_acmo: Vector3 = act_root.global_transform.affine_inverse() * act_world_before

	var new_basis: Basis = Basis(final_rot)
	var new_origin: Vector3 = target_world - new_basis * act_in_acmo

	act_root.global_transform = Transform3D(new_basis, new_origin)

	print("🔗 inco: %s.%s[%s%d] → %s.%s[%s%d]" %
		  [act_root.name, act_inpa, act_type, act_pt_idx,
		   pas_root.name, pas_inpa, pas_type, pas_pt_idx])


# 根据点位类型取局部坐标
# @return: Vector3，失败返回 null
func _get_inpo_point(part_name: String, type: String, idx: int) -> Variant:
	var data: Array

	if type == "studs":
		data = _get_connection_data(part_name, true)
	elif type == "sockets":
		data = _get_connection_data(part_name, false)
	else:
		data = _get_pin_data(part_name, type)

	if data.size() <= idx:
		push_error("opfu._get_inpo_point: 点位越界! part=%s type=%s idx=%d size=%d" %
				   [part_name, type, idx, data.size()])
		return null

	var pt = data[idx].get("pos")
	if pt == null:
		push_error("opfu._get_inpo_point: 点位无 pos! part=%s type=%s idx=%d" %
				   [part_name, type, idx])
		return null

	return pt as Vector3

# ============================================================
# setmo
# ============================================================
func setmo(model_data: Dictionary, rotation: Quaternion) -> void:
	var model_root: Node3D = model_data.get("root")
	if not model_root:
		push_error("opfu.setmo: model_root 无效")
		return

	var anchor_part_name: String = model_data.get("anchor_part", "")
	var anchor_point: Vector3 = model_data.get("anchor_point", Vector3.ZERO)

	if anchor_part_name.is_empty():
		push_error("opfu.setmo: 锚点零件未定义")
		return

	var anchor_part := model_root.get_node_or_null(anchor_part_name) as Node3D
	if not anchor_part:
		push_error("opfu.setmo: 锚点零件 '%s' 不存在" % anchor_part_name)
		return

	var anchor_world: Vector3 = anchor_part.global_transform * anchor_point
	var anchor_in_model: Vector3 = model_root.global_transform.affine_inverse() * anchor_world

	var new_basis: Basis = Basis(rotation)
	var new_origin: Vector3 = target_world_safe(new_basis, anchor_in_model)

	model_root.global_transform = Transform3D(new_basis, new_origin)

	var verify_world: Vector3 = anchor_part.global_transform * anchor_point
	print("⚓ setmo: %s | 锚点 %s | 验证世界坐标: %s" % [model_root.name, anchor_part_name, verify_world])

func target_world_safe(basis: Basis, v: Vector3) -> Vector3:
	return -(basis * v)
