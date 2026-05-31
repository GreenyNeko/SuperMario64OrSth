extends Node3D

@export var dropObject: PackedScene
@export var FuseParticles: GPUParticles3D
@export var animPlayer: AnimationPlayer
@export var charBody: CharacterBody3D
@export var collision: Node3D
var marioNearby
var fuseTimer = 8
var aggro = false
var grabbed = false
var audioTimer = 0
var thrown = false


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	aggro = false
	grabbed = false
	thrown = false
	animPlayer.play("idle")
	animPlayer.speed_scale = 1.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	if not visible:
		return
	if marioNearby and GameManager.Instance().advancedMario.getAction() in [LibSM64.ACT_DIVE, LibSM64.ACT_PUNCHING, LibSM64.ACT_DIVE_SLIDE, LibSM64.ACT_MOVE_PUNCHING]:
		if GameManager.Instance().advancedMario.action == AdvancedMario.CustomAction.DEFAULT:
			GameManager.Instance().advancedMario.grabLightObject(charBody)
			aggro = true
			if not grabbed:
				GameManager.Instance().advancedMario.connect("throwObject", onThrow)
			grabbed = true
			FuseParticles.emitting = true
	AI(delta)

func _enter_tree() -> void:
	GameManager.Instance().objectsToAdd.append(collision)

func onMarioEntered(area: Area3D) -> void:
	if not area.get_parent().is_in_group("player"):
		return
	marioNearby = true

func onMarioExited(area: Area3D) -> void:
	if not area.get_parent().is_in_group("player"):
		return
	marioNearby = false

func onMarioEnterSight(area: Area3D) -> void:
	if not area.get_parent().is_in_group("player"):
		return
	animPlayer.speed_scale = 2.
	FuseParticles.emitting = true
	aggro = true

func AI(delta: float):
	if aggro:
		audioTimer -= delta
		if audioTimer <= 0:
			LibSM64.play_sound(LibSM64.SOUND_AIR_BOBOMB_LIT_FUSE, charBody.global_position)
			audioTimer = 0.0
		fuseTimer -= delta
		if fuseTimer <= 0:
			explode()
			visible = false
	if thrown:
		var vel = charBody.velocity * 0.99 + Vector3(0, -4.5, 0) 
		charBody.velocity = vel
		charBody.move_and_slide()
		if charBody.is_on_floor() or charBody.is_on_wall():
			explode()
			visible = false
		return
	if aggro and not grabbed:
		charBody.velocity = charBody.global_basis.z.normalized() * 10.
		var toMario = (GameManager.Instance().advancedMario.getGlobalPosition() - charBody.global_position).normalized()
		var angleToMario = charBody.global_basis.z.signed_angle_to(toMario, Vector3.UP)
		charBody.rotation.y += angleToMario * delta * 4.
		if not charBody.is_on_floor():
			charBody.velocity *= 0.25
		charBody.velocity += Vector3(0,-9,0)
		charBody.move_and_slide()
		return
	if not aggro:
		charBody.velocity = charBody.global_basis.z.normalized() * 2.
		charBody.rotation.y += PI*0.125 * delta
		if not charBody.is_on_floor():
			charBody.velocity *= 0.25
		charBody.velocity += Vector3(0,-9,0)
		charBody.move_and_slide()

func explode():
	animPlayer.play("explode")
	await animPlayer.animation_finished
	animPlayer.stop(true)
	LibSM64.play_sound(LibSM64.SOUND_GENERAL2_BOBOMB_EXPLOSION, charBody.global_position)
	FuseParticles.emitting = false
	var mario = GameManager.Instance().advancedMario.MainMario
	if abs(charBody.global_position.distance_to(mario.global_position)) < 3:
		GameManager.Instance().advancedMario.takeWedgeDamage(2, 1, charBody.global_position)
		var dir = charBody.global_position - mario.global_position
		dir.y = abs(dir.y+0.01)
		mario.velocity = dir.normalized() * 50.
	var loot = dropObject.instantiate(PackedScene.GEN_EDIT_STATE_INSTANCE)
	loot.gravity = true
	loot.movingDirection = Vector3.FORWARD.rotated(Vector3.UP, GameManager.Instance().rng.randf_range(0,TAU))
	get_parent().add_child(loot)
	loot.global_position = charBody.global_position + Vector3(0, 2, 0)

func onThrow():
	var mario =  GameManager.Instance().advancedMario.MainMario as LibSM64Mario
	var vel = mario.forward_velocity + 1
	var direction = -mario.basis.z.normalized().rotated(Vector3.UP, PI/2) * vel * 36. + Vector3(0, 24, 0)
	charBody.velocity = direction
	thrown = true
	
