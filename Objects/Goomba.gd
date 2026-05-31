extends Node3D

@export var scenematic: bool
@export var dropObject: PackedScene
@export var rigidBody: RigidBody3D
@export var animationPlayer: AnimationPlayer
@export var goombaModel: Node3D
var alive = true
var actionTime = 0
var marioId = -1
var missingRotation = 0
var attack = false
var speed = 0.01
var slowDown = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if scenematic:
		return
	if not alive:
		return
	if not animationPlayer.is_playing():
		animationPlayer.play("Walk")

func _physics_process(delta: float) -> void:
	if scenematic:
		return
	if not alive:
		return
	# gravity
	rigidBody.move_and_collide(Vector3.DOWN * 0.01)
	# AI
	AI(delta)

func AI(delta):
	if not alive:
		return
	if not (attack or slowDown) and GameManager.Instance().advancedMario.getPosition().distance_to(position) < 5:
		attack = true
		speed = 0
		var toMario = (GameManager.Instance().advancedMario.getGlobalPosition() - rigidBody.global_position).normalized()
		var angleToMario = rigidBody.global_basis.z.signed_angle_to(toMario, Vector3.UP)
		missingRotation = angleToMario
		rigidBody.move_and_collide(Vector3(0, 1, 0))
		LibSM64.play_sound(LibSM64.SOUND_OBJ_WIGGLER_JUMP, rigidBody.position)
	# AI
	if abs(missingRotation) > 0.05:
		rigidBody.rotation.y += missingRotation * delta
		missingRotation -= missingRotation * delta
		return
	elif not (attack or slowDown) and actionTime > 0:
		actionTime -= delta
		rigidBody.move_and_collide(0.01 * -Vector3.FORWARD.rotated(Vector3.UP, rigidBody.rotation.y))
		return
	elif attack or slowDown:
		if attack:
			speed += delta
		if slowDown:
			speed -= delta
		rigidBody.move_and_collide(min(speed, 0.03) * -Vector3.FORWARD.rotated(Vector3.UP, rigidBody.rotation.y))
		var toMario = (GameManager.Instance().advancedMario.getGlobalPosition() - rigidBody.global_position).normalized()
		var angleToMario = rigidBody.global_basis.z.signed_angle_to(toMario, Vector3.UP)
		rigidBody.rotation.y += min(delta*speed*PI*0.25*sign(angleToMario), angleToMario)
		if attack and GameManager.Instance().advancedMario.getPosition().distance_to(position) > 5:
			slowDown = true
			attack = false
		if slowDown and speed < 0.01:
			slowDown = false
		return
	var decision = GameManager.Instance().rng.randi_range(0, 7)
	if decision <= 2:
		actionTime = GameManager.Instance().rng.randf() * 1. + 1.
		missingRotation += PI*0.25
	elif decision <= 5:
		actionTime = GameManager.Instance().rng.randf() * 1. + 1.
		missingRotation -= PI*0.25
	elif decision == 6:
		rigidBody.move_and_collide(Vector3(0, 1, 0))
		missingRotation += PI*0.75
		LibSM64.play_sound(LibSM64.SOUND_OBJ_WIGGLER_JUMP, rigidBody.position)
	else:
		rigidBody.move_and_collide(Vector3(0, 1, 0))
		missingRotation -= PI*0.75
		LibSM64.play_sound(LibSM64.SOUND_OBJ_WIGGLER_JUMP, rigidBody.position)

func bounceOff(mario):
	if not alive:
		return
	goombaModel.scale = Vector3(1.25, 0.1, 1.25)
	onDeath()
	LibSM64.play_sound(LibSM64.SOUND_OBJ_STOMPED, rigidBody.global_position)
	LibSM64.set_mario_velocity(mario.id, Vector3(mario.velocity.x,15.,mario.velocity.z))
	visible = false

func onMarioInteract(area: Area3D):
	if scenematic:
		return
	if not area.get_parent().is_in_group("player"):
		return
	if not alive:
		return
	var mario = area.get_parent() as LibSM64Mario
	print("mario y", mario.global_position.y)
	print("goomba y", rigidBody.global_position.y)
	if mario.action & LibSM64.ActionFlags.ACT_FLAG_AIR > 0 and mario.global_position.y > rigidBody.global_position.y:
		bounceOff(mario)
	elif mario.action in [LibSM64.ActionFlags.ACT_GROUND_POUND, LibSM64.ActionFlags.ACT_GROUND_POUND_LAND,
		LibSM64.ActionFlags.ACT_SLIDE_KICK, LibSM64.ActionFlags.ACT_SLIDE_KICK_SLIDE, LibSM64.ActionFlags.ACT_JUMP_KICK,
		LibSM64.ActionFlags.ACT_CROUCH_SLIDE, LibSM64.ACT_DIVE, LibSM64.ACT_PUNCHING, LibSM64.ACT_MOVE_PUNCHING, 
		LibSM64.ACT_DIVE_SLIDE]:
			visible = false
			onDeath()
	else:
		if mario.invincibility_time > 0:
			return
		mario.take_damage(1, 0, rigidBody.position)

func onDeath():
	await get_tree().create_timer(0.5).timeout
	var loot = dropObject.instantiate(PackedScene.GEN_EDIT_STATE_INSTANCE)
	loot.gravity = true
	alive = false
	loot.movingDirection = Vector3.FORWARD.rotated(Vector3.UP, GameManager.Instance().rng.randf_range(0,TAU))
	get_parent().add_child(loot)
	loot.global_position = rigidBody.global_position + Vector3(0, 2, 0)
