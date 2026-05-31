extends Node3D

@export var currCoinScore: Array[TextureRect]
@export var currStarName: RichTextLabel
@export var starIds: Array
@export var hundredCoinStarId: int
@export var stars: Array[Node3D]
@export var starCount: Array[RichTextLabel]
@export var starSeperation: float
@export var UI: CanvasLayer
@export var camera: Camera3D
@export var starNames: Array[String]
var selectedStar = 0
var starNumber = 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	if not visible:
		return
	if Input.is_action_just_pressed("StickLeft"):
		if selectedStar > 0:
			LibSM64.play_sound_global(LibSM64.SEQ_MENU_STAR_SELECT)
			stars[selectedStar].spins = false
			stars[selectedStar].rotation.y = 0
			stars[selectedStar].scale = Vector3(0.125, 0.125, 0.125)
			selectedStar -= 1
			stars[selectedStar].spins = true
			stars[selectedStar].rotation.y = 0
			stars[selectedStar].scale = Vector3(0.13, 0.13, 0.13)
	elif Input.is_action_just_pressed("StickRight"):
		if selectedStar < starNumber - 1:
			LibSM64.play_sound_global(LibSM64.SEQ_MENU_STAR_SELECT)
			stars[selectedStar].spins = false
			stars[selectedStar].rotation.y = 0
			stars[selectedStar].scale = Vector3(0.125, 0.125, 0.125)
			selectedStar += 1
			stars[selectedStar].spins = true
			stars[selectedStar].rotation.y = 0
			stars[selectedStar].scale = Vector3(0.13, 0.13, 0.13)
	if Input.is_action_just_pressed("Start") or Input.is_action_just_pressed("A"):
		GameManager.Instance().PostProcessingManager.playWhiteOut(2.34, Color.WHITE)
		GameManager.Instance().onStarSelect(selectedStar)

func showStarSelect(ids: Array, coinStarId):
	currStarName.text = starNames[0]
	visible = true
	UI.visible = true
	LibSM64.play_music(LibSM64.SEQ_PLAYER_LEVEL, LibSM64.SEQ_MENU_STAR_SELECT)
	selectedStar = 0
	var highestCollectedIdx = -1
	starIds = ids
	hundredCoinStarId = coinStarId
	for idx in range(len(starIds)):
		stars[idx].visible = false
		starCount[idx].visible = false
		if GameManager.Instance().starIds.has(starIds[idx]):
			highestCollectedIdx = idx
			stars[idx].collected = false
		else:
			stars[idx].collected = true
	var offset = 0
	starNumber = min(max(1,highestCollectedIdx + 2), 6)
	if starNumber % 2 == 0:
		offset = starSeperation * 0.5
	for i in range(starNumber):
		stars[i].visible = true
		starCount[i].visible = true
		stars[i].position.x = starSeperation * (i - int(starNumber * 0.5)) + offset
	stars[selectedStar].spins = true
	stars[selectedStar].scale = Vector3(0.13, 0.13, 0.13)
