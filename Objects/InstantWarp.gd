extends Area3D

@export var relativeToStart: Node3D
@export var relativeToEnd: Node3D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func onMarioEnter(area: Area3D):
	if not area.get_parent().is_in_group("player"):
		return
	GameManager.Instance().trollMenu.unlock(TrollMenu.TROLL.ENDLESS_SLIDE)
	var mario = area.get_parent() as LibSM64Mario
	var relPos = mario.global_position - relativeToStart.global_position
	mario.teleport(relPos + relativeToEnd.global_position)
