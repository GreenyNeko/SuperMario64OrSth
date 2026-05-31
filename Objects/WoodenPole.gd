extends Node3D

signal poundedThreeTimes

@export var objectNode: Node3D
var cooldown = 0.5
var currCooldown = 0
var poundCount = 0

func _enter_tree() -> void:
	GameManager.Instance().objectsToAdd.append(objectNode)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	currCooldown -= delta

func onMarioLandOn(area: Area3D) -> void:
	if currCooldown > 0:
		return
	if not area.get_parent().is_in_group("player"):
		return
	var mario = area.get_parent() as LibSM64Mario
	if not mario.action in [LibSM64.ActionFlags.ACT_GROUND_POUND, LibSM64.ActionFlags.ACT_GROUND_POUND_LAND]:
		return
	position.y -= 0.66
	poundCount += 1
	LibSM64.play_sound(LibSM64.SOUND_GENERAL_POUND_WOOD_POST, global_position)
	if poundCount == 3:
		poundedThreeTimes.emit()
	currCooldown = cooldown
