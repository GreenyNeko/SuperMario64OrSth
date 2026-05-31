extends Control

@export var panel: PanelContainer
@export var continueIcon: TextureRect
@export var option1: RichTextLabel
@export var option2: RichTextLabel
@export var select1: TextureRect
@export var select2: TextureRect
@export var textBoxTexts: Array[RichTextLabel]
@export var text: Array[String]
var progress = 0
var current = 0
var shiftTextBy = 0
var shiftSpeed = 140
var width = 0
var height = 0
var cooldown = 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	cooldown -= delta
	if not visible:
		return
	if shiftTextBy > 0:
		for textBoxText in textBoxTexts:
			textBoxText.position.y -= delta * shiftSpeed
		shiftTextBy -= delta * shiftSpeed
	if Input.is_action_just_pressed("A") or Input.is_action_just_pressed("B"):
		if cooldown > 0:
			return
		cooldown = 0.5
		progress += 1
		if progress >= text.size():
			visible = false
			LibSM64.play_sound_global(LibSM64.SOUND_MENU_MESSAGE_DISAPPEAR)
			return
		LibSM64.play_sound_global(LibSM64.SOUND_MENU_MESSAGE_NEXT_PAGE)
		shiftTextBy = height
		current = 1 - current
		if textBoxTexts[0].position.y <= 0 and textBoxTexts[1].position.y <= 0:
			textBoxTexts[current].position.y = height
			textBoxTexts[current].text = text[progress % text.size()]

func init(relX: float, relY: float, darkMode: bool, _width: float, _height: float):
	cooldown = 0.5
	anchor_left = relX
	anchor_top = relY
	panel.offset_right = _width
	panel.offset_bottom = _height
	shiftSpeed = _height * 2.
	width = _width
	height = _height
	textBoxTexts[0].position.y = 0
	textBoxTexts[1].position.y = _height
	textBoxTexts[0].text = text[0]
	textBoxTexts[1].text = text[1 % text.size()]
	progress = 0
	visible = true
	var newStylebox = StyleBoxFlat.new()
	var textColor = Color.BLACK
	if darkMode:
		newStylebox.bg_color = Color(0.0, 0.0, 0.0, 0.561)
		textColor = Color.WHITE		
	else:
		newStylebox.bg_color = Color(1.0, 1.0, 1.0, 0.561)
	panel.add_theme_stylebox_override("panel", newStylebox)
	for textBox in textBoxTexts:
		textBox.self_modulate = textColor
		continueIcon.self_modulate = textColor
	LibSM64.play_sound_global(LibSM64.SOUND_MENU_MESSAGE_APPEAR)
