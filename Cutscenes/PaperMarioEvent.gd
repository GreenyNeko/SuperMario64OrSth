extends Area3D

@export var paperMarioScene: Node3D
@export var marioAnim: LibSM64.MarioAnimID
@export var paperMarioCam: Camera3D
@export var audioStream: AudioStreamPlayer3D
@export var firstStrike: Control
@export var teleportMarioTo: Node3D
@export var paperMarioAnimator: AnimationPlayer
@export var marioAngle: float
@export var paperMarioUI: CanvasLayer
@export var battleUI: Control
var animationTime = 0
var startAnim = false
var returnPos
var updateMarioPos = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if not startAnim:
		return
	animationTime += delta
	firstStrike.anchor_left = -0.75 + min(1, animationTime)
	firstStrike.anchor_right = -0.25 + min(1, animationTime)
	if marioAnim != LibSM64.MARIO_ANIM_CREDITS_WAVING:
		GameManager.Instance().advancedMario.MainMario.anim_id = marioAnim
	if updateMarioPos:
		GameManager.Instance().advancedMario.MainMario.global_position = teleportMarioTo.global_position
		GameManager.Instance().advancedMario.MainMario.face_angle = marioAngle

func onMarioEnter(area: Area3D):
	if GameManager.Instance().trollMenu.foundTrolls[TrollMenu.TROLL.PAPER_MARIO]:
		return
	if startAnim:
		return
	if not area.get_parent().is_in_group("player"):
		return
	var mario = area.get_parent() as LibSM64Mario
	paperMarioUI.visible = true
	paperMarioScene.visible = true
	mario.face_angle = -PI/2
	mario.action = LibSM64.ACT_UNKNOWN_0002020E
	GameManager.Instance().advancedMario.VisualMario.visible = true
	returnPos = mario.global_position
	LibSM64.fadeout_background_music(LibSM64.SEQ_LEVEL_GRASS, 0.5)
	startAnim = true
	audioStream.play()
	await get_tree().create_timer(1.5).timeout
	GameManager.Instance().PostProcessingManager.playFadeOut(2.34, 0, 6, 1)
	await get_tree().create_timer(2.5).timeout
	firstStrike.visible = false
	updateMarioPos = true
	paperMarioCam.current = true
	GameManager.Instance().PostProcessingManager.playWhiteIn(0.3, Color.BLACK)
	await get_tree().create_timer(1.).timeout
	battleUI.visible = true
	paperMarioAnimator.play("play")
	await paperMarioAnimator.animation_finished
	await get_tree().create_timer(3.).timeout
	GameManager.Instance().PostProcessingManager.playWhiteOut(0.3, Color.BLACK)
	updateMarioPos = false
	await get_tree().create_timer(1.).timeout
	GameManager.Instance().MarioCam.current = true
	marioAnim = LibSM64.MARIO_ANIM_CREDITS_WAVING
	mario.action = LibSM64.ACT_JUMP
	mario.global_position = returnPos
	get_parent().visible = false
	get_parent().alive = false
	GameManager.Instance().advancedMario.VisualMario.visible = false
	paperMarioUI.visible = false
	audioStream.stop()
	GameManager.Instance().PostProcessingManager.playWhiteIn(0.3, Color.BLACK)
	await get_tree().create_timer(2.).timeout
	LibSM64.play_music(LibSM64.SEQ_PLAYER_LEVEL, LibSM64.SEQ_LEVEL_GRASS)
	paperMarioScene.visible = false
	GameManager.Instance().trollMenu.unlock(TrollMenu.TROLL.PAPER_MARIO)
	# hide everything go back to base game.
