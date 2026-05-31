extends Node3D

@export var cameraRig: Node3D
@export var speed = 1.
var shouldRotate = false
var targetRotation = 0


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if shouldRotate:
		if abs(targetRotation - fmod(rotation.y, 2*PI)) > 0.03:
			rotation.y -= delta * speed

func doRotation():
	shouldRotate = true
	position = cameraRig.position
	rotation = cameraRig.rotation
	rotation.y -= PI + 0.1
	targetRotation = cameraRig.rotation.y
	visible = true
