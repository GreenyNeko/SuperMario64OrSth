extends Node

class_name AdvancedMario

signal dropObject
signal throwObject

enum CustomAction {
	DEFAULT,
	HOLD_LIGHT,
	HOLD_HEAVY,
}

@export var heavyHand: Node3D
@export var lightHand: Node3D
@export var MainMario: Node3D
@export var VisualMario:Node3D
var action
var initializd
var startGrab = false
var prevParent = null

var mapToHoldLight = {LibSM64.MARIO_ANIM_IDLE_HEAD_CENTER: LibSM64.MARIO_ANIM_IDLE_WITH_LIGHT_OBJ,
	LibSM64.MARIO_ANIM_IDLE_HEAD_LEFT: LibSM64.MARIO_ANIM_IDLE_WITH_LIGHT_OBJ,
	LibSM64.MARIO_ANIM_IDLE_HEAD_RIGHT: LibSM64.MARIO_ANIM_IDLE_WITH_LIGHT_OBJ,
	LibSM64.MARIO_ANIM_WALKING: LibSM64.MARIO_ANIM_WALK_WITH_LIGHT_OBJ,
	LibSM64.MARIO_ANIM_RUNNING: LibSM64.MARIO_ANIM_RUN_WITH_LIGHT_OBJ,
	LibSM64.MARIO_ANIM_SINGLE_JUMP: LibSM64.MARIO_ANIM_JUMP_WITH_LIGHT_OBJ,
	LibSM64.MARIO_ANIM_GENERAL_FALL: LibSM64.MARIO_ANIM_FALL_LAND_WITH_LIGHT_OBJ,
	LibSM64.MARIO_ANIM_SLIDE: LibSM64.MARIO_ANIM_STOP_SLIDE_LIGHT_OBJ,
}

var mapToHoldHeavy = {LibSM64.MARIO_ANIM_IDLE_HEAD_CENTER: LibSM64.MARIO_ANIM_IDLE_HEAVY_OBJ,
	LibSM64.MARIO_ANIM_IDLE_HEAD_LEFT: LibSM64.MARIO_ANIM_IDLE_HEAVY_OBJ,
	LibSM64.MARIO_ANIM_IDLE_HEAD_RIGHT: LibSM64.MARIO_ANIM_IDLE_HEAVY_OBJ,
	LibSM64.MARIO_ANIM_WALKING: LibSM64.MARIO_ANIM_WALK_WITH_HEAVY_OBJ,
	LibSM64.MARIO_ANIM_RUNNING: LibSM64.MARIO_ANIM_WALK_WITH_HEAVY_OBJ,
}

var cancelStatesLight = {LibSM64.ACT_DOUBLE_JUMP: LibSM64.ACT_JUMP,
	LibSM64.ACT_TRIPLE_JUMP: LibSM64.ACT_JUMP,
	LibSM64.ACT_JUMP_KICK: LibSM64.ACT_JUMP,
	LibSM64.ACT_LONG_JUMP: LibSM64.ACT_CROUCHING,
	LibSM64.ACT_SIDE_FLIP: LibSM64.ACT_JUMP,
	LibSM64.ACT_BACKFLIP: LibSM64.ACT_CROUCHING,
	LibSM64.ACT_CROUCH_SLIDE: LibSM64.ACT_CROUCHING,
	LibSM64.ACT_PUNCHING: LibSM64.ACT_IDLE,
	LibSM64.ACT_START_SLEEPING: LibSM64.ACT_IDLE,
}

var cancelStatesHeavy = {LibSM64.ACT_DOUBLE_JUMP: LibSM64.ACT_IDLE,
	LibSM64.ACT_TRIPLE_JUMP: LibSM64.ACT_IDLE,
	LibSM64.ACT_JUMP_KICK: LibSM64.ACT_IDLE,
	LibSM64.ACT_LONG_JUMP: LibSM64.ACT_CROUCHING,
	LibSM64.ACT_SIDE_FLIP: LibSM64.ACT_IDLE,
	LibSM64.ACT_BACKFLIP: LibSM64.ACT_CROUCHING,
	LibSM64.ACT_CROUCH_SLIDE: LibSM64.ACT_CROUCHING,
	LibSM64.ACT_PUNCHING: LibSM64.ACT_IDLE,
	LibSM64.ACT_START_SLEEPING: LibSM64.ACT_IDLE,
	LibSM64.ACT_JUMP: LibSM64.ACT_IDLE,
}

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	action = CustomAction.DEFAULT
	pass # Replace with function body.

func _physics_process(delta: float) -> void:
	if not initializd:
		return
	LibSM64.set_mario_angle(VisualMario.id, MainMario.quaternion)
	if not initializd:
		return
	if action == CustomAction.HOLD_LIGHT:
		if MainMario.forward_velocity > 4 and MainMario.action & LibSM64.ACT_FLAG_AIR == 0:
			MainMario.forward_velocity = 4
		if MainMario.action in [LibSM64.ACT_FALL_AFTER_STAR_GRAB, LibSM64.ACT_LEDGE_GRAB, LibSM64.ACT_LONG_JUMP, LibSM64.ACT_CROUCHING, LibSM64.ACT_GROUND_POUND, LibSM64.ACT_SOFT_BONK, LibSM64.ACT_GROUND_BONK, LibSM64.ACT_JUMP_KICK, LibSM64.ACT_STOMACH_SLIDE]:
			stopGrab()
		if MainMario.action in [LibSM64.ACT_PUNCHING,LibSM64.ACT_PUNCHING]:
			throw()
		if cancelStatesLight.has(MainMario.action):
			LibSM64.set_mario_action(MainMario.id, cancelStatesLight[MainMario.action])
	elif action == CustomAction.HOLD_HEAVY:
		if MainMario.forward_velocity > 1:
			MainMario.forward_velocity = 1
		if MainMario.action in [LibSM64.ACT_FALL_AFTER_STAR_GRAB, LibSM64.ACT_LEDGE_GRAB, LibSM64.ACT_LONG_JUMP, LibSM64.ACT_CROUCHING, LibSM64.ACT_GROUND_POUND, LibSM64.ACT_SOFT_BONK, LibSM64.ACT_GROUND_BONK, LibSM64.ACT_JUMP_KICK, LibSM64.ACT_STOMACH_SLIDE, LibSM64.ACT_BUTT_SLIDE]:
			throw()
		if MainMario.action in [LibSM64.ACT_PUNCHING,LibSM64.ACT_PUNCHING]:
			throw()
		if cancelStatesHeavy.has(MainMario.action):
			LibSM64.set_mario_action(MainMario.id, cancelStatesHeavy[MainMario.action])

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if not initializd:
		return
	#VisualMario.velocity = MainMario.velocity
	#LibSM64.set_mario_velocity(VisualMario.id, MainMario.velocity)
	#LibSM64.set_mario_forward_velocity(VisualMario.id, MainMario.forward_velocity)
	#VisualMario.forward_velocity = MainMario.forward_velocity
	#VisualMario.face_angle = MainMario.face_angle
	var mario: LibSM64Mario
	#mario.veloc
	#mario.
	#VisualMario.set_angle(MainMario.quaternion)
	#VisualMario.position = MainMario.position
	if startGrab:
		return
	VisualMario.anim_id = mapAnimation(MainMario.anim_id)
	VisualMario.anim_frame = MainMario.anim_frame

func mapAnimation(marioAction):
	if action == CustomAction.HOLD_LIGHT:
		if mapToHoldLight.has(marioAction):
			return mapToHoldLight[marioAction]
	if action == CustomAction.HOLD_HEAVY:
		if mapToHoldHeavy.has(marioAction):
			return mapToHoldHeavy[marioAction]
	return marioAction

func createMario():
	MainMario.create()
	VisualMario.create()

func interactCap(cap):
	MainMario.interact_cap(cap)
	VisualMario.interact_cap(cap)

func lateInit():
	MainMario.modelVisible = false
	VisualMario.disableInputs = true
	VisualMario.stationary = true
	LibSM64.set_mario_action(VisualMario.id, LibSM64.SOUND_ACTION_UNK3C)
	initializd = true

func setWaterLevel(height: float):
	LibSM64.set_mario_water_level(MainMario.id, height)
	LibSM64.set_mario_water_level(VisualMario.id, height)

func setAction(action: LibSM64.ActionFlags):
	LibSM64.set_mario_action(MainMario.id, action)

func setPosition(newPos: Vector3):
	MainMario.position = newPos

func grabLightObject(obj: Node3D):
	if action != CustomAction.DEFAULT or startGrab:
		return
	MainMario.modelVisible = false
	VisualMario.visible = true
	startGrab = true
	LibSM64.set_mario_animation(VisualMario.id, LibSM64.MARIO_ANIM_PICK_UP_LIGHT_OBJ)
	await get_tree().create_timer(0.75).timeout
	prevParent = obj.get_parent()
	prevParent.remove_child(obj)
	lightHand.add_child(obj)
	obj.position = Vector3(0,0,0)
	obj.rotation.y = -PI/2
	action = CustomAction.HOLD_LIGHT
	startGrab = false

func grabHeavyObject(obj: Node3D):
	if action != CustomAction.DEFAULT:
		return
	startGrab = true
	MainMario.modelVisible = false
	VisualMario.visible = true
	LibSM64.set_mario_animation(VisualMario.id, LibSM64.MARIO_ANIM_GRAB_HEAVY_OBJECT)
	await get_tree().create_timer(0.75).timeout
	prevParent = obj.get_parent()
	prevParent.remove_child(obj)
	heavyHand.add_child(obj)
	obj.position = Vector3(0,0,0)
	obj.rotation.y = 0
	action = CustomAction.HOLD_HEAVY
	startGrab = false

func throw():
	if action == CustomAction.DEFAULT or startGrab:
		return
	startGrab = true
	if action == CustomAction.HOLD_LIGHT:
		LibSM64.set_mario_animation(VisualMario.id, LibSM64.MARIO_ANIM_THROW_LIGHT_OBJECT)
	elif action == CustomAction.HOLD_HEAVY:
		LibSM64.set_mario_animation(VisualMario.id, LibSM64.MARIO_ANIM_HEAVY_THROW)
		LibSM64.set_mario_position(MainMario.id, MainMario.position - Vector3(-1,0,0).rotated(Vector3.UP,MainMario.rotation.y))
	else:
		startGrab = false
		return
	await get_tree().create_timer(0.75).timeout
	var obj
	var objPos
	if lightHand.get_child_count() > 0:
		obj = lightHand.get_child(0)
		objPos = obj.global_position
		lightHand.remove_child(obj)
	if heavyHand.get_child_count() > 0:
		obj = heavyHand.get_child(0)
		objPos = obj.global_position
		heavyHand.remove_child(obj)
	prevParent.add_child(obj)
	obj.global_position= objPos
	throwObject.emit()
	MainMario.modelVisible = true
	VisualMario.visible = false
	action = CustomAction.DEFAULT
	startGrab = false

func stopGrab():
	if action == CustomAction.DEFAULT or startGrab:
		return
	startGrab = true
	var obj
	var objPos
	if lightHand.get_child_count() > 0:
		obj = lightHand.get_child(0)
		objPos = obj.global_position
		lightHand.remove_child(obj)
	if heavyHand.get_child_count() > 0:
		obj = heavyHand.get_child(0)
		objPos = obj.global_position
		heavyHand.remove_child(obj)
	prevParent.add_child(obj)
	obj.global_position = objPos
	dropObject.emit()
	MainMario.modelVisible = true
	VisualMario.visible = false
	action = CustomAction.DEFAULT
	startGrab = false

func setInactive():
	MainMario.disableInputs = true
	VisualMario.visible = false

func setActive():
	MainMario.disableInputs = false
	VisualMario.visible = true

func setIgnoreInputs(ignoreInputs):
	MainMario.disableInputs = ignoreInputs

func setVisible(visibility: bool):
	MainMario.modelVisible = false
	VisualMario.visible = false
	if action in [CustomAction.HOLD_LIGHT, CustomAction.HOLD_HEAVY]:
		VisualMario.visible = visibility
		MainMario.modelVisible = false
	else:
		VisualMario.visible = false
		MainMario.modelVisible = visibility

func setHealth(amount: int):
	LibSM64.set_mario_health(MainMario.id, amount)

func heal(amount: int):
	LibSM64.mario_heal(MainMario.id, amount)

func setAngle(quat: Quaternion):
	if not initializd:
		return
	LibSM64.set_mario_angle(MainMario.id, quat)

func teleport(position: Vector3):
	MainMario.teleport(position)
	#VisualMario.telepot(position)

func setMarioAction(action: LibSM64.ActionFlags):
	LibSM64.set_mario_action(MainMario.id, action)

func setMarioVelocity(velocity: Vector3):
	LibSM64.set_mario_velocity(MainMario.id, velocity)

func getHealth():
	return MainMario.health

func getHealthWedges():
	return MainMario.health_wedges

func getPosition():
	return MainMario.position

func getGlobalPosition():
	return MainMario.global_position

func getAction():
	return MainMario.action

func takeDamage(amount: int):
	MainMario.health -= amount

func takeWedgeDamage(amount: int, subtype: int, sourcePos: Vector3):
	MainMario.take_damage(amount, subtype, sourcePos)
