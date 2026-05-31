extends Node3D

@export var withCamera: Node3D
@export var withoutCamera: Node3D
@export var hasCamera: bool

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	withCamera.visible = hasCamera
	withoutCamera.visible = not hasCamera
