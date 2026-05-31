extends Node3D

signal onLoaded()

@export var skyTexture: Texture2D
@export var waterLevelNode: Node3D
@export var spawnPoints: Array[Node3D]
@export var levelMusic: LibSM64.SeqId
@export var respawnArea: GameManager.Levels
@export var respawnPoint: int
@export var respawnVelocity: Vector3
@export var stars: Array[Node3D]
@export var deathArea: Node3D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func onFullyLoaded():
	onLoaded.emit()
