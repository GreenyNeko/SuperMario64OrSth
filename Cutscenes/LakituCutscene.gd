extends Area3D

@export var behindscenesLakitus: Node3D
@export var lakituSpeed: float
@export var cutsceneLakitu: Node3D
var updateLakitu = false
var lakituTargetStartPos
var missingRotation
var estimatedTime
var flyInSpeed = 6.

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if not updateLakitu:
		return
	var flightVec = (lakituTargetStartPos - cutsceneLakitu.global_position)
	if abs(flightVec.length()) > 0.1:
		cutsceneLakitu.position += flightVec.normalized() * delta * lakituSpeed * flyInSpeed
		cutsceneLakitu.get_child(0).rotation.y += missingRotation / estimatedTime * delta
	elif cutsceneLakitu.rotation.y > -PI:
		cutsceneLakitu.position = lakituTargetStartPos
		cutsceneLakitu.rotation.y -= delta * lakituSpeed
	else:
		print(flightVec, " ", flightVec.length(), " ", cutsceneLakitu.global_position, " ", lakituTargetStartPos)
		updateLakitu = false

func onMarioEnter(area: Area3D) -> void:
	if not area.get_parent().is_in_group("player"):
		return
	var mario = area.get_parent() as LibSM64Mario
	if GameManager.Instance().trollMenu.foundTrolls[TrollMenu.TROLL.LAKITU_EXPLANATION]:
		return
	startCutscene(mario)

func startCutscene(mario: LibSM64Mario):
	if mario.action == LibSM64.ACT_LEDGE_GRAB:
		LibSM64.set_mario_action(mario.id, LibSM64.ACT_LEDGE_CLIMB_FAST)
	GameManager.Instance().cutscene = true
	GameManager.Instance().advancedMario.setIgnoreInputs(true)
	mario.velocity = Vector3.ZERO
	await get_tree().create_timer(1.).timeout
	updateLakitu = true
	var forward = -mario.transform.basis.z
	behindscenesLakitus.position = mario.position
	lakituTargetStartPos = -forward.normalized() + mario.global_position + Vector3(0.9, 1.25, 0)
	estimatedTime = (lakituTargetStartPos - cutsceneLakitu.global_position).length() / (lakituSpeed * flyInSpeed)
	var angle = mario.rotation.y - cutsceneLakitu.get_child(0).rotation.y
	var counterAngle = TAU - abs(angle)
	print(rad_to_deg(mario.global_rotation.y), " ", rad_to_deg(cutsceneLakitu.rotation.y), " ", rad_to_deg(angle), " ", rad_to_deg(counterAngle))
	if abs(angle) < abs(counterAngle):
		missingRotation = angle - PI*0.5
	else:
		missingRotation = counterAngle - PI*0.5
	LibSM64.play_music(LibSM64.SEQ_PLAYER_LEVEL, LibSM64.SEQ_EVENT_CUTSCENE_LAKITU)
	# TODO: add the other lakitus
	behindscenesLakitus.visible = true
	await get_tree().create_timer(estimatedTime + 2.).timeout
	var textBox = GameManager.Instance().TextBox
	textBox.text.clear()
	textBox.text.append("Good afternoon. The Lakitu Bros., here, reporting live from- Hm?")
	textBox.text.append("If I'm in front who is filming right now? Sure, let's have some behidn the scenes action.")
	textBox.init(0.2, 0.2, true, 400, 300)
	await textBox.hidden
	LibSM64.stop_background_music(LibSM64.SEQ_EVENT_CUTSCENE_LAKITU)
	LibSM64.play_sound_global(LibSM64.SOUND_MENU_CAMERA_BUZZ)
	cutsceneLakitu.get_child(0).get_child(-1).current = true
	await get_tree().create_timer(0.5).timeout
	textBox.text.clear()
	textBox.text.append("You can see... That's Mario cam Lakitu, cutscene Lakitu, close camera Lakitu.")
	textBox.text.append("Anyways, camera works as usual, there's no close, 1st person or Mario cam.")
	textBox.text.append("D-pad < > pans the camera continuously, D-pad ^ to look in Mario's direction.")
	textBox.text.append("D-pad _ to lock to a cardinal/ordinal direction.")
	textBox.text.append("Now back to the action.")
	textBox.init(0.2, 0.2, true, 400, 300)
	await textBox.hidden
	cutsceneLakitu.visible = false
	behindscenesLakitus.visible = false
	LibSM64.play_sound_global(LibSM64.SOUND_MENU_CAMERA_BUZZ)
	GameManager.Instance().MarioCam.current = true
	GameManager.Instance().cutscene = false
	GameManager.Instance().advancedMario.setIgnoreInputs(false)	
	GameManager.Instance().trollMenu.unlock(TrollMenu.TROLL.LAKITU_EXPLANATION)
