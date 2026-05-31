extends Node3D

@export var starCamera: Camera3D
var spawning = false
var animTime
var hasSpawned = false
var startPosition
var fakeStarSpawned = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if not spawning:
		return
	animTime += delta
	if animTime < 1.75:
		var animatedVec = Vector3(-animTime,-pow(animTime-1,2)+1.5,0)
		position = animatedVec.rotated(Vector3.UP, global_rotation.y) + startPosition
	else:
		spawning = false
		hasSpawned = true
		GameManager.Instance().MarioCam.current = true
		GameManager.Instance().cutscene = false
		GameManager.Instance().advancedMario.setIgnoreInputs(false)

func onMarioCollect(area: Area3D):
	if not hasSpawned:
		return
	if not visible:
		return
	var mario = area.get_parent() as LibSM64Mario
	LibSM64.play_sound(LibSM64.SOUND_MENU_STAR_SOUND, global_position)
	LibSM64.set_mario_action(mario.id, LibSM64.ACT_FALL_AFTER_STAR_GRAB)
	await get_tree().create_timer(2.).timeout
	GameManager.Instance().TextBox.text.clear()
	GameManager.Instance().TextBox.text.append("You just collected something.. maybe.")
	GameManager.Instance().TextBox.init(0.2, 0.2, true, 400, 300)
	await GameManager.Instance().TextBox.hidden
	LibSM64.set_mario_action(mario.id, LibSM64.ACT_IDLE)
	GameManager.Instance().trollMenu.unlock(TrollMenu.TROLL.IMAGINARY_STAR)
	visible = false

func spawnFakeStar():
	if fakeStarSpawned:
		return
	fakeStarSpawned = true
	GameManager.Instance().cutscene = true
	GameManager.Instance().advancedMario.setIgnoreInputs(true)
	if hasSpawned:
		return
	startPosition = position
	spawning = true
	starCamera.current = true
	animTime = 0
	LibSM64.play_sound(LibSM64.SOUND_GENERAL_STAR_APPEARS, global_position)
