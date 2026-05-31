extends Node3D

signal postDialogEvent

@export var rotates: bool
@export var becomesTransparent: bool
@export_enum("Intro", "Trees", "Swim", "crouch", "Star Toad", "Yoshi", "Cannon Bob-Omb", "Spawn Bob-Omb",
	"Chain Chomp", "Punching", "C Buttons", "King's Decree", "Island Wingcap BoB", "Ledge Grab", "Signs",
	"Red Coins", "Heart", "Wing Cap", "Coin Ring Secrtes", "Toad WF"
)
var talkEvent: int
@export var collision: CollisionShape3D
@export var meshes: Array[MeshInstance3D]
@export_enum("Sign", "Toad", "Yoshi", "BobOmb") var NPCType
var marioNearby = false
var doRotate = false

const interactionSound = [LibSM64.SOUND_ACTION_READ_SIGN, LibSM64.SEQ_EVENT_TOAD_MESSAGE, LibSM64.SEQ_EVENT_SOLVE_PUZZLE, LibSM64.SOUND_OBJ_BOBOMB_BUDDY_TALK]
const soundType = [0, 1, 1, 0]

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

func _enter_tree() -> void:
	GameManager.Instance().objectsToAdd.append(collision)

func _physics_process(delta: float) -> void:	
	if becomesTransparent:
		var distance = global_position.distance_to(GameManager.Instance().advancedMario.getGlobalPosition())
		var alpha = 1.
		if distance > 5:
			alpha = 0.5
		for mesh in meshes:
			if mesh.mesh is ArrayMesh:
				mesh.mesh.surface_get_material(0).albedo_color.a = alpha
			else:
				mesh.mesh.material.albedo_color.a = alpha
	if rotates and doRotate:
		var toMario = (GameManager.Instance().advancedMario.getGlobalPosition() - global_position).normalized()
		var angleToMario = global_basis.z.signed_angle_to(toMario, Vector3.UP)
		rotation.y += delta * angleToMario * 2.
		if GameManager.Instance().dialogCooldown > 0:
			doRotate = false
	# nearby and not disabled
	if marioNearby and not GameManager.Instance().advancedMario.MainMario.disableInputs:
		# on ground
		if GameManager.Instance().advancedMario.getAction() & LibSM64.ActionFlags.ACT_FLAG_AIR == 0:
			# button press
			if Input.is_action_just_pressed("A") or Input.is_action_just_pressed("B"):
				if GameManager.Instance().dialogCooldown <= 0:
					doRotate = true
					if soundType[NPCType] == 0:
						LibSM64.play_sound_global(interactionSound[NPCType])
					else:
						var seq = LibSM64.get_current_background_music()
						LibSM64.stop_background_music(seq)
						LibSM64.play_music(LibSM64.SEQ_PLAYER_LEVEL, interactionSound[NPCType])
						handleMusic(seq)
					GameManager.Instance().talkCutscene(self, talkEvent)

func handleMusic(seq):
	await get_tree().create_timer(2).timeout
	LibSM64.stop_background_music(interactionSound[NPCType])
	LibSM64.play_music(LibSM64.SEQ_PLAYER_LEVEL, seq)

func onMarioEntered(area: Area3D) -> void:
	if not area.get_parent().is_in_group("player"):
		return
	marioNearby = true

func onMarioExited(area: Area3D) -> void:
	if not area.get_parent().is_in_group("player"):
		return
	marioNearby = false

func dialogDone():
	postDialogEvent.emit()
