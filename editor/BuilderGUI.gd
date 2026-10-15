# BuilderGUI.gd ver: cache, CPAS dots, correct names
# last ver: cache, CPAS dots
extends Node3D

# === 1. 资源配置区 ===
const PAS1_PART_KEY := "pl3031"
const PAS1_POSITION := Vector3.ZERO
const PAS1_EULER_X := -90.0

# 摄像机预设
const CAM_BUI_POS := Vector3(0, 0, 200)
const CAM_AUI_POS := Vector3(1020, 80, -880)
const CAM_AUI_ROT := Vector3(-10.0, 0.0, 0.0)
const CAM_DEFAULT_ROT := Vector3.ZERO

# ACT 预览位置
const PREVIEW_ACT_POS := Vector3(1000, 0, -1000)

# ✅ 摄像机平移/旋转参数
const CAM_PAN_STEP := 50.0
const CAM_PAN_TWEEN_DURATION := 0.15
const CAM_ROT_SPEED := 45.0


# 构造分类映射 (缩写 -> 全称, plmo/brmo 独立)
const CATEGORY_MAP := {
	"br": "Brick",
	"brmo": "Brick, Modified",
	"pl": "Plate",
	"plmo": "Plate, Modified",
	"bk":   "Bracket", 
	"sl": "Slope",
	"slin": "Slope, Inverted",
	"slcu": "Slope, Curved",
	"teax": "Technique, Axle",
	"tebr": "Technique, Brick",
	"ti": "Tile",
	"brro": "Brick, Round",
}

# === 2. 内部状态 ===
var _ui_layer: CanvasLayer
var _btn_to_preview: Button      # BUI 专用按钮
var _btn_back: Button            # AUI 专用按钮
var _category_list: VBoxContainer
var _part_list: VBoxContainer
var _pact_controls: HBoxContainer # PACT旋转控制容器
var _cam_pan_controls: GridContainer # AUI 摄像机平移控制容器
var _bui_view_controls: GridContainer # ✅ BUI 视角控制容器
var _pas1_node: Node3D
var _preview_node: Node3D         # 当前PACT节点
var _camera: Camera3D
var _pan_tween: Tween             # 平移动画引用
var _rotating_y: float = 0.0      # ✅ 连续Y轴旋转累积值
var _panning_dir: Vector3 = Vector3.ZERO  # ✅ 当前平移方向 (Vector3.ZERO表示未按下)

# ✅ PACT 姿态与选点状态存储 (跨页面缓存)
var _pact_rotation: Quaternion = Quaternion.IDENTITY
var _selected_point_type: String = ""
var _selected_point_index: int = -1
var _cached_part_key: String = "" # ✅ 新增：缓存AUI中选中的零件Key

# ✅ 点位标记相关 (使用字典映射替代 index*2 计算)
var _point_markers: Array = []        # 仅用于统一销毁
var _marker_panels: Dictionary = {}   # Key: 序号, Value: Panel引用
var _current_marker_type: String = ""

# ✅ 内聚操作函数所需状态
var _constructors: Dictionary = {}    # 本地构造器实例
var _part_counter: Dictionary = {}    # 零件计数器 (预留)

# ✅ CPAS (Current PAS) 状态
var _cpas_node: Node3D = null          # 当前高亮的CPAS节点
var _cpas_marker_type: String = ""     # CPAS应显示的点位类型 ("stud"/"socket")
var _cpas_marker_panels: Dictionary = {} # CPAS标记面板字典 (防越界)
var _cpas_marker_list: Array = []      # CPAS标记列表 (用于销毁)

func _ready():
	# ✅ 核心修复：本地初始化构造器，不再依赖 LegoOps
	_setup_constructors()
	
	_setup_pas1()
	_setup_camera()
	_create_bui()

# 🔧 本地构造器注入
func _setup_constructors():
	if not _constructors.is_empty():
		return
	
	var ctors := {
		"br": BrickConstructor.new(),
		"brmo": BrickModifiedConstructor.new(),		
		"pl": PlateConstructor.new(),
		"plmo": PlateModifiedConstructor.new(),
		"bk":   BracketConstructor.new(),
		"sl": SlopeConstructor.new(),
		"slin": SlopeInvertedConstructor.new(),
		"slcu": SlopeCurvedConstructor.new(),
		"teax": TechniqueAxleConstructor.new(),
		"tebr": TechniqueBrickConstructor.new(),
		"ti": TileConstructor.new(),
		"brro": BrickRoundConstructor.new()
	}
	_constructors = ctors
	print("🔧 BuilderGUI: 已本地初始化 %d 个构造器" % ctors.size())

## 🔧 为指定零件Key分配唯一序列名称 (计数器只增不减)
func _allocate_part_name(part_key: String) -> String:
	if not _part_counter.has(part_key):
		_part_counter[part_key] = 0
	
	var seq : int = _part_counter[part_key]
	_part_counter[part_key] += 1
	
	return "%s_%d" % [part_key, seq]

# 🔧 放置 PAS1
func _setup_pas1():
	var scene_res = PartIndex.PART_SCENES.get(PAS1_PART_KEY)
	if not scene_res:
		push_error("BuilderGUI: 未找到 PAS1 零件 '%s'" % PAS1_PART_KEY)
		return
	
	_pas1_node = scene_res.instantiate() as Node3D
	
	# ✅ 核心修改：PAS1 使用统一序列命名 pl3031_0
	_pas1_node.name = "%s_%d" % [PAS1_PART_KEY, 0]
	
	# ✅ 初始化计数器，确保后续同型号零件从 _1 开始
	_part_counter[PAS1_PART_KEY] = 1 
	
	add_child(_pas1_node)
	
	var rot := Quaternion(Vector3.RIGHT, deg_to_rad(PAS1_EULER_X))
	_pas1_node.transform = Transform3D(rot, PAS1_POSITION)
	
	print("🧱 PAS1 已放置: %s | Pos: %s | RotX: %.1f°" % [_pas1_node.name, PAS1_POSITION, PAS1_EULER_X])

#  设置摄像机
func _setup_camera():
	_camera = Camera3D.new()
	_camera.name = "LockedCamera"
	_camera.position = CAM_BUI_POS
	_camera.rotation_degrees = CAM_DEFAULT_ROT
	_camera.current = true
	_camera.set_process_input(false)
	add_child(_camera)

# ️ 创建 BUI (包含进入AUI按钮 + 视角控制)
func _create_bui():
	_ui_layer = CanvasLayer.new()
	_ui_layer.name = "UI_Layer"
	add_child(_ui_layer)
	
	_btn_to_preview = Button.new()
	_btn_to_preview.text = "switch page"
	_btn_to_preview.custom_minimum_size = Vector2(120, 40)
	_btn_to_preview.position = Vector2(1000, 20)
	_btn_to_preview.pressed.connect(_on_enter_aui)
	_ui_layer.add_child(_btn_to_preview)
	
	# ✅ 补全：在 BUI 中创建视角控制按钮 (2x5 网格)
	_create_bui_view_controls()

# 🔀 切换到 AUI
func _on_enter_aui():
	# ✅ 补全：进入AUI时立即销毁BUI视角控件
	_destroy_bui_view_controls()
	
	_btn_to_preview.visible = false
	_pas1_node.visible = false
	
	_camera.position = CAM_AUI_POS
	_camera.rotation_degrees = CAM_AUI_ROT
	
	var main_hbox := HBoxContainer.new()
	main_hbox.name = "AUI_Main"
	main_hbox.set_anchors_preset(Control.PRESET_FULL_RECT)
	main_hbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_ui_layer.add_child(main_hbox)
	
	_category_list = VBoxContainer.new()
	_category_list.custom_minimum_size = Vector2(150, 0)
	_category_list.size_flags_vertical = Control.SIZE_EXPAND_FILL
	main_hbox.add_child(_category_list)
	
	_part_list = VBoxContainer.new()
	_part_list.custom_minimum_size = Vector2(200, 0)
	_part_list.size_flags_vertical = Control.SIZE_EXPAND_FILL
	main_hbox.add_child(_part_list)
	
	_btn_back = Button.new()
	_btn_back.text = "switch page"
	_btn_back.custom_minimum_size = Vector2(120, 40)
	_btn_back.position = Vector2(1000, 20)
	_btn_back.pressed.connect(_on_exit_aui)
	_ui_layer.add_child(_btn_back)
	
	_build_category_list()

# 🔙 退出 AUI 回到 BUI (✅ 新增延迟实例化测试逻辑)
func _on_exit_aui():
	for child in _ui_layer.get_children():
		if child.name == "AUI_Main":
			child.queue_free()
	_btn_back.queue_free()
	
	_btn_to_preview.visible = true
	_pas1_node.visible = true
	
	_camera.position = CAM_BUI_POS
	_camera.rotation_degrees = CAM_DEFAULT_ROT
	_rotating_y = 0.0 # 复位时重置连续旋转累积值
	
	# ✅ 补全：返回BUI时重建视角控件
	_create_bui_view_controls()
	
	# ✅ 核心修改：执行延迟实例化测试，而非直接销毁PACT
	_execute_delayed_instantiate_test()
	
	_clear_point_markers()
	_reset_pact_state()
	_destroy_cam_pan_controls()

# BuilderGUI.gd - 替换 _execute_delayed_instantiate_test 函数
func _execute_delayed_instantiate_test():
	# 1. 校验缓存有效性
	if _cached_part_key.is_empty():
		print("️ 测试跳过: AUI中未选择任何零件")
		return
	
	if _selected_point_type.is_empty() or _selected_point_index < 0:
		print("⚠️ 测试跳过: AUI中未选择点位 (Type=%s, Index=%d)" % [_selected_point_type, _selected_point_index])
		return
	
	# 2. 获取资源并实例化（仅用于验证姿态传递，不作为CPAS）
	var scene_res = PartIndex.PART_SCENES.get(_cached_part_key)
	if not scene_res:
		push_error("BuilderGUI: 测试失败 - 未找到零件 '%s'" % _cached_part_key)
		return
	
	var test_node := scene_res.instantiate() as Node3D
	
	# ✅ 核心修改：测试零件也使用统一序列命名，避免前缀污染
	test_node.name = _allocate_part_name(_cached_part_key)
	
	add_child(test_node)
	
	# 3. 应用缓存的姿态到原点
	test_node.transform = Transform3D(_pact_rotation, Vector3.ZERO)
	
	# 4. 控制台详细报告
	print("========================================")
	print("✅ 延迟实例化测试成功!")
	print("   零件名称: %s" % test_node.name)
	print("   世界坐标: Vector3(0, 0, 0)")
	print("   四元数  : %s" % _pact_rotation)
	print("   PACT选中: Type=%s Index=%d" % [_selected_point_type, _selected_point_index])
	print("========================================")
	
	# 5. CPAS 始终指向真实组合体零件（当前为 PAS1）
	_cpas_node = _pas1_node 
	_cpas_marker_type = "socket" if _selected_point_type == "stud" else "stud"
	_show_cpas_markers()
	
	# 6. 销毁AUI预览节点
	_destroy_pact()

# BuilderGUI.gd - 替换 _show_cpas_markers 函数
func _show_cpas_markers():
	if not _cpas_node or _cpas_marker_type.is_empty():
		return
	
	# 清除旧CPAS标记
	for marker in _cpas_marker_list:
		if is_instance_valid(marker):
			marker.queue_free()
	_cpas_marker_list.clear()
	_cpas_marker_panels.clear()
	
	# ✅ 使用 _cpas_node 的真实名称获取数据，确保前缀匹配正确
	var data: Array = _get_connection_data(_cpas_node.name, _cpas_marker_type == "stud")
	if data.is_empty():
		push_warning("BuilderGUI: 无法获取CPAS %s 的 %s 数据" % [_cpas_node.name, _cpas_marker_type])
		return
	
	var color := Color.GREEN if _cpas_marker_type == "stud" else Color.DIM_GRAY
	
	for i in range(data.size()):
		var local_pos: Vector3 = (data[i]["pos"] as Vector3)
		var world_pos := _cpas_node.transform * local_pos
		var screen_pos := _camera.unproject_position(world_pos)
		
		# 创建2D标记面板
		var marker_panel := Panel.new()
		marker_panel.size = Vector2(16, 16)
		marker_panel.position = screen_pos - Vector2(8, 8)
		marker_panel.self_modulate = color
		marker_panel.mouse_filter = Control.MOUSE_FILTER_STOP
		
		var style := StyleBoxFlat.new()
		style.bg_color = color
		style.corner_radius_top_left = 8
		style.corner_radius_top_right = 8
		style.corner_radius_bottom_left = 8
		style.corner_radius_bottom_right = 8
		marker_panel.add_theme_stylebox_override("panel", style)
		
		# 存入字典防越界
		_cpas_marker_panels[i] = marker_panel
		
		_ui_layer.add_child(marker_panel)
		_cpas_marker_list.append(marker_panel)
		
		# 创建序号标签
		var label := Label.new()
		label.text = str(i)
		label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		label.size = Vector2(16, 16)
		label.position = Vector2(0, 0)
		label.add_theme_color_override("font_color", Color.WHITE)
		label.add_theme_font_size_override("font_size", 14)
		marker_panel.add_child(label)
		
		# 绑定CPAS专用点击回调
		marker_panel.gui_input.connect(_on_cpas_point_clicked.bind(i))
	
	print(" 已显示CPAS %d 个 %s 互补标记" % [data.size(), _cpas_marker_type])

func _on_cpas_point_clicked(event: InputEvent, index: int):
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		# ✅ 视觉反馈：高亮被点击的CPAS点位
		for idx in _cpas_marker_panels.keys():
			var panel := _cpas_marker_panels[idx] as Panel
			if panel:
				var style := panel.get_theme_stylebox("panel") as StyleBoxFlat
				if style:
					style.bg_color = Color.YELLOW if idx == index else \
						(Color.GREEN if _cpas_marker_type == "stud" else Color.CYAN)
		
		print("️ CPAS点位点击: Index=%d | Type=%s | Ready for skco/stco" % 
			  [index, _cpas_marker_type])
			  
# ✅ 补全：创建 BUI 视角控制按钮 (2x5 网格布局)
func _create_bui_view_controls():
	_destroy_bui_view_controls()
	
	_bui_view_controls = GridContainer.new()
	_bui_view_controls.columns = 5
	_bui_view_controls.position = Vector2(20, 540)
	_ui_layer.add_child(_bui_view_controls)
	
	# 2x5 按钮定义：第一行平移，第二行旋转+复位+占位
	var view_buttons := [
		# 第一行：前后左右 + 空占位
		{"text": "↑", "type": "pan", "dir": Vector3.FORWARD},
		{"text": "↓", "type": "pan", "dir": Vector3.BACK},
		{"text": "←", "type": "pan", "dir": Vector3.LEFT},
		{"text": "→", "type": "pan", "dir": Vector3.RIGHT},
		{"text": "",  "type": "empty"},
		
		# 第二行：逆时针、顺时针、复位、上、下
		{"text": "<",  "type": "rot_ccw"},
		{"text": ">",  "type": "rot_cw"},
		{"text": "R",  "type": "reset"},
		{"text": "+",  "type": "pan", "dir": Vector3.UP},
		{"text": "-",  "type": "pan", "dir": Vector3.DOWN}
	]
	
	for b in view_buttons:
		if b["type"] == "empty":
			var spacer := Control.new()
			spacer.custom_minimum_size = Vector2(40, 40)
			_bui_view_controls.add_child(spacer)
			continue
		
		var btn := Button.new()
		btn.text = b["text"]
		btn.custom_minimum_size = Vector2(40, 40)
		
		match b["type"]:
			"pan":
				btn.gui_input.connect(_on_view_button_input.bind(b["dir"], "pan"))
			"rot_ccw":
				btn.gui_input.connect(_on_view_button_input.bind(-CAM_ROT_SPEED, "rot"))
			"rot_cw":
				btn.gui_input.connect(_on_view_button_input.bind(CAM_ROT_SPEED, "rot"))
			"reset":
				btn.pressed.connect(_reset_camera_position)
		
		_bui_view_controls.add_child(btn)

# ✅ 补全：处理视角按钮输入 (支持按下持续触发 + 松手即停)
func _on_view_button_input(event: InputEvent, param: Variant, action_type: String):
	if event is InputEventMouseButton:
		if event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
			if action_type == "pan":
				_pan_camera_smooth(param as Vector3)
			elif action_type == "rot":
				_start_continuous_rotation(param as float)
		else:
			if action_type == "rot":
				_stop_continuous_rotation()
	
	elif event is InputEventScreenTouch:
		if event.pressed:
			if action_type == "pan":
				_pan_camera_smooth(param as Vector3)
			elif action_type == "rot":
				_start_continuous_rotation(param as float)
		else:
			if action_type == "rot":
				_stop_continuous_rotation()

# ✅ 补全：启动连续Y轴旋转
func _start_continuous_rotation(speed: float):
	_rotating_y = speed
	set_process(true) # 激活 _process 进行帧更新

# ✅ 补全：停止连续旋转
func _stop_continuous_rotation():
	_rotating_y = 0.0
	_refresh_point_markers()
	# 若无其他待处理任务，可关闭 process 节省开销
	if _pan_tween == null or not _pan_tween.is_valid():
		set_process(false)

# ✅ 补全：每帧执行连续旋转
func _process(delta: float):
	if abs(_rotating_y) > 0.001:
		var new_y := _camera.rotation_degrees.y + _rotating_y * delta
		_camera.rotation_degrees = Vector3(0.0, new_y, 0.0)

# ✅ 平滑平移摄像机 (BUI/AUI 共用)
func _pan_camera_smooth(direction: Vector3):
	if not _camera:
		return
	
	if _pan_tween and _pan_tween.is_valid():
		_pan_tween.kill()
	
	var target_pos := _camera.position + _camera.basis * direction * CAM_PAN_STEP
	
	_pan_tween = create_tween().set_trans(Tween.TRANS_LINEAR).set_ease(Tween.EASE_IN_OUT)
	_pan_tween.tween_property(_camera, "position", target_pos, CAM_PAN_TWEEN_DURATION)
	_pan_tween.finished.connect(_refresh_point_markers)
	
	# 确保 process 开启以支持可能的后续旋转
	set_process(true)

# ✅ 跳变复位摄像机 (BUI/AUI 共用)
func _reset_camera_position():
	if not _camera:
		return
	
	if _pan_tween and _pan_tween.is_valid():
		_pan_tween.kill()
	_stop_continuous_rotation()
	
	if _btn_to_preview.visible:
		_camera.position = CAM_BUI_POS
		_camera.rotation_degrees = CAM_DEFAULT_ROT
		_rotating_y = 0.0
	else:
		_camera.position = CAM_AUI_POS
	
	_refresh_point_markers()

# ✅ 刷新点位标记 (平移/复位后调用)
func _refresh_point_markers():
	# ✅ 如果在 AUI 且存在 PACT 标记，则刷新 PACT 标记
	if not _btn_to_preview.visible and not _current_marker_type.is_empty():
		_show_point_markers(_current_marker_type)
	
	# ✅ 如果在 BUI 且存在 CPAS 标记，则刷新 CPAS 标记
	if _btn_to_preview.visible and not _cpas_marker_type.is_empty():
		_show_cpas_markers()

# ✅ 安全销毁 BUI 视角控件
func _destroy_bui_view_controls():
	if _bui_view_controls:
		_bui_view_controls.queue_free()
		_bui_view_controls = null
	_stop_continuous_rotation()

# 🔧 动态生成一级目录 (plmo/brmo 独立显示)
func _build_category_list():
	var grouped := {}
	for part_key in PartIndex.PART_SCENES.keys():
		var prefix := _get_prefix(part_key)
		if not grouped.has(prefix):
			grouped[prefix] = []
		grouped[prefix].append(part_key)
	
	for prefix in CATEGORY_MAP.keys():
		if not grouped.has(prefix):
			continue
		
		var btn := Button.new()
		btn.text = CATEGORY_MAP[prefix]
		btn.custom_minimum_size = Vector2(140, 35)
		btn.pressed.connect(_on_select_category.bind(prefix, grouped[prefix]))
		_category_list.add_child(btn)

# 🔧 选择构造后显示二级目录
func _on_select_category(_prefix: String, parts: Array):
	for child in _part_list.get_children():
		child.queue_free()
	
	for part_key in parts:
		var btn := Button.new()
		btn.text = part_key
		btn.custom_minimum_size = Vector2(190, 35)
		btn.pressed.connect(_on_select_part.bind(part_key))
		_part_list.add_child(btn)

# 🔧 选择零件后预览 (✅ 关键：同步缓存 part_key)
func _on_select_part(part_key: String):
	_destroy_pact()
	_clear_point_markers()
	_reset_pact_state()
	
	var scene_res = PartIndex.PART_SCENES.get(part_key)
	if not scene_res:
		push_error("BuilderGUI: 未找到零件 '%s'" % part_key)
		return
	
	_preview_node = scene_res.instantiate()
	_preview_node.name = part_key
	add_child(_preview_node)
	
	_preview_node.transform = Transform3D(Quaternion.IDENTITY, PREVIEW_ACT_POS)
	_pact_rotation = Quaternion.IDENTITY
	
	# ✅ 核心修复：缓存零件Key，确保退出AUI时可访问
	_cached_part_key = part_key
	
	_create_pact_controls()
	_create_cam_pan_controls() # ✅ PACT放置后显示AUI摄像机平移控件
	
	print("👁️ 预览零件: %s | Pos: %s" % [part_key, PREVIEW_ACT_POS])

# 🔧 创建 PACT 旋转控制按钮组 + Stud/Socket 切换按钮
func _create_pact_controls():
	_pact_controls = HBoxContainer.new()
	_pact_controls.alignment = BoxContainer.ALIGNMENT_CENTER
	_pact_controls.position = Vector2(600, 20)
	_ui_layer.add_child(_pact_controls)
	
	var dirs := [
		{"text": "↑", "axis": Vector3.RIGHT, "deg": -90.0},
		{"text": "↓", "axis": Vector3.RIGHT, "deg": 90.0},
		{"text": "←", "axis": Vector3.UP,    "deg": -90.0},
		{"text": "→", "axis": Vector3.UP,    "deg": 90.0}
	]
	
	for d in dirs:
		var btn := Button.new()
		btn.text = d["text"]
		btn.custom_minimum_size = Vector2(40, 40)
		btn.pressed.connect(_rotate_pact.bind(d["axis"], d["deg"]))
		_pact_controls.add_child(btn)
	
	var spacer := Control.new()
	spacer.custom_minimum_size = Vector2(20, 0)
	_pact_controls.add_child(spacer)
	
	var stud_btn := Button.new()
	stud_btn.text = "Stud"
	stud_btn.custom_minimum_size = Vector2(70, 35)
	stud_btn.pressed.connect(_show_point_markers.bind("stud"))
	_pact_controls.add_child(stud_btn)
	
	var sock_btn := Button.new()
	sock_btn.text = "Socket"
	sock_btn.custom_minimum_size = Vector2(70, 35)
	sock_btn.pressed.connect(_show_point_markers.bind("socket"))
	_pact_controls.add_child(sock_btn)

# 🔧 执行 PACT 单步旋转
func _rotate_pact(axis: Vector3, deg: float):
	if not _preview_node:
		return
	
	var step_rot := Quaternion(axis, deg_to_rad(deg))
	_pact_rotation = step_rot * _pact_rotation
	
	_preview_node.transform.basis = Basis(_pact_rotation)
	
	if not _current_marker_type.is_empty():
		_show_point_markers(_current_marker_type)
	
	print("🔄 PACT 旋转: Axis=%s Deg=%.0f° | Stored Rot: %s" % [axis, deg, _pact_rotation])

# 🔧 显示指定类型的点位标记 (✅ 纯2D投影 + 字典映射防越界)
func _show_point_markers(point_type: String):
	if not _preview_node:
		return
	
	_clear_point_markers()
	_current_marker_type = point_type
	
	# ✅ 调用本地化点位查询函数
	var data: Array = _get_connection_data(_preview_node.name, point_type == "stud")
	if data.is_empty():
		push_warning("BuilderGUI: 无法获取 %s 的 %s 数据" % [_preview_node.name, point_type])
		return
	
	var color := Color.RED if point_type == "stud" else Color.BLUE
	
	for i in range(data.size()):
		var local_pos: Vector3 = (data[i]["pos"] as Vector3)
		var world_pos := _preview_node.transform * local_pos
		var screen_pos := _camera.unproject_position(world_pos)
		
		# 创建2D标记面板
		var marker_panel := Panel.new()
		marker_panel.size = Vector2(16, 16)
		marker_panel.position = screen_pos - Vector2(8, 8)
		marker_panel.self_modulate = color
		marker_panel.mouse_filter = Control.MOUSE_FILTER_STOP
		
		var style := StyleBoxFlat.new()
		style.bg_color = color
		style.corner_radius_top_left = 8
		style.corner_radius_top_right = 8
		style.corner_radius_bottom_left = 8
		style.corner_radius_bottom_right = 8
		marker_panel.add_theme_stylebox_override("panel", style)
		
		# ✅ 核心修复：将Panel引用按序号存入字典
		_marker_panels[i] = marker_panel
		
		_ui_layer.add_child(marker_panel)
		_point_markers.append(marker_panel)
		
		# 创建序号标签
		var label := Label.new()
		label.text = str(i)
		label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		label.size = Vector2(16, 16)
		label.position = Vector2(0, 0)
		label.add_theme_color_override("font_color", Color.WHITE)
		label.add_theme_font_size_override("font_size", 14)
		marker_panel.add_child(label)
		
		# 绑定点击事件
		marker_panel.gui_input.connect(_on_point_clicked.bind(point_type, i))
	
	print("✅ 已显示 %d 个 %s 2D标记" % [data.size(), point_type])

# ✅ 处理点位点击事件
func _on_point_clicked(event: InputEvent, point_type: String, index: int):
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		_selected_point_type = point_type
		_selected_point_index = index
		
		# ✅ 安全获取被点击的Panel引用
		var clicked_panel := _marker_panels.get(index) as Panel
		if not clicked_panel:
			push_warning("BuilderGUI: 未找到序号 %d 对应的Panel" % index)
			return
		
		# 高亮被选中的圆点
		var style := clicked_panel.get_theme_stylebox("panel") as StyleBoxFlat
		if style:
			style.bg_color = Color.YELLOW
		
		# 恢复其他圆点颜色
		for idx in _marker_panels.keys():
			if idx != index:
				var other_panel := _marker_panels[idx] as Panel
				var other_style := other_panel.get_theme_stylebox("panel") as StyleBoxFlat
				if other_style:
					other_style.bg_color = Color.RED if _current_marker_type == "stud" else Color.BLUE
		
		print("🎯 已选中: Type=%s Index=%d | Current PACT Rot: %s" % 
			  [point_type, index, _pact_rotation])

#  清除所有点位标记
func _clear_point_markers():
	for marker in _point_markers:
		if is_instance_valid(marker):
			marker.queue_free()
	_point_markers.clear()
	_marker_panels.clear()
	_current_marker_type = ""

# ✅ 重置 PACT 状态
func _reset_pact_state():
	_pact_rotation = Quaternion.IDENTITY
	_selected_point_type = ""
	_selected_point_index = -1
	_current_marker_type = ""
	# ✅ 注意：不重置 _cached_part_key，因为它需要跨越AUI/BUI边界

# 🔧 工具：提取零件前缀 (最长匹配)
func _get_prefix(part_name: String) -> String:
	var matched := ""
	for key in CATEGORY_MAP.keys():
		if part_name.begins_with(key) and key.length() > matched.length():
			matched = key
	return matched if not matched.is_empty() else "unknown"

# 🔧 工具：安全销毁 PACT 及其控件
func _destroy_pact():
	if _preview_node:
		_preview_node.queue_free()
		_preview_node = null
	
	if _pact_controls:
		_pact_controls.queue_free()
		_pact_controls = null

# ✅ 安全销毁 AUI 摄像机平移控件
func _destroy_cam_pan_controls():
	if _cam_pan_controls:
		_cam_pan_controls.queue_free()
		_cam_pan_controls = null
	if _pan_tween and _pan_tween.is_valid():
		_pan_tween.kill()
		_pan_tween = null

# ✅ 新增：创建 AUI 摄像机平移控件 (2x4 网格)
func _create_cam_pan_controls():
	_destroy_cam_pan_controls()
	
	_cam_pan_controls = GridContainer.new()
	_cam_pan_controls.columns = 4
	_cam_pan_controls.position = Vector2(20, 540)
	_ui_layer.add_child(_cam_pan_controls)
	
	var pan_buttons := [
		{"text": "↑", "dir": Vector3.FORWARD},
		{"text": "↓", "dir": Vector3.BACK},
		{"text": "←", "dir": Vector3.LEFT},
		{"text": "→", "dir": Vector3.RIGHT},
		{"text": "+", "dir": Vector3.UP},
		{"text": "-", "dir": Vector3.DOWN},
		{"text": "",  "dir": Vector3.ZERO},
		{"text": "R", "dir": Vector3.ZERO}
	]
	
	for b in pan_buttons:
		var btn := Button.new()
		btn.text = b["text"]
		btn.custom_minimum_size = Vector2(40, 40)
		
		if b["text"] == "R":
			btn.pressed.connect(_reset_camera_position)
		elif b["dir"] != Vector3.ZERO:
			btn.pressed.connect(_pan_camera_smooth.bind(b["dir"]))
		
		_cam_pan_controls.add_child(btn)

# ============================================================
# ✅ 以下为核心操作函数 (已从 LegoOps.gd 完整迁移)
# ============================================================

#  构造器路由工具 (本地化版本)
func _get_connection_data(part_name: String, need_studs: bool) -> Array:
	# 1. 去除尾部序号
	var clean_name := part_name
	if "_" in clean_name:
		clean_name = clean_name.split("_")[0]
	
	# 2. 寻找最长的匹配前缀
	var matched_prefix := ""
	for key in _constructors.keys():
		if clean_name.begins_with(key):
			if key.length() > matched_prefix.length():
				matched_prefix = key
	
	if matched_prefix.is_empty():
		push_error("BuilderGUI._get_data: 未识别的零件前缀 '%s' (cleaned from '%s')" % [clean_name, part_name])
		return []
	
	# 3. 提取基础零件名
	var base_name := clean_name.substr(matched_prefix.length())
	
	var ctor = _constructors[matched_prefix]
	
	# 4. 显式类型声明并获取数据
	var data: Dictionary = ctor.get_connection_data(base_name) as Dictionary
	
	if data.is_empty():
		push_warning("BuilderGUI._get_data: 构造器返回空数据 for '%s'" % base_name)
		
	return data.get("studs", []) if need_studs else data.get("sockets", [])

# skco: Socket-Connect - ACT Stud 对齐 PAS Socket (绝对姿态+单点)
func skco(act_name: String, pas_name: String, 
		  act_rot: Variant, 
		  act_stud_idx: int, pas_sock_idx: int) -> void:
	_connect_uni(act_name, pas_name, act_rot, act_stud_idx, pas_sock_idx, true)

# stco: Stud-Connect - ACT Socket 对齐 PAS Stud (绝对姿态+单点)
func stco(act_name: String, pas_name: String, 
		  act_rot: Variant, 
		  act_sock_idx: int, pas_stud_idx: int) -> void:
	_connect_uni(act_name, pas_name, act_rot, act_sock_idx, pas_stud_idx, false)

# ✅ 核心单点连接逻辑
func _connect_uni(act_name: String, pas_name: String,
				  act_rot: Variant,
				  act_idx: int, pas_idx: int,
				  is_skco: bool) -> void:
	var act_node := get_node_or_null(act_name) as Node3D
	var pas_node := get_node_or_null(pas_name) as Node3D
	
	if not act_node or not pas_node:
		push_error("BuilderGUI._connect_uni: 零件不存在 act=%s, pas=%s" % [act_name, pas_name])
		return
	
	# 获取数据 (严格区分点位索引作用域)
	var act_data: Array = _get_connection_data(act_name, is_skco)
	var pas_data: Array = _get_connection_data(pas_name, !is_skco)
	
	# ✅ 越界检查：中断执行
	if act_data.size() <= act_idx:
		push_error("BuilderGUI._connect_uni: ACT点位索引越界! part=%s idx=%d size=%d type=%s" % 
				   [act_name, act_idx, act_data.size(), "studs" if is_skco else "sockets"])
		return
		
	if pas_data.size() <= pas_idx:
		push_error("BuilderGUI._connect_uni: PAS点位索引越界! part=%s idx=%d size=%d type=%s" % 
				   [pas_name, pas_idx, pas_data.size(), "sockets" if is_skco else "studs"])
		return
	
	# 提取局部锚点坐标
	var act_local_anchor: Vector3 = (act_data[act_idx]["pos"] as Vector3)
	var pas_local_target: Vector3 = (pas_data[pas_idx]["pos"] as Vector3)
	
	# === Step 1: 解析并应用绝对姿态 ===
	var final_rot: Quaternion = _parse_rotation(act_rot)
	
	# === Step 2: 计算PAS目标世界坐标 ===
	var target_world_pos := pas_node.transform * pas_local_target
	
	# === Step 3: 单点平移补偿 ===
	var rotated_anchor := final_rot * act_local_anchor
	var final_pos := target_world_pos - rotated_anchor
	
	act_node.transform = Transform3D(final_rot, final_pos)
	
	var op_type := "skco" if is_skco else "stco"
	print(" %s: %s[%d] → %s[%d] | Pos: %s" % 
		  [op_type, act_name, act_idx, pas_name, pas_idx, final_pos])

#  旋转量解析器 (支持叉乘结果/多类型输入)
func _parse_rotation(rot_input: Variant) -> Quaternion:
	if rot_input is Quaternion:
		return rot_input
	elif rot_input is Basis:
		return rot_input.get_rotation_quaternion()
	elif rot_input is Transform3D:
		return rot_input.basis.get_rotation_quaternion()
	elif rot_input is Vector3:
		# 视为欧拉角 (XYZ顺序, 弧度制)
		return Quaternion.from_euler(rot_input)
	else:
		push_error("BuilderGUI._parse_rotation: 不支持的旋转类型 %s" % typeof(rot_input))
		return Quaternion.IDENTITY
