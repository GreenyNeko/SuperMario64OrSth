extends MeshInstance3D

@export var collision: CollisionShape3D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

func _enter_tree() -> void:
	GameManager.Instance().objectsToAdd.append(collision)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func onChompEnter(area: Area3D):
	# area -> rigidbody -> chomp root
	if not area.get_parent().get_parent().is_in_group("ChainChomp"):
		return
	if not self:
		return
	var chomp = area.get_parent().get_parent()
	if chomp.state == 2:
		LibSM64.play_sound(LibSM64.SOUND_GENERAL_WALL_EXPLOSION, global_position)
		collision.queue_free()
		queue_free()
