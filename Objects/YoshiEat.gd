extends Node3D
@export var yoshiAnimationPlayer: AnimationPlayer
@export var egg: Node3D
var updateMario = false
var targetDir

func _process(delta: float) -> void:
	if not updateMario:
		return
	GameManager.Instance().advancedMario.setPosition(targetDir * 2. * delta)

func onDialogFinished():
	GameManager.Instance().cutscene = true
	var mario = GameManager.Instance().advancedMario.MainMario as LibSM64Mario
	mario.disableInputs = true
	LibSM64.set_mario_action(mario.id, LibSM64.ACT_UNKNOWN_0002020E)
	LibSM64.set_mario_animation(mario.id, LibSM64.MARIO_ANIM_IDLE_HEAD_CENTER)
	yoshiAnimationPlayer.play("eat")
	await yoshiAnimationPlayer.animation_finished
	LibSM64.set_mario_animation(mario.id, LibSM64.MARIO_ANIM_GROUND_BONK)
	yoshiAnimationPlayer.play("eatFinish")
	updateMario = true
	targetDir = get_child(0).global_position - mario.global_position
	await yoshiAnimationPlayer.animation_finished
	yoshiAnimationPlayer.play("swallow")
	updateMario = false
	mario.visible = false
	await yoshiAnimationPlayer.animation_finished
	yoshiAnimationPlayer.play("idle")
	egg.visible = true
	var eggRigidbody = egg.get_child(0) as RigidBody3D
	eggRigidbody.linear_velocity = targetDir.normalized() * 5.
	eggRigidbody.gravity_scale = 1.
	await get_tree().create_timer(5).timeout
	mario.disableInputs = false
	GameManager.Instance().cutscene = false
	mario.health = 0
	GameManager.Instance().trollMenu.unlock(TrollMenu.TROLL.YOSHI)
