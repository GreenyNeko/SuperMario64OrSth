extends Node3D

@export var goombaObject: PackedScene
@export var goombaCount: int
@export var spawnDistance: float
@export var heightOffset: float
var hasSpawned = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if hasSpawned:
		return
	var marioPos = GameManager.Instance().advancedMario.getPosition() as Vector3
	if marioPos.distance_to(position) < 20:
		hasSpawned = true
		var instanceRotation = rotation.y
		for i in range(3):
			var obj = goombaObject.instantiate()
			obj.position = Vector3.FORWARD.rotated(Vector3.UP, instanceRotation) * spawnDistance + Vector3.UP * heightOffset
			instanceRotation += PI/goombaCount
			add_child(obj)
		hasSpawned = true
