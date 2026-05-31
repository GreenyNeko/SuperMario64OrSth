extends TextureRect

@export var blinkingSpeed: float
var timer = 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	timer = blinkingSpeed
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	timer -= delta
	if timer < 0:
		visible = not visible
		timer = blinkingSpeed
