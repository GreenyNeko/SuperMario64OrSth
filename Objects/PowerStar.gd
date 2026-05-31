extends Node3D

@export var id: int
@export var uncollectedStar: Node3D
@export var collectedStar: Node3D
@export var collected: bool
@export var rotationSpeed: float
@export var targetPosition: Vector3
@export var spins: bool

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	uncollectedStar.visible = not collected
	collectedStar.visible = collected

func _process(delta: float):
	if spins:
		rotation.y += delta * rotationSpeed
	uncollectedStar.visible = not collected
	collectedStar.visible = collected

func onMarioCollect(area: Area3D) -> void:
	if not visible:
		return
	if not area.get_parent().is_in_group("player"):
		return
	var mario = area.get_parent() as LibSM64Mario
	mario.invincibility_time = 60
	if mario.health_wedges < 8:
		LibSM64.play_sound_global(LibSM64.SOUND_MENU_POWER_METER)
	LibSM64.mario_heal(mario.id, 256*8)
	LibSM64.play_sound(LibSM64.SOUND_MENU_STAR_SOUND, position)
	LibSM64.stop_background_music(LibSM64.SEQ_LEVEL_GRASS)
	await get_tree().create_timer(0.016).timeout
	LibSM64.play_music(LibSM64.SEQ_PLAYER_LEVEL, LibSM64.SEQ_EVENT_CUTSCENE_COLLECT_STAR)
	LibSM64.set_mario_action(mario.id, LibSM64.ACT_FALL_AFTER_STAR_GRAB)
	collected = true
	visible = false
	GameManager.Instance().updateStarCounter(id)
	await get_tree().create_timer(5.).timeout
	GameManager.Instance().PostProcessingManager.playFadeOut(3, 0, 6, 1)
	await get_tree().create_timer(2.).timeout
	LibSM64.stop_background_music(LibSM64.SEQ_EVENT_CUTSCENE_COLLECT_STAR)
	GameManager.Instance().leaveLevel()
	GameManager.Instance().PostProcessingManager.playFadeIn(6, 6, 0, 0)
	mario.invincibility_time = 0
	
