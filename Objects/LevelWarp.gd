extends Node3D

@export var warpTo: GameManager.Levels
@export var warpPoint: int

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func onMarioEnter(area: Area3D):
	GameManager.Instance().PostProcessingManager.playFadeOut(3, 0, 6, 0)
	await get_tree().create_timer(2.).timeout
	LibSM64.play_sound_global(LibSM64.SOUND_MENU_ENTER_HOLE)
	GameManager.Instance().switchToLevel(warpTo, warpPoint, GameManager.StartType.SPINNING)
	GameManager.Instance().PostProcessingManager.playFadeIn(6, 6, 0, 0)
