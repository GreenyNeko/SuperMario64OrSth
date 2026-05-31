extends Node

@export var videoPlayer: VideoStreamPlayer 
var nearButton = 0
var progress = 0
var requiredActions = ["JUMP", "JUMP", "PUNCH", "CAMERA_RIGHT", "WALK", "CROUCH", "CROUCH", "CAMERA_LEFT", "JUMP", "PUNCH", "PUNCH"]
var action = ""
var cooldown = 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if cooldown > 0:
		cooldown -= delta
	if nearButton > 0:
		if GameManager.Instance().advancedMario.MainMario.action in [LibSM64.ACT_PUNCHING, LibSM64.ACT_MOVE_PUNCHING]:
			if cooldown <= 0:
				cooldown = 0.5
				if nearButton == 1:
					videoPlayer.play()
				elif nearButton == 2:
					videoPlayer.paused = not videoPlayer.paused
	detectActions()

func onMarioEnterPlayButton(area: Area3D):
	nearButton = 1

func onMarioExitPlaybutton(area: Area3D):
	nearButton = 0

func onMarioEnterPauseButton(area: Area3D):
	nearButton = 2

func onMarioLeavePauseButton(area: Area3D):
	nearButton = 0

func detectActions():
	var marioAction = GameManager.Instance().advancedMario.MainMario.action
	if marioAction == LibSM64.ACT_JUMP:
		action = "JUMP"
	elif marioAction == LibSM64.ACT_WALKING:
		action = "WALK"
	elif marioAction == LibSM64.ACT_PUNCHING:
		action = "PUNCH"
	elif marioAction == LibSM64.ACT_CROUCHING:
		action = "CROUCH"
	elif marioAction == LibSM64.ACT_IDLE:
		if action == "":
			pass
		elif action == requiredActions[progress]:
			progress += 1
			action = ""
			if progress >= len(requiredActions):
				LibSM64.play_music(LibSM64.SEQ_PLAYER_LEVEL, LibSM64.SEQ_EVENT_SOLVE_PUZZLE)
				GameManager.Instance().switchToLevel(GameManager.Levels.CASTLE_INTERIOR, 1, GameManager.StartType.DEFAULT)
	if Input.is_action_just_pressed("CLeft"):
		action = "CAMERA_RIGHT"
		if action == requiredActions[progress]:
			progress += 1
			action = ""
		else:
			progress = 0
	if Input.is_action_just_pressed("CRight"):
		action = "CAMERA_LEFT"
		if action == requiredActions[progress]:
			progress += 1
			action = ""
		else:
			progress = 0
