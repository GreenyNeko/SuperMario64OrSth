extends Node

@export var mario: Node3D
@export var pauseMenu: Control
@export var continueSelection: Control
@export var exitCourseSelection: Control
@export var exitOption: Control
@export var optionMenu: Control
@export var menuOption1: RichTextLabel
@export var menuOption2: RichTextLabel
@export var skillTreeOption: Control
@export var skillTreeSelection: Control
@export var skillTreeMenu: Control

var paused = false
var keyDown = false
var canExit = false
var levelMusic
var musicTicks = 0
var selection = -1
var selectionMatrixUp = {0: 0, 1: 1, 2: 2}
var selectionMatrixDown = {0: 0, 1: 1, 2: 2}
var konamiActions = ["StickUp", "StickUp", "StickDown", "StickDown", "StickLeft", "StickRight", 
	"StickLeft", "StickRight", "B", "A"
]
var konamiProgress = 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if skillTreeMenu.visible:
		return
	if GameManager.Instance().cutscene:
		return
	if not paused:
		if Input.is_action_just_pressed("Start"):
			if keyDown:
				return
			keyDown = true
			get_tree().paused = true
			paused = true
			if paused:
				initPauseMenu()
			else:
				unpause()
		else:
			keyDown = false
	else:
		if Input.is_action_just_pressed("StickDown"):
			detectKonami("StickDown")
			skillTreeSelection.text = ""
			exitCourseSelection.text = ""
			continueSelection.text = ""
			var newSelection = selectionMatrixDown[selection]
			if newSelection != selection:
				LibSM64.play_sound_global(LibSM64.SOUND_MENU_CHANGE_SELECT)
			if newSelection == 2:
				skillTreeSelection.text = ">"
			elif newSelection == 1:
				exitCourseSelection.text = ">"
			else:
				continueSelection.text = ">"
			selection = newSelection
		elif Input.is_action_just_pressed("StickUp"):
			detectKonami("StickUp")
			skillTreeSelection.text = ""
			exitCourseSelection.text = ""
			continueSelection.text = ""
			var newSelection = selectionMatrixUp[selection]
			if newSelection != selection:
				LibSM64.play_sound_global(LibSM64.SOUND_MENU_CHANGE_SELECT)
			if newSelection == 2:
				skillTreeSelection.text = ">"
			elif newSelection == 1:
				exitCourseSelection.text = ">"
			else:
				continueSelection.text = ">"
			selection = newSelection
		if Input.is_action_just_pressed("B"):
			detectKonami("B")
		if Input.is_action_just_pressed("StickLeft"):
			detectKonami("StickLeft")
		if Input.is_action_just_pressed("StickRight"):
			detectKonami("StickRight")
		if (Input.is_action_just_pressed("Start") and not keyDown) or Input.is_action_just_pressed("A"):
			detectKonami("A")
			keyDown = true
			if GameManager.Instance().trollMenu.foundTrolls[TrollMenu.TROLL.PAPER_MARIO] and selection == 2:
				await get_tree().create_timer(0.1).timeout
				skillTreeMenu.enableSkillMenu = true
				skillTreeMenu.visible = true
				GameManager.Instance().trollMenu.unlock(TrollMenu.TROLL.LEVEL_UP)
				pauseMenu.visible = false
				paused = false
				return
			elif selection == 1:
				if GameManager.Instance().skippable:
					unpause()
					GameManager.Instance().skipLakituCutscene()
					return
				GameManager.Instance().switchToLevel(GameManager.Levels.CASTLE_INTERIOR, 1, GameManager.StartType.DEFAULT)
			unpause()
		if not Input.is_key_pressed(KEY_QUOTELEFT):
			keyDown = false

func unpause():
	pauseMenu.visible = false
	get_tree().paused = false
	paused = false
	LibSM64.play_sound_global(LibSM64.SOUND_MENU_PAUSE_2)

func initPauseMenu():
	LibSM64.play_sound_global(LibSM64.SOUND_MENU_PAUSE)
	menuOption1.text = "CONTINUE"
	menuOption2.text = "EXIT COURSE"
	if GameManager.Instance().skippable:
		selection = 0
		selectionMatrixUp[0] = 0
		selectionMatrixUp[1] = 0
		selectionMatrixUp[2] = 0
		selectionMatrixDown[0] = 1
		selectionMatrixDown[1] = 1
		selectionMatrixDown[2] = 1
		exitCourseSelection.text = ""
		continueSelection.text = ">"
		menuOption1.text = "CONTINUE"
		menuOption2.text = "SKIP CUTSCENE"
		pauseMenu.visible = true
		return
	canExit = true
	canExit = mario.action & LibSM64.ActionFlags.ACT_FLAG_AIR == 0
	canExit = canExit || (mario.action & LibSM64.ActionFlags.ACT_FLAG_BUTT_OR_STOMACH_SLIDE > 0)
	canExit = canExit && GameManager.Instance().currentLevel not in [GameManager.Levels.OUTSIDE_CASTLE, GameManager.Levels.CASTLE_INTERIOR, GameManager.Levels.GERMAN_ANTI]
	exitOption.visible = canExit
	selection = 0
	if selection == 2:
		skillTreeSelection.text = ">"
	elif selection == 1:
		exitCourseSelection.text = ">"
	else:
		continueSelection.text = ">"
	var state = 0
	if canExit:
		optionMenu.visible = true
		state |= 1
	if GameManager.Instance().trollMenu.foundTrolls[TrollMenu.TROLL.PAPER_MARIO]:
		skillTreeOption.visible = true
		optionMenu.visible = true
		state |= 2
		selection = 0
	if state == 0: #none?
		optionMenu.visible = false
		selectionMatrixUp[0] = 0
		selectionMatrixUp[1] = 0
		selectionMatrixUp[2] = 0
		selectionMatrixDown[0] = 0
		selectionMatrixDown[1] = 0
		selectionMatrixDown[2] = 0
	elif state == 1: # default
		selectionMatrixUp[0] = 0
		selectionMatrixUp[1] = 0
		selectionMatrixUp[2] = 0
		selectionMatrixDown[0] = 1
		selectionMatrixDown[1] = 1
		selectionMatrixDown[2] = 1
	elif state == 2: # skill tree only
		selectionMatrixUp[0] = 0
		selectionMatrixUp[1] = 0
		selectionMatrixUp[2] = 0
		selectionMatrixDown[0] = 2
		selectionMatrixDown[1] = 2
		selectionMatrixDown[2] = 2
	else: # all
		selectionMatrixUp[0] = 0
		selectionMatrixUp[1] = 2
		selectionMatrixUp[2] = 0
		selectionMatrixDown[0] = 2
		selectionMatrixDown[1] = 1
		selectionMatrixDown[2] = 1
	pauseMenu.visible = true
	
func detectKonami(action: String):
	if not canExit:
		return
	if action == konamiActions[konamiProgress]:
		konamiProgress += 1
	else:
		konamiProgress = 0
		if action == konamiActions[0]:
			konamiProgress = 1
	if konamiProgress >= 10:
		GameManager.Instance().trollMenu.unlock(TrollMenu.TROLL.KONAMI)
