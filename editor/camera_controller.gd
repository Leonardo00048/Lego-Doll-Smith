# CameraController.gd
extends Node3D

# === 配置参数 ===
const CAM_DEFAULT_POS := Vector3(0, 0, 600)
#const CAM_DEFAULT_ROT := Vector3.ZERO
const CAM_DEFAULT_ROT := Vector3(0.0, 0.0, 0.0)
const PAN_STEP := 50.0
const PAN_TWEEN_DURATION := 0.15
const ROT_SPEED := 45.0  # 度/秒

# === 内部状态 ===
var _camera: Camera3D
var _ui_layer: CanvasLayer
var _view_controls: GridContainer
var _pan_tween: Tween
var _rotating_y: float = 0.0

func _ready():
	_setup_camera()
	_create_ui()

# 📷 自动创建并配置摄像机
func _setup_camera():
	_camera = Camera3D.new()
	_camera.name = "DevCamera"
	_camera.position = CAM_DEFAULT_POS
	_camera.rotation_degrees = CAM_DEFAULT_ROT
	_camera.current = true
	_camera.set_process_input(false)
	add_child(_camera)

# 🖥️ 自动生成 UI 层与 2x5 视角控制按钮
func _create_ui():
	_ui_layer = CanvasLayer.new()
	_ui_layer.name = "CamUI_Layer"
	add_child(_ui_layer)
	
	_view_controls = GridContainer.new()
	_view_controls.columns = 5
	_view_controls.position = Vector2(20, 540)
	_ui_layer.add_child(_view_controls)
	
	var buttons := [
		{"text": "↑", "type": "pan", "dir": Vector3.FORWARD},
		{"text": "↓", "type": "pan", "dir": Vector3.BACK},
		{"text": "←", "type": "pan", "dir": Vector3.LEFT},
		{"text": "→", "type": "pan", "dir": Vector3.RIGHT},
		{"text": "",  "type": "empty"},
		
		{"text": "<",  "type": "rot_ccw"},
		{"text": ">",  "type": "rot_cw"},
		{"text": "R",  "type": "reset"},
		{"text": "+",  "type": "pan", "dir": Vector3.UP},
		{"text": "-",  "type": "pan", "dir": Vector3.DOWN}
	]
	
	for b in buttons:
		if b["type"] == "empty":
			var spacer := Control.new()
			spacer.custom_minimum_size = Vector2(40, 40)
			_view_controls.add_child(spacer)
			continue
		
		var btn := Button.new()
		btn.text = b["text"]
		btn.custom_minimum_size = Vector2(40, 40)
		
		match b["type"]:
			"pan":
				btn.gui_input.connect(_on_button_input.bind(b["dir"], "pan"))
			"rot_ccw":
				btn.gui_input.connect(_on_button_input.bind(-ROT_SPEED, "rot"))
			"rot_cw":
				btn.gui_input.connect(_on_button_input.bind(ROT_SPEED, "rot"))
			"reset":
				btn.pressed.connect(_reset_camera)
		
		_view_controls.add_child(btn)

# 🔘 统一处理按钮输入（支持按住连续旋转）
func _on_button_input(event: InputEvent, param: Variant, action_type: String):
	if event is InputEventMouseButton:
		if event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
			if action_type == "pan":
				_pan_smooth(param as Vector3)
			elif action_type == "rot":
				_start_rotation(param as float)
		else:
			if action_type == "rot":
				_stop_rotation()
	
	elif event is InputEventScreenTouch:
		if event.pressed:
			if action_type == "pan":
				_pan_smooth(param as Vector3)
			elif action_type == "rot":
				_start_rotation(param as float)
		else:
			if action_type == "rot":
				_stop_rotation()

# ️ 平滑平移摄像机
func _pan_smooth(direction: Vector3):
	if not _camera:
		return
	
	if _pan_tween and _pan_tween.is_valid():
		_pan_tween.kill()
	
	var target_pos := _camera.position + _camera.basis * direction * PAN_STEP
	
	_pan_tween = create_tween().set_trans(Tween.TRANS_LINEAR).set_ease(Tween.EASE_IN_OUT)
	_pan_tween.tween_property(_camera, "position", target_pos, PAN_TWEEN_DURATION)
	set_process(true)

# 🔄 启动连续 Y 轴旋转
func _start_rotation(speed: float):
	_rotating_y = speed
	set_process(true)

# ⏹️ 停止连续旋转
func _stop_rotation():
	_rotating_y = 0.0
	if (_pan_tween == null or not _pan_tween.is_valid()) and abs(_rotating_y) < 0.001:
		set_process(false)

#  每帧执行旋转更新
func _process(delta: float):
	if abs(_rotating_y) > 0.001:
		var new_y := _camera.rotation_degrees.y + _rotating_y * delta
		_camera.rotation_degrees = Vector3(0.0, new_y, 0.0)

# 🏠 一键复位摄像机
func _reset_camera():
	if not _camera:
		return
	
	if _pan_tween and _pan_tween.is_valid():
		_pan_tween.kill()
	
	_stop_rotation()
	_camera.position = CAM_DEFAULT_POS
	_camera.rotation_degrees = CAM_DEFAULT_ROT
	set_process(false)
