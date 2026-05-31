extends Node3D

@export var speed: float
@export var platformControls: Array[Node3D]
@export var targetPoints: Array[Node3D]
var forwardRot = true
var moveState = false
var rotationAmount = 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

func _enter_tree() -> void:
	GameManager.Instance().objectsToAdd.append(platformControls[0].get_child(1))
	GameManager.Instance().objectsToAdd.append(platformControls[1].get_child(1))

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if moveState:
		_handleMoveState(delta)
	else:
		_handleRotateState(delta)

func _handleMoveState(delta: float) -> void:
	if forwardRot:
		platformControls[1].position.y += delta * speed
		platformControls[0].position.y -= delta * speed
		var dist = abs(targetPoints[0].position.y - platformControls[0].position.y)
		if dist < 0.01:
			platformControls[1].position.y = targetPoints[1].position.y
			platformControls[0].position.y = targetPoints[0].position.y
			moveState = false
	else:
		platformControls[1].position.y -= delta * speed
		platformControls[0].position.y += delta * speed
		var dist = abs(targetPoints[1].position.y - platformControls[0].position.y)
		if dist < 0.01:
			platformControls[1].position.y = targetPoints[0].position.y
			platformControls[0].position.y = targetPoints[1].position.y
			moveState = false

func _handleRotateState(delta: float) -> void:
	for platform in platformControls:
		platform.rotation.x -= delta * speed
	rotationAmount -= delta * speed
	if rotationAmount <= -PI:
		rotationAmount = 0
		for platform in platformControls:
			if forwardRot:
				platform.rotation.x = -PI
			else:
				platform.rotation.x = -2*PI
		moveState = true
		forwardRot = not forwardRot
