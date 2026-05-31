extends Node3D

@export var sprite: Sprite3D
@export var animationSpeed: float
var animationTime = 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	animationTime += delta * animationSpeed
	if animationTime > sprite.hframes:
		animationTime = 0
	sprite.frame = int(animationTime)
