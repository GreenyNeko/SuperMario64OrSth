extends Area3D

@export var tonyHawkSFX: AudioStreamPlayer3D
@export var tonyHawkUI: Control
@export var trickText: RichTextLabel
@export var scoreText: RichTextLabel
var playCutscene = false
var stateTimer = 0
var state = 0
var camHeight = 0
var trickStr = 0
var scoreMult = 0
var score = 0
var end = false
var actionTrickMappings = {
	LibSM64.ACT_LONG_JUMP_LAND: "LONG JUMP", LibSM64.ACT_TRIPLE_JUMP_LAND: "TRIPLE JUMP",
	LibSM64.ACT_JUMP_LAND: "OLLIE", LibSM64.ACT_BACKFLIP_LAND: "BACKFLIP", 
	LibSM64.ACT_DOUBLE_JUMP_LAND: "DOUBLE JUMP", LibSM64.ACT_GROUND_POUND_LAND: "GROUND POUND!?",
	LibSM64.ACT_FORWARD_ROLLOUT: "DIVE + ROLLOUT", LibSM64.ACT_DIVE: "DIVE",
	LibSM64.ACT_SIDE_FLIP_LAND: "SIDEFLIP",
}
var actionPointMappings = {
	LibSM64.ACT_LONG_JUMP_LAND: 475, LibSM64.ACT_TRIPLE_JUMP_LAND: 650,
	LibSM64.ACT_JUMP_LAND: 250, LibSM64.ACT_BACKFLIP_LAND: 800, 
	LibSM64.ACT_DOUBLE_JUMP_LAND: 150, LibSM64.ACT_GROUND_POUND_LAND: 1050,
	LibSM64.ACT_FORWARD_ROLLOUT: 1300, LibSM64.ACT_DIVE: 550,
	LibSM64.ACT_SIDE_FLIP_LAND: 875,
}

func _physics_process(delta):
	if end:
		score -= delta * 8000
		scoreText.text = "[center]" + str(int(score))
		if score <= 0:
			end = false
			tonyHawkUI.visible = false
	if not playCutscene:
		return
	stateTimer += delta
	score += 200 * delta
	scoreText.text = "[center]" + str(int(score)) + " X" + str(scoreMult)
	var mario = GameManager.Instance().advancedMario.MainMario
	LibSM64.set_mario_position(mario.id, mario.position - Vector3(0,0,delta * 3.))
	if stateTimer > 0.05:
		stateTimer = 0
		if state == 0:
			LibSM64.set_mario_animation(mario.id, LibSM64.MARIO_ANIM_LAND_FROM_SINGLE_JUMP)
			LibSM64.play_sound(LibSM64.SOUND_ACTION_TERRAIN_LANDING, mario.position)
			state = 1
			GameManager.Instance().MarioCam.position.y = camHeight + 0.25
		else:
			LibSM64.set_mario_animation(mario.id, LibSM64.MARIO_ANIM_GENERAL_FALL)
			LibSM64.play_sound(LibSM64.SOUND_OBJ_WALKING_WATER, mario.position)
			state = 0
			GameManager.Instance().MarioCam.position.y = camHeight - 0.25

func onMarioEnter(area: Area3D):
	if not area.get_parent().is_in_group("player"):
		return
	if playCutscene:
		return
	var mario = area.get_parent() as LibSM64Mario
	var currAction = mario.action
	if mario.action in [LibSM64.ACT_LEDGE_GRAB, LibSM64.ACT_LEDGE_CLIMB_FAST, LibSM64.ACT_LEDGE_CLIMB_SLOW_1, LibSM64.ACT_LEDGE_CLIMB_SLOW_2]:
		return
	if mario.velocity.z < -1:
		end = false
		trickStr = getTrickFromLanding(currAction)
		if not trickStr.is_empty(): 
			trickStr += " + "
		trickStr += "50-50 GRIND"
		scoreMult = trickStr.count("+") + 1
		score = getPointsFromLanding(currAction)
		tonyHawkUI.visible = true
		trickText.text = "[center]" + trickStr
		scoreText.text = "[center]" + str(int(score)) + " X" + str(scoreMult)
		camHeight = GameManager.Instance().MarioCam.position.y 
		mario.action = LibSM64.ACT_UNKNOWN_0002020E
		LibSM64.set_mario_animation(mario.id, LibSM64.MARIO_ANIM_GENERAL_FALL)
		playCutscene = true

func onMarioExit(area: Area3D):
	if not playCutscene:
		return
	if not area.get_parent().is_in_group("player"):
		return
	var mario = area.get_parent() as LibSM64Mario
	tonyHawkSFX.play()
	playCutscene = false
	GameManager.Instance().MarioCam.position.y = camHeight
	LibSM64.set_mario_position(mario.id, mario.position + Vector3(1.5,0,0))
	LibSM64.set_mario_action(mario.id, LibSM64.ACT_JUMP_LAND)
	trickText.text = "[center]" + trickStr + "+ [color=ffae00]LAKITU SKIP"
	scoreText.text = "[center]" + str(int(score) + 5000) + " X" + str(scoreMult + 1)
	score = score +5000 *(scoreMult +1)
	fadeTonyHawkOut()
	GameManager.Instance().trollMenu.unlock(TrollMenu.TROLL.LAKITU_SKIP)

func getTrickFromLanding(action):
	if actionTrickMappings.has(action):
		return actionTrickMappings[action]
	return ""

func getPointsFromLanding(action):
	if actionTrickMappings.has(action):
		return actionPointMappings[action]
	return 0

func fadeTonyHawkOut():
	await get_tree().create_timer(1.).timeout
	trickText.text = " "
	scoreText.text = "[center]" + str(int(score))
	await get_tree().create_timer(1.).timeout
	end = true
	
