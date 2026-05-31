extends Node3D

@export var objectNodes: Array[Node3D]
@export var starRequirement: int
@export var coinRequirement: int
@export var starNumber: MeshInstance3D
@export var warpDoor: bool
@export var warpTo: GameManager.Levels
@export var warpPoint: int
@export var animationPlayer: AnimationPlayer
@export_enum("pull", "push", "slide double") var doorType
@export var lockId: int
@export var keyRequirement: int
@export_enum("Wood", "Metal", "Star", "Automatic") var soundType

var soundsOpen = [
	LibSM64.SOUND_GENERAL_OPEN_WOOD_DOOR,
	LibSM64.SOUND_GENERAL_OPEN_IRON_DOOR,
	LibSM64.SOUND_GENERAL_STAR_DOOR_OPEN,
	LibSM64.SOUND_GENERAL_SWITCH_DOOR_OPEN
]

var soundsClose = [
	LibSM64.SOUND_GENERAL_CLOSE_WOOD_DOOR,
	LibSM64.SOUND_GENERAL_CLOSE_IRON_DOOR,
	LibSM64.SOUND_GENERAL_STAR_DOOR_CLOSE,
	LibSM64.SOUND_GENERAL_SWITCH_DOOR_OPEN
]

var numbers = [
	"uid://5hbyqm8x2c3v", "uid://djrx01aj8sv8w", "", "uid://b664j2ypl4kxh"
]

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if starNumber:
		starNumber.mesh.surface_get_material(0).albedo_texture = load(numbers[starRequirement])

func _enter_tree() -> void:
	for obj in objectNodes:
		GameManager.Instance().objectsToAdd.append(obj)

func _exit_tree() -> void:
	pass
	#GameManager.Instance().ObjectSurfaceHandler.delete_surface_object(objectNode)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func onMarioInteractFront(area: Area3D) -> void:
	if not area.get_parent().is_in_group("player"):
		return
	var mario = area.get_parent() as LibSM64Mario
	if not mario.action in [LibSM64.ActionFlags.ACT_BRAKING, LibSM64.ActionFlags.ACT_BRAKING_STOP, LibSM64.ACT_WALKING, LibSM64.ACT_JUMP_LAND, LibSM64.ACT_JUMP_LAND_STOP, LibSM64.ACT_LONG_JUMP_LAND, LibSM64.ACT_LONG_JUMP_LAND_STOP, LibSM64.ACT_IDLE]:
		return
	if GameManager.Instance().lockedDoors[lockId]:
		if keyRequirement > 0:
			LibSM64.play_sound_global(LibSM64.SOUND_OBJ_BOWSER_INTRO_LAUGH)
			GameManager.Instance().TextBox.text.clear()
			GameManager.Instance().advancedMario.setIgnoreInputs(true)
			GameManager.Instance().cutscene = true
			GameManager.Instance().TextBox.text.clear()
			GameManager.Instance().TextBox.text.append("You need a key to open this door.")
			GameManager.Instance().TextBox.init(0.2, 0.2, true, 400, 300)
			await GameManager.Instance().TextBox.hidden
			GameManager.Instance().advancedMario.setIgnoreInputs(false)
			GameManager.Instance().cutscene = false
			return
		elif coinRequirement > 0 and (GameManager.Instance().coinCount < coinRequirement or GameManager.Instance().coinCount > coinRequirement):
			var requirementText = ""
			if GameManager.Instance().coinCount < 3:
				requirementText = "at least " + str(GameManager.Instance().coinCount + 1)
			else:
				requirementText = "exactly 3"
				GameManager.Instance().trollMenu.unlock(TrollMenu.TROLL.COIN_REQUIREMENT)
			LibSM64.play_sound_global(LibSM64.SOUND_OBJ_BOWSER_INTRO_LAUGH)
			GameManager.Instance().TextBox.text.clear()
			GameManager.Instance().advancedMario.setIgnoreInputs(true)
			GameManager.Instance().cutscene = true
			GameManager.Instance().TextBox.text.clear()
			GameManager.Instance().TextBox.text.append("It takes the power of " + requirementText + " coins to open this door.")
			GameManager.Instance().TextBox.init(0.2, 0.2, true, 400, 300)
			await GameManager.Instance().TextBox.hidden
			GameManager.Instance().advancedMario.setIgnoreInputs(false)
			GameManager.Instance().cutscene = false
			return
		elif GameManager.Instance().starCount < starRequirement:
			LibSM64.play_sound_global(LibSM64.SOUND_OBJ_BOWSER_INTRO_LAUGH)
			GameManager.Instance().TextBox.text.clear()
			GameManager.Instance().advancedMario.setIgnoreInputs(true)
			GameManager.Instance().cutscene = true
			GameManager.Instance().TextBox.text.clear()
			var missing = starRequirement - GameManager.Instance().starCount
			GameManager.Instance().TextBox.text.append("It takes the power of " + str(starRequirement) + " Stars to open this door. You need " + str(missing) + " more Stars.")
			GameManager.Instance().TextBox.init(0.2, 0.2, true, 400, 300)
			await GameManager.Instance().TextBox.hidden
			GameManager.Instance().advancedMario.setIgnoreInputs(false)
			GameManager.Instance().cutscene = false
			return
		else:
			GameManager.Instance().TextBox.text.clear()
			GameManager.Instance().advancedMario.setIgnoreInputs(true)
			GameManager.Instance().cutscene = true
			GameManager.Instance().TextBox.text.clear()
			GameManager.Instance().TextBox.text.append("Reacting to the Star power, the door slowly opens.")
			GameManager.Instance().TextBox.init(0.2, 0.2, true, 400, 300)
			await GameManager.Instance().TextBox.hidden
			GameManager.Instance().advancedMario.setIgnoreInputs(false)
			GameManager.Instance().cutscene = false
			GameManager.Instance().lockedDoors[lockId] = false
	if GameManager.Instance().advancedMario.action != AdvancedMario.CustomAction.DEFAULT:
		return
	LibSM64.play_sound(soundsOpen[soundType], position)
	if doorType == 1:
		animationPlayer.play("door/openreverse")
	elif doorType == 2:
		animationPlayer.play("openClosedoor")
	else:
		animationPlayer.play("door/open")
	if not warpDoor:
		return
	GameManager.Instance().advancedMario.setIgnoreInputs(true)
	GameManager.Instance().PostProcessingManager.playFadeOut(3., 0, 6, 0)
	await get_tree().create_timer(2.).timeout
	GameManager.Instance().switchToLevel(warpTo, warpPoint, GameManager.StartType.DEFAULT)
	GameManager.Instance().PostProcessingManager.playFadeIn(6., 6, 0, 0)
	GameManager.Instance().advancedMario.setIgnoreInputs(false)
	GameManager.Instance().trollMenu.unlock(TrollMenu.TROLL.WEIRD_DOORS)

func onMarioInteractBack(area: Area3D) -> void:
	if not area.get_parent().is_in_group("player"):
		return
	var mario = area.get_parent() as LibSM64Mario
	if not mario.action in [LibSM64.ActionFlags.ACT_BRAKING, LibSM64.ActionFlags.ACT_BRAKING_STOP, LibSM64.ACT_WALKING, LibSM64.ACT_JUMP_LAND, LibSM64.ACT_JUMP_LAND_STOP, LibSM64.ACT_LONG_JUMP_LAND, LibSM64.ACT_LONG_JUMP_LAND_STOP, LibSM64.ACT_IDLE]:
		return
	if GameManager.Instance().lockedDoors[lockId]:
		if keyRequirement > 0:
			LibSM64.play_sound_global(LibSM64.SOUND_OBJ_BOWSER_INTRO_LAUGH)
			GameManager.Instance().TextBox.text.clear()
			GameManager.Instance().advancedMario.setIgnoreInputs(true)
			GameManager.Instance().cutscene = true
			GameManager.Instance().TextBox.text.clear()
			GameManager.Instance().TextBox.text.append("You need a key to open this door.")
			GameManager.Instance().TextBox.init(0.2, 0.2, true, 400, 300)
			await GameManager.Instance().TextBox.hidden
			GameManager.Instance().advancedMario.setIgnoreInputs(false)
			GameManager.Instance().cutscene = false
			return
		elif coinRequirement > 0 and (GameManager.Instance().coinCount < coinRequirement or GameManager.Instance().coinCount > coinRequirement):
			var requirementText = ""
			if GameManager.Instance().coinCount < 3:
				requirementText = "at least " + str(GameManager.Instance().coinCount + 1)
			else:
				requirementText = "exactly 3"
				GameManager.Instance().trollMenu.unlock(TrollMenu.TROLL.COIN_REQUIREMENT)
			LibSM64.play_sound_global(LibSM64.SOUND_OBJ_BOWSER_INTRO_LAUGH)
			GameManager.Instance().TextBox.text.clear()
			GameManager.Instance().advancedMario.setIgnoreInputs(true)
			GameManager.Instance().cutscene = true
			GameManager.Instance().TextBox.text.clear()
			GameManager.Instance().TextBox.text.append("It takes the power of " + requirementText + " coins to open this door.")
			GameManager.Instance().TextBox.init(0.2, 0.2, true, 400, 300)
			await GameManager.Instance().TextBox.hidden
			GameManager.Instance().advancedMario.setIgnoreInputs(false)
			GameManager.Instance().cutscene = false
			GameManager.Instance().lockedDoors[lockId] = false
			return
		elif GameManager.Instance().starCount < starRequirement:
			LibSM64.play_sound_global(LibSM64.SOUND_OBJ_BOWSER_INTRO_LAUGH)
			GameManager.Instance().TextBox.text.clear()
			GameManager.Instance().advancedMario.setIgnoreInputs(true)
			GameManager.Instance().cutscene = true
			GameManager.Instance().TextBox.text.clear()
			var missing = starRequirement - GameManager.Instance().starCount
			GameManager.Instance().TextBox.text.append("It takes the power of " + str(starRequirement) + " Stars to open this door. You need " + str(missing) + " more Stars.")
			GameManager.Instance().TextBox.init(0.2, 0.2, true, 400, 300)
			await GameManager.Instance().TextBox.hidden
			GameManager.Instance().advancedMario.setIgnoreInputs(false)
			GameManager.Instance().cutscene = false
			return
		else:
			GameManager.Instance().TextBox.text.clear()
			GameManager.Instance().advancedMario.setIgnoreInputs(true)
			GameManager.Instance().cutscene = true
			GameManager.Instance().TextBox.text.clear()
			GameManager.Instance().TextBox.text.append("Reacting to the Star power, the door slowly opens.")
			GameManager.Instance().TextBox.init(0.2, 0.2, true, 400, 300)
			await GameManager.Instance().TextBox.hidden
			GameManager.Instance().advancedMario.setIgnoreInputs(false)
			GameManager.Instance().cutscene = false
			GameManager.Instance().lockedDoors[lockId] = false
	if GameManager.Instance().advancedMario.action != AdvancedMario.CustomAction.DEFAULT:
		return
	LibSM64.play_sound(soundsOpen[soundType], position)
	if doorType == 1:
		animationPlayer.play("door/open")
	elif doorType == 2:
		animationPlayer.play("openClose")
	else:
		animationPlayer.play("door/openreverse")
	if not warpDoor:
		return
	if not warpDoor:
		return
	GameManager.Instance().advancedMario.setIgnoreInputs(true)
	GameManager.Instance().PostProcessingManager.playFadeOut(3, 0, 6, 0)
	await get_tree().create_timer(2.).timeout
	GameManager.Instance().switchToLevel(warpTo, warpPoint, GameManager.StartType.DEFAULT)
	GameManager.Instance().PostProcessingManager.playFadeIn(6, 6, 0, 0)
	GameManager.Instance().advancedMario.setIgnoreInputs(false)
	GameManager.Instance().trollMenu.unlock(TrollMenu.TROLL.WEIRD_DOORS)
