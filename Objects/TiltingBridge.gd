extends MeshInstance3D

@export var gravity: float
var marioIsOnLeft = false
var marioIsOnRight = false
var timeTilting = 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	if timeTilting > 1.0:
		LibSM64.play_sound(LibSM64.SOUND_GENERAL_BOAT_TILT1, position)
		timeTilting = 0.
	if not marioIsOnLeft and not marioIsOnRight:
		if rotation.x != 0:
			timeTilting += delta
			rotation.x *= 0.99
		return
	var mario = GameManager.Instance().advancedMario.Mainmario
	if mario.action & LibSM64.ACT_FLAG_AIR != 0:
		return
	timeTilting += delta
	if marioIsOnLeft:
		rotation.x -= delta * gravity
	else:
		rotation.x += delta * gravity

func _enter_tree() -> void:
	GameManager.Instance().objectsToAdd.append(self)

func onMarioOnLeftSide(area: Area3D) -> void:
	if not area.get_parent().is_in_group("player"):
		return
	marioIsOnRight = false
	marioIsOnLeft = true

func onMarioOnRightSide(area: Area3D) -> void:
	if not area.get_parent().is_in_group("player"):
		return
	marioIsOnRight = true
	marioIsOnLeft = false


func marioLeft(area: Area3D) -> void:
	marioIsOnRight = false
	marioIsOnLeft = false
