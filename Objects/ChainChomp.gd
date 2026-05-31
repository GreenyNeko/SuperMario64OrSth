extends Node3D

@export var home: Vector3
@export var chainPieces: Array[Node3D]
@export var rigidBody: RigidBody3D
@export var isChained: bool
@export var radius: float
@export var animationPlayer: AnimationPlayer
var state = 0
var stateTime = 0
const STATE_MAX_TIME = [3, 2, 2]
const STATE_ANIMATIONS = ["lipflap", "lipflap", "attack"]
var mario: Node3D
var hopTime = 0
var cutscene = false
var targetAngle = 0
var oldPositions: Array[Vector3]
var posUpdateTime = 0
# TODO: 3s move, 2s rotate, 2s attack?

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	mario = GameManager.Instance().advancedMario.MainMario
	animationPlayer.play("lipflap")
	for i in range(len(chainPieces)):
		oldPositions.append(position)

func updateChain():
	if isChained:
		var dir = home - rigidBody.position
		var step = dir / 4
		for i in range(len(chainPieces)):
			chainPieces[i].position = home + step * i
	else:
		for i in range(len(chainPieces)):
			chainPieces[i].position = oldPositions[i]

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if posUpdateTime > 0:
		if not oldPositions.has(rigidBody.position):
			if oldPositions.size() > 4:
				oldPositions.remove_at(0)
			oldPositions.append(rigidBody.position)
		posUpdateTime = 0
	stateTime += delta
	updateChain()
	if cutscene:
		if state == 1:
			AIRotate(delta)
		return
	if stateTime > STATE_MAX_TIME[state]:
		stateTime = 0
		state = (state + 1) % 3
		animationPlayer.play(STATE_ANIMATIONS[state])
		if state == 2:
			LibSM64.play_sound(LibSM64.SOUND_GENERAL_CHAIN_CHOMP2, rigidBody.position)
	[AIMove, AIRotate, AIAttack][state].call(delta)

func enterCutscene():
	state = 0
	cutscene = true
	GameManager.Instance().cutscene = true
	GameManager.Instance().advancedMario.setIgnoreInputs(true)
	GameManager.Instance().advancedMario.MainMario.invincibility_time = 60
	animationPlayer.play("lipflap")
	rigidBody.gravity_scale = 1.0
	LibSM64.play_sound(LibSM64.SOUND_GENERAL_CHAIN_CHOMP1, rigidBody.position)
	rigidBody.linear_velocity = Vector3(8, 4., 3)
	rigidBody.linear_velocity += rigidBody.global_basis.z.normalized() * 3.
	targetAngle = rigidBody.rotation.y - PI/2.
	await get_tree().create_timer(1.).timeout
	# TODO: jump right
	LibSM64.play_sound(LibSM64.SOUND_GENERAL_CHAIN_CHOMP1, rigidBody.position)
	rigidBody.linear_velocity = Vector3(-8, 4., 3)
	rigidBody.linear_velocity += rigidBody.global_basis.z.normalized() * 3.
	targetAngle = rigidBody.rotation.y + PI*0.75
	await get_tree().create_timer(1.).timeout
	animationPlayer.play("attack")
	await get_tree().create_timer(3.).timeout
	# TODO: turn towards mario
	state = 1
	await get_tree().create_timer(2.).timeout
	isChained = false
	GameManager.Instance().cutscene = false
	GameManager.Instance().advancedMario.setIgnoreInputs(false)
	cutscene = false
	GameManager.Instance().advancedMario.MainMario.invincibility_time = 0
	GameManager.Instance().trollMenu.unlock(TrollMenu.TROLL.WHO_LET_THE_DOGS_OUT)

func onCollideMario(area: Area3D):
	if not area.get_parent().is_in_group("player"):
		return
	var _mario = area.get_parent() as LibSM64Mario
	if _mario.invincibility_time > 0:
		return
	_mario.take_damage(3, 0, rigidBody.position)

func AIMove(delta: float):
	rigidBody.gravity_scale = 1.0
	# hop towards mario's direction
	hopTime += delta
	if hopTime > 0.5:
		hopTime = 0
		LibSM64.play_sound(LibSM64.SOUND_GENERAL_CHAIN_CHOMP1, rigidBody.position)
		rigidBody.linear_velocity = Vector3(0, 2.5, 0)
		var homeToChomp = (rigidBody.global_position - global_position).normalized()
		var dot = homeToChomp.dot(rigidBody.basis.z)
		if rigidBody.position.distance_to(home) < radius or dot < 0. or not isChained:
			rigidBody.linear_velocity += rigidBody.global_basis.z.normalized() * 2.
		var toMario = (mario.global_position - rigidBody.global_position).normalized()
		var angleToMario = rigidBody.global_basis.z.signed_angle_to(toMario, Vector3.UP)
		var angleChange = min(angleToMario, PI*0.25)
		rigidBody.rotation.y += angleChange
		#rigidBody.move_and_collide(force)

func AIRotate(delta: float):
	rigidBody.gravity_scale = 1.0
	var toMario = (mario.global_position - rigidBody.global_position).normalized()
	var angleToMario = rigidBody.global_basis.z.signed_angle_to(toMario, Vector3.UP)
	rigidBody.rotation.y += delta * angleToMario * 2.

func AIAttack(delta: float):
	rigidBody.gravity_scale = 0.0
	var homeToChomp = (rigidBody.global_position - global_position).normalized()
	var dot = homeToChomp.dot(rigidBody.basis.z)
	if stateTime < 0.75:
		if rigidBody.position.distance_to(home) > radius and isChained:
			rigidBody.linear_velocity = Vector3(0, rigidBody.linear_velocity.y, 0)
		if rigidBody.position.distance_to(home) < radius or dot < 0. or not isChained:
			rigidBody.linear_velocity =	rigidBody.global_basis.z.normalized() * 30
	else:
		rigidBody.linear_velocity = Vector3(0, rigidBody.linear_velocity.y, 0)
	if stateTime > 1.5:
		rigidBody.gravity_scale = 1.
