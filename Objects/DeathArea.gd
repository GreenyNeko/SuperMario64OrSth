extends Area3D

signal deathPlaneTouched()

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func onColliderEnter(object: Area3D):
	if object.is_in_group("player"):
		deathPlaneTouched.emit()
