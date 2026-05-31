extends Control

class_name TrollMenu

enum TROLL {
	SKIP_INTRO,
	CONTROL_SETUP,
	POLE_EXPLANATION,
	MISSING_WATER_MOVEMENT,
	BROKEN_GROUND_TYPE,
	YOSHI,
	DID_NOT_DRAIN,
	LAKITU_SKIP,
	LAKITU_EXPLANATION,
	BOWSER_MSG,
	IMAGINARY_STAR,
	COIN_REQUIREMENT,
	WEIRD_DOORS,
	FAKE_SIGN,
	KONAMI,
	PAPER_MARIO,
	LEVEL_UP,
	WHO_LET_THE_DOGS_OUT,
	GERMAN_ANTI,
	DONT_SAVE_AND_QUIT,
	WRONG_PEACH,
	ENDLESS_SLIDE,
	ANOTHER_CASTLE,
}

@export var lockedIcon: Texture2D
@export var unlockedIcon: Texture2D
@export var trollButtons: Array[TextureRect]
@export var tabContainer: TabContainer
var cooldown = 0
var foundTrolls: Array[bool]

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	for TrollButton in trollButtons:
		foundTrolls.append(false)
	loadData()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if cooldown > 0:
		cooldown -= delta
	if Input.is_key_pressed(KEY_F1) and cooldown <= 0:
		cooldown = 0.5
		get_tree().paused = not get_tree().paused 
		visible = not visible
	if not visible:
		return
	if Input.is_action_just_pressed("StickLeft") or Input.is_action_just_pressed("DLeft"):
		cooldown = 0.5
		tabContainer.current_tab -= 1
	if Input.is_action_just_pressed("StickRight") or Input.is_action_just_pressed("DRight"):
		cooldown = 0.5
		tabContainer.current_tab += 1
func unlock(troll: TROLL):
	if foundTrolls[troll]:
		return
	foundTrolls[troll] = true
	trollButtons[troll].material.set_shader_parameter("buttonTexture", unlockedIcon)
	saveData()

func loadData():
	if not FileAccess.file_exists("data.bin"):
		return
	var file = FileAccess.open("data.bin", FileAccess.READ)
	for i in len(foundTrolls):
		foundTrolls[i] = file.get_8()
		if foundTrolls[i]:
			trollButtons[i].material.set_shader_parameter("buttonTexture", unlockedIcon)
func saveData():
	var file = FileAccess.open("data.bin", FileAccess.WRITE)
	for i in len(foundTrolls):
		file.store_8(foundTrolls[i])
