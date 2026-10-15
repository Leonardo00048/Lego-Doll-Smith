# fdef_test.gd
extends Node

var y0 = Quaternion(Vector3.UP, deg_to_rad(0.0))
var y270 = Quaternion(Vector3.UP, deg_to_rad(-90.0))
var x270 = Quaternion(Vector3.RIGHT, deg_to_rad(-90.0))
var y90 = Quaternion(Vector3.UP, deg_to_rad(90.0))
var x90 = Quaternion(Vector3.RIGHT, deg_to_rad(90.0))
var y180 = Quaternion(Vector3.UP, deg_to_rad(180.0))
var z90 = Quaternion(Vector3.FORWARD, deg_to_rad(90.0))
var z270 = Quaternion(Vector3.FORWARD, deg_to_rad(270.0))

const hips_0000 := "res://mdef/hips_0000.gd"
const torso_0000 := "res://mdef/torso_0000.gd"

const upper_leg_left_0000 := "res://mdef/upper_leg_left_0000.gd"
const upper_leg_right_0000 := "res://mdef/upper_leg_right_0000.gd"
const lower_leg_left_0000 := "res://mdef/lower_leg_left_0000.gd"
const lower_leg_right_0000 := "res://mdef/lower_leg_right_0000.gd"

const foot_left_0000 := "res://mdef/foot_left_0000.gd"
const foot_right_0000 := "res://mdef/foot_right_0000.gd"

const upper_arm_left_0000 := "res://mdef/upper_arm_left_0000.gd"
const upper_arm_right_0000 := "res://mdef/upper_arm_right_0000.gd"
const lower_arm_left_0000 := "res://mdef/lower_arm_left_0000.gd"
const lower_arm_right_0000 := "res://mdef/lower_arm_right_0000.gd"

const hand_left_0000 := "res://mdef/hand_left_0000.gd"
const hand_right_0000 := "res://mdef/hand_right_0000.gd"

const head_0000 := "res://mdef/res://mdef/head_0000.gd.gd"

var _models: Dictionary = {}

func _ready():
	call_deferred("_run")

func _run():
	Opfu.set_part_scenes(PartIndex.PART_SCENES)
	Opfu.set_constructors({
		"pl": PlateConstructor.new(),
		"ti": TileConstructor.new(),
		"tebr": TechniqueBrickConstructor.new(),
		"brmo": BrickModifiedConstructor.new(),
		"bk": BracketConstructor.new(),
		"brro": BrickRoundConstructor.new(),
		"plmo": PlateModifiedConstructor.new(),
		"br": BrickConstructor.new(),
		"sl": SlopeConstructor.new(),
		"slin": SlopeInvertedConstructor.new(),
		"slcu": SlopeCurvedConstructor.new(),
		"teax": TechniqueAxleConstructor.new(),
		"tepi": TechniquePinConstructor.new()
	})

	# hips
	var hips_0000_0: Dictionary = Opfu.crmo(hips_0000)
	_models["hips"] = hips_0000_0
	Opfu.setmo(hips_0000_0, y0)

	# torso
	var torso_0000_0: Dictionary = Opfu.crmo(torso_0000)
	_models["torso"] = torso_0000_0

	# torso -- hips
	Opfu.inco(_models["torso"], _models["hips"], y0, 0, 2)


# LEGS AND FEET
	# upper_leg_left
	var upper_leg_left_0000_0: Dictionary = Opfu.crmo(upper_leg_left_0000)
	_models["upper_leg_left"] = upper_leg_left_0000_0

	# upper_leg_left -- hips
	Opfu.inco(_models["upper_leg_left"], _models["hips"], y0, 0, 0)

	# upper_leg_right
	var upper_leg_right_0000_0: Dictionary = Opfu.crmo(upper_leg_right_0000)
	_models["upper_leg_right"] = upper_leg_right_0000_0

	# upper_leg_right -- hips
	Opfu.inco(_models["upper_leg_right"], _models["hips"], y0, 0, 1)

	# lower_leg_left
	var lower_leg_left_0000_0: Dictionary = Opfu.crmo(lower_leg_left_0000)
	_models["lower_leg_left"] = lower_leg_left_0000_0

	# lower_leg_left -- upper_leg_left
	Opfu.inco(_models["lower_leg_left"], _models["upper_leg_left"], y0, 0, 1)

	# lower_leg_right
	var lower_leg_right_0000_0: Dictionary = Opfu.crmo(lower_leg_right_0000)
	_models["lower_leg_right"] = lower_leg_right_0000_0

	# lower_leg_right -- upper_leg_right
	Opfu.inco(_models["lower_leg_right"], _models["upper_leg_right"], y0, 0, 1)

	# foot_left
	var foot_left_0000_0: Dictionary = Opfu.crmo(foot_left_0000)
	_models["foot_left"] = foot_left_0000_0

	# foot_left -- lower_leg_left
	Opfu.inco(_models["foot_left"], _models["lower_leg_left"], y0, 0, 1)

	# foot_right
	var foot_right_0000_0: Dictionary = Opfu.crmo(foot_right_0000)
	_models["foot_right"] = foot_right_0000_0

	# foot_right -- lower_leg_right
	Opfu.inco(_models["foot_right"], _models["lower_leg_right"], y0, 0, 1)


# ARMS AND HANDS
	# upper_arm_left
	var upper_arm_left_0000_0: Dictionary = Opfu.crmo(upper_arm_left_0000)
	_models["upper_arm_left"] = upper_arm_left_0000_0

	# upper_arm_left -- torso
	Opfu.inco(_models["upper_arm_left"], _models["hips"], y0, 0, 1)

	# upper_arm_right
	var upper_arm_right_0000_0: Dictionary = Opfu.crmo(upper_arm_right_0000)
	_models["upper_arm_right"] = upper_arm_right_0000_0

	# upper_arm_right -- torso
	Opfu.inco(_models["upper_arm_right"], _models["hips"], y0, 0, 2)

	# lower_arm_left
	var lower_arm_left_0000_0: Dictionary = Opfu.crmo(lower_arm_left_0000)
	_models["lower_arm_left"] = lower_arm_left_0000_0

	# lower_arm_left -- upper_arm_left
	Opfu.inco(_models["lower_arm_left"], _models["upper_arm_left"], y0, 0, 1)

	# lower_arm_right
	var lower_arm_right_0000_0: Dictionary = Opfu.crmo(lower_arm_right_0000)
	_models["lower_arm_right"] = lower_arm_right_0000_0

	# lower_arm_right -- upper_arm_right
	Opfu.inco(_models["lower_arm_right"], _models["upper_arm_right"], y0, 0, 1)

	# hand_left
	var hand_left_0000_0: Dictionary = Opfu.crmo(hand_left_0000)
	_models["hand_left"] = hand_left_0000_0

	# hand_left -- lower_arm_left
	Opfu.inco(_models["hand_left"], _models["lower_arm_left"], y0, 0, 1)

	# hand_right
	var hand_right_0000_0: Dictionary = Opfu.crmo(hand_right_0000)
	_models["hand_right"] = foot_right_0000_0

	# hand_right -- lower_leg_right
	Opfu.inco(_models["hand_right"], _models["lower_arm_right"], y0, 0, 1)

	# 世界原点红点标记
	var dot := MeshInstance3D.new()
	var sphere := SphereMesh.new()
	sphere.radius = 2.0
	sphere.height = 4.0
	dot.mesh = sphere
	var mat := StandardMaterial3D.new()
	mat.albedo_color = Color.RED
	mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	mat.no_depth_test = true
	dot.material_override = mat
	get_tree().root.add_child(dot)
