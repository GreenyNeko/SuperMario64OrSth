extends TextureRect

@export var voidOutMasks: Array[Control]
@export var whiteOut: Control
@export_flags ("FADE_OUT", "FADE_IN") var animFlags: int = 0
@export_enum("CIRCLE", "STAR", "MARIO", "BOWSER")
var fadeOutInMask: int = 0
var animStart = 0.0
var animTarget = 0.0
var animTime = 0.0
@export var playBackSpeed = 1.
var currMaterial

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	var dir = animTarget - animStart
	dir = dir/abs(dir)
	if (animTime >= animStart and animTime <= animTarget) or (animTime <= animStart and animTime >= animTarget):
		animTime += dir * delta * playBackSpeed
		if not currMaterial:
			return
		currMaterial.set_shader_parameter("animTime", animTime)
	else:
		if not currMaterial:
			return
		currMaterial.set_shader_parameter("enabledAnims", 0)

func _enableAnimation(id: int):
	animFlags = 1
	currMaterial.set_shader_parameter("enabledAnims", animFlags)
	currMaterial.set_shader_parameter("animTime", animTime)

func playWhiteIn(speed, color: Color):
	if currMaterial:
		currMaterial.set_shader_parameter("enabledAnims", 0)
	playBackSpeed = speed
	currMaterial = whiteOut.material
	currMaterial.set_shader_parameter("color", color)
	animStart = 1
	animTarget = 0
	animTime = animStart
	_enableAnimation(1)

func playWhiteOut(speed, color: Color):
	if currMaterial:
		currMaterial.set_shader_parameter("enabledAnims", 0)
	playBackSpeed = speed
	currMaterial = whiteOut.material
	currMaterial.set_shader_parameter("color", color)
	animStart = 0
	animTarget = 1
	animTime = animStart
	_enableAnimation(1)

### types are 0: CIRCLE, 1: STAR, 2: MARIO, 3: BOWSER, 4: FULL
func playFadeOut(speed, animateFrom: float, animateTo: float, type):
	if currMaterial:
		currMaterial.set_shader_parameter("enabledAnims", 0)
	playBackSpeed = speed
	fadeOutInMask = type
	animStart = animateFrom
	animTarget = animateTo
	animTime = animStart
	currMaterial = voidOutMasks[fadeOutInMask].material
	_enableAnimation(1)

func playFadeIn(speed, animateFrom: float, animateTo: float, type):
	if currMaterial:
		currMaterial.set_shader_parameter("enabledAnims", 0)
	playBackSpeed = speed
	fadeOutInMask = type
	animStart = animateFrom
	animTarget = animateTo
	animTime = animStart
	animFlags &= ~1
	currMaterial = voidOutMasks[fadeOutInMask].material
	_enableAnimation(1)
