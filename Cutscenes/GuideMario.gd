extends Node3D

signal guidingFinished

var guiding = false

@export var guideNode: Node3D
@export var animationPlayer: AnimationPlayer

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if not guiding:
		return
	LibSM64.set_mario_position(GameManager.Instance().advancedMario.MainMario.id, guideNode.global_position)

func startGuideMario():
	guiding = true
	animationPlayer.play("successExit")
	await animationPlayer.animation_finished
	guiding = false
	guidingFinished.emit()
