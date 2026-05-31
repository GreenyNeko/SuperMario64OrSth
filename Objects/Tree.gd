extends Node3D

var onTip = false
var beingClimbed = false
var climbTime = 0
var climbDownTime = 0
var freshGrab = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if not beingClimbed:
		return
	var mario = GameManager.Instance().advancedMario.MainMario as LibSM64Mario
	if onTip:
		if mario.action == LibSM64.ACT_UNKNOWN_0002020E:
			if mario.anim_id != LibSM64.MARIO_ANIM_HANDSTAND_IDLE:
				LibSM64.set_mario_animation(mario.id, LibSM64.MARIO_ANIM_HANDSTAND_IDLE)
			if Input.is_action_pressed("StickDown"):
				LibSM64.set_mario_position(mario.id, mario.position - Vector3(0,delta * 2.5,0))
			if Input.is_action_just_pressed("A"):
				beingClimbed = false
				onTip = false
				LibSM64.set_mario_action(mario.id, LibSM64.ACT_BACKFLIP)
				mario.forward_velocity = 7
		return
	if mario.action == LibSM64.ACT_UNKNOWN_0002020E:
		if Input.is_action_just_pressed("Z"):
			beingClimbed = false
			LibSM64.set_mario_action(mario.id, LibSM64.ACT_SOFT_BONK)
			var dir = (mario.position - position).normalized()
			mario.forward_velocity = -7
		if Input.is_action_pressed("StickUp"):
			freshGrab = false
			if mario.anim_id != LibSM64.MARIO_ANIM_CLIMB_UP_POLE:
				LibSM64.set_mario_animation(mario.id, LibSM64.MARIO_ANIM_CLIMB_UP_POLE)
			LibSM64.set_mario_position(mario.id, mario.position + Vector3(0,delta * 3,0))
			climbTime += delta
		elif Input.is_action_pressed("StickDown"):
			if mario.anim_id != LibSM64.MARIO_ANIM_CLIMB_UP_POLE:
				LibSM64.set_mario_animation(mario.id, LibSM64.MARIO_ANIM_CLIMB_UP_POLE)
			LibSM64.set_mario_position(mario.id, mario.position - Vector3(0,delta * 3.,0))
			LibSM64.set_mario_angle(mario.id, Quaternion(Vector3.UP, mario.rotation.y + delta * 4.))
			climbDownTime += delta
			print(mario.position.y)
			print(global_position.y)
			if mario.global_position.y < global_position.y + 0.05:
				LibSM64.play_sound(LibSM64.SOUND_MARIO_UH, mario.position)
				LibSM64.set_mario_action(mario.id, LibSM64.ACT_JUMP_LAND)
		elif Input.is_action_pressed("StickLeft"):
			LibSM64.set_mario_angle(mario.id, Quaternion(Vector3.UP, mario.rotation.y + delta * 4.))
			#LibSM64.set_mario_face_angle(mario.id, mario.face_angle - delta * 8.)
		elif Input.is_action_pressed("StickRight"):
			LibSM64.set_mario_angle(mario.id, Quaternion(Vector3.UP, mario.rotation.y + delta * 4.))
			#LibSM64.set_mario_face_angle(mario.id, mario.face_angle - delta * 8.)
		elif Input.is_action_pressed("A"):
			beingClimbed = false
			#LibSM64.set_mario_angle(mario.id, Quaternion(Vector3.UP, mario.rotation.y + PI))
			LibSM64.set_mario_action(mario.id, LibSM64.ACT_JUMP)
			mario.forward_velocity = -14
		else:
			if mario.anim_id != LibSM64.MARIO_ANIM_IDLE_ON_POLE:
				LibSM64.set_mario_animation(mario.id, LibSM64.MARIO_ANIM_IDLE_ON_POLE)
		if climbTime > 0.5:
			LibSM64.play_sound(LibSM64.SOUND_ACTION_CLIMB_UP_TREE, mario.position)
			climbTime = 0
		if climbDownTime > 0.5:
			climbDownTime = 0
			LibSM64.play_sound(LibSM64.SOUND_ACTION_CLIMB_DOWN_TREE, mario.position)

func onMarioEnter(area: Area3D):
	if not area.get_parent().is_in_group("player"):
		return
	var mario = area.get_parent() as LibSM64Mario
	if GameManager.Instance().advancedMario.action != AdvancedMario.CustomAction.DEFAULT:
		return
	#mario.particle_flags = LibSM64.PARTICLE_LEAF
	if mario.action in [LibSM64.ACT_FREEFALL, LibSM64.ACT_PUNCHING, LibSM64.ACT_JUMP, LibSM64.ACT_DIVE, LibSM64.ACT_LONG_JUMP, LibSM64.ACT_SIDE_FLIP]:
		LibSM64.play_sound(LibSM64.SOUND_MARIO_WHOA, mario.position)
		mario.action = LibSM64.ACT_UNKNOWN_0002020E
		LibSM64.set_mario_animation(mario.id, LibSM64.MARIO_ANIM_GRAB_POLE_SHORT)
		beingClimbed = true
		freshGrab = true
		onTip = false
		LibSM64.set_mario_face_angle(mario.id, mario.face_angle + PI)
	elif mario.action == LibSM64.ACT_UNKNOWN_0002020E:
		onTip = false

func onMarioExit(area: Area3D):
	if not area.get_parent().is_in_group("player"):
		return
	var mario = area.get_parent() as LibSM64Mario
	if mario.action == LibSM64.ACT_UNKNOWN_0002020E and not freshGrab:
		LibSM64.set_mario_position(mario.id, mario.position + Vector3(0,1,0))
		LibSM64.play_sound(LibSM64.SOUND_MARIO_WHOA, mario.position)
		onTip = true
