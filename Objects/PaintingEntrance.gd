extends Area3D

@export var warpTo: GameManager.Levels
@export var warpPoint: int
@export var meshNode: Node3D
var nearby = false
var waveAnimTimer = 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	meshNode.mesh.material.set_shader_parameter("showWaves", false)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if nearby:
		waveAnimTimer += delta
		waveAnimTimer = fmod(waveAnimTimer, 3.)
		meshNode.mesh.material.set_shader_parameter("marioPos",  GameManager.Instance().advancedMario.getGlobalPosition() )
		meshNode.mesh.material.set_shader_parameter("fastWaveTimer", waveAnimTimer)

func onMarioEnterNear(area: Area3D) -> void:
	nearby = true
	waveAnimTimer = 0

func onMarioExitNear(area: Area3D) -> void:
	nearby = false
	waveAnimTimer = 0

func onMarioEnter(area: Area3D) -> void:
	if area.get_parent().is_in_group("player"):
		var mario = area.get_parent() as LibSM64Mario
		if mario.action in [LibSM64.ACT_DEATH_EXIT, LibSM64.ACT_EXIT_AIRBORNE, LibSM64.ACT_SPAWN_NO_SPIN_AIRBORNE, LibSM64.ACT_EXIT_LAND_SAVE_DIALOG]:
			return
		meshNode.mesh.material.set_shader_parameter("showWaves", true)
		meshNode.mesh.material.set_shader_parameter("marioPos",  GameManager.Instance().advancedMario.getGlobalPosition() )
		# TODO: zoom into painting fix camera
		# how to make mario pull the door?
		#LibSM64.set_mario_animation(mario.id, LibSM64.MARIO_ANIM_PULL_DOOR_WALK_IN)
		#LibSM64.set_mario_action(mario.id, LibSM64.ACT_PULLING_DOOR)
		#mario.action = LibSM64.ActionFlags.ACT_PULLING_DOOR
		LibSM64.play_sound_global(LibSM64.SOUND_MENU_STAR_SOUND)
		GameManager.Instance().PostProcessingManager.playWhiteOut(0.3333, Color.WHITE)
		mario.process_mode = Node.PROCESS_MODE_DISABLED
		await get_tree().create_timer(3.).timeout
		GameManager.Instance().switchToLevel(warpTo, warpPoint, GameManager.StartType.SPINNING)
