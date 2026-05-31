extends Node3D

@export_enum("line", "circle") var formationType
@export var distance: float
var coinPrefab

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	coinPrefab = preload("uid://clcwmw71go86j")
	[_genrateLine, _generateCircle][formationType].call()

func _genrateLine():
	for i in range(5):
		var newCoin = coinPrefab.instantiate()
		newCoin.position = Vector3.FORWARD * (i - 2) * distance
		add_child(newCoin)

func _generateCircle():
	for i in range(8):
		var angle = PI/4 * i
		var newCoin = coinPrefab.instantiate()
		newCoin.position = Vector3.FORWARD.rotated(Vector3.UP,angle)  * distance
		add_child(newCoin)
