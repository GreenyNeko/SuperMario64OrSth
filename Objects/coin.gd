extends Node3D

@export var charBody: CharacterBody3D
@export var redCoinOrder: int
@export var coinSprite: Sprite3D
@export var gravity: bool
@export_enum("yellow", "red", "blue") var coinType
var value = 1
var animSpeed = 8
var animTime = 0
var collected = false
var movingDirection = Vector3.ZERO
var air

var collectSound = [LibSM64.SOUND_GENERAL_COIN, LibSM64.SOUND_GENERAL_RED_COIN, LibSM64.SOUND_GENERAL_COIN]

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	value = [1,2,5][coinType]
	coinSprite.modulate = [Color.YELLOW,Color.RED,Color(0.471, 0.471, 1.0)][coinType]
	air = false

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	animTime += delta * animSpeed
	coinSprite.frame = int(animTime) % coinSprite.hframes
	if gravity:
		if charBody.is_on_floor():
			if air:
				LibSM64.play_sound(LibSM64.SOUND_GENERAL_COIN_DROP, charBody.global_position)
			air = false
		else:
			air = true
		charBody.velocity = movingDirection + Vector3(0, -9, 0)
		charBody.move_and_slide()

func onMarioCollect(area: Area3D) -> void:
	if not visible:
		return
	if not area.get_parent().is_in_group("player"):
		return
	var mario = area.get_parent() as LibSM64Mario
	if mario.health_wedges < 8:
		LibSM64.play_sound_global(LibSM64.SOUND_MENU_POWER_METER)
	LibSM64.mario_heal(mario.id, value*256)
	
	LibSM64.play_sound(collectSound[coinType], position)
	collected = true
	visible = false
	GameManager.Instance().onCollectCoins(value)
