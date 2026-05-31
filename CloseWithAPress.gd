extends Control


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	if not visible:
		return
	if Input.is_action_just_pressed("A"):
		LibSM64.play_sound_global(LibSM64.SOUND_MENU_MESSAGE_DISAPPEAR)
		set_visible(false)

func showUI():
	LibSM64.play_sound_global(LibSM64.SOUND_MENU_MESSAGE_APPEAR)
	visible = true
