extends Node3D

class_name GameManager

signal levelLoaded()

@export var deathPlane: Node3D

@export var worldEnvironment: WorldEnvironment
@export var PostProcessingManager: Node

@export var StaticSurfaceHandler: Node
@export var ObjectSurfaceHandler: Node

@export var TextBox: Control
@export var IntroControls: Control

@export var SM64AudioStreamPlayer: LibSM64AudioStreamPlayer
@export var advancedMario: Node
@export var RomPicker: FileDialog
@export var HUD: Control
@export var trollMenu: Control
@export var resultMenu: Control

@export var start_cap := LibSM64.MarioFlags.MARIO_NORMAL_CAP
@export var waterLevel: Node3D

@export var levelRoot: Node

@export var CameraRigCastleCutscene: Node
@export var CutsceneCamera: Node
@export var MarioCam: Node

@export var StarSelect: Node3D

@export var lakitus: Array[Node3D]

@export var dialogs: Node

enum StartType {
	DEFAULT,
	SPINNING,
	DEATH_EXIT,
	SUCCESS_EXIT,
}

enum Levels {
	OUTSIDE_CASTLE,
	CASTLE_INTERIOR,
	LEVEL_BOB,
	LEVEL_WF,
	LEVEL_JRB,
	LEVEL_CCM,
	SECRET_SLIDE,
	VC,
	FIRST_BOWSER,
	GERMAN_ANTI,
}

var levels: Dictionary

var _libsm64_was_init = false
var voidOutTimer = 0
var voidingOut = false
var lastSafePosition: Vector3
var birdTimer = 0
var marioCreated = false
var currentLevel = -1
var deathTimer = 0
var deathLaugh = false
var deathDone = false
var healUp = false
var rng = RandomNumberGenerator.new()
var cutscene = false
var skippable = false
var skipLakitu = false
var dialogCooldown = 0
### any, bob, wf, ppss, jrb, ccm, bowser, basement, upstairs
var lockedDoors = [false, true, true, true, true, true, true, true, true, true, true]

var previousHealthWedges = 8

var coinCount = 0
var starCount = 0

var objectsToAdd: Array
var starIds: Dictionary

var castleCutscenePlayed = false

static var _instance

static func Instance():
	return _instance

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_instance = self
	levels[Levels.OUTSIDE_CASTLE] = preload("res://outsideCastleScene.tscn")
	levels[Levels.CASTLE_INTERIOR] = preload("res://CastleInterior.tscn")
	levels[Levels.LEVEL_BOB] = preload("res://BombOmbBattlefield.tscn")
	levels[Levels.VC] = preload("res://VC.tscn")
	levels[Levels.SECRET_SLIDE] = preload("res://SecretSlide.tscn")
	levels[Levels.GERMAN_ANTI] = preload("res://GermanAnti.tscn")
	# TODO: store this in a game manager?
	if LibSM64Global.rom.is_empty():
		RomPicker.pick_rom()
	else:
		_init_libsm64()

func onLevelLoaded():	
	pass

func leaveLevel():
	switchToLevel(levelRoot.get_child(0).respawnArea, levelRoot.get_child(0).respawnPoint, StartType.SUCCESS_EXIT)

func switchToLevel(levelName: Levels, spawnPoint: int, startType: StartType):
	coinCount = 0
	HUD.updateCoinCounter(coinCount)
	var level = levels[levelName].instantiate()
	currentLevel = levelName
	if levelRoot.get_child_count() > 0:
		LibSM64.fadeout_background_music(levelRoot.get_child(0).levelMusic, 1.)
	call_deferred("unloadPreviousLevel", level, spawnPoint, startType)

func pauseMario():
	advancedMario.MainMario.process_mode = Node.PROCESS_MODE_DISABLED

func resumeMario():
	advancedMario.MainMario.process_mode = Node.PROCESS_MODE_INHERIT

func skipLakituCutscene():
	cutscene = false
	skipLakitu = true
	CutsceneCamera.gravity_scale = 0.0
	CameraRigCastleCutscene.pause()
	lakitus[0].doRotation()
	await get_tree().create_timer(3).timeout
	TextBox.text.clear()
	TextBox.text.append("You want me to skip the cutscene?")
	TextBox.text.append("...")
	TextBox.text.append("You know I get paid by the hour..")
	TextBox.text.append("Back in the old times a session took 40+ hours. Now it's... less than 1.5 hours for a 120 star session? Some are even less than 15 minutes, not even 7 minutes!")
	TextBox.text.append("...")
	TextBox.text.append("You know what.")
	TextBox.text.append("Let's skip the cuscene.")
	TextBox.text.append("Let's skip everything.")
	TextBox.text.append("I'll skip my job!\nSee what you'll do disrespecting my work!!!")
	TextBox.init(0.2, 0.2, true, 400, 300)
	await TextBox.hidden
	CutsceneCamera.gravity_scale = 1.0
	trollMenu.unlock(TrollMenu.TROLL.SKIP_INTRO)

func gameStartCutscene():
	LibSM64.play_music(LibSM64.SEQ_PLAYER_LEVEL, LibSM64.SEQ_EVENT_CUTSCENE_INTRO)
	skippable = true
	CameraRigCastleCutscene.start()
	advancedMario.setInactive()
	await get_tree().create_timer(30.0).timeout
	if skipLakitu:
		return
	skippable = false
	advancedMario.setVisible(false)
	#LibSM64.set_mario_action(SM64Mario.id, LibSM64.ACT_GROUP_CUTSCENE)
	#LibSM64.set_mario_animation(SM64Mario.id, LibSM64.MARIO_ANIM_GROUND_POUND)
	await get_tree().create_timer(2.0).timeout
	#pauseMario()
	cutscene = true
	# TODO: make mario come out of the ground
	# TODO: make a pipe spawn out of mario
	TextBox.text.clear()
	TextBox.text.append("Welcome to\nSuper Mario 64 or sth!\nPress @ or J (keyboard) to proceed.")
	TextBox.text.append("If you are on controller...\nGood for you! It should work magically.")
	TextBox.text.append("I wasn't sure about ³ so I mapped it to every unmapped one.")
	TextBox.text.append("However, if you are on keyboard.. there was not enough budget for custom keyboard bindings.")
	TextBox.text.append("But I've got you covered. After this dialog... ")
	TextBox.text.append("You will see an image with button labels to print and one showing how to stick them to your keyboard!")
	TextBox.init(0.2, 0.2, true, 400, 300)
	await TextBox.hidden
	IntroControls.showUI()
	await IntroControls.hidden
	cutscene = false
	advancedMario.setVisible(true)
	advancedMario.MainMario.disableInputs = false
	MarioCam.current = true
	LibSM64.stop_background_music(LibSM64.SEQ_EVENT_CUTSCENE_INTRO)
	GameManager.Instance().trollMenu.unlock(TrollMenu.TROLL.CONTROL_SETUP)
	#resumeMario()

func castleCutscene():
	advancedMario.MainMario.disableInputs = true
	cutscene = true
	castleCutscenePlayed = true
	await get_tree().create_timer(1.).timeout
	LibSM64.play_sound_global(LibSM64.SOUND_OBJ_BOWSER_INTRO_LAUGH)
	await get_tree().create_timer(1.).timeout
	TextBox.text.clear()
	TextBox.text.append("Bwahahahahahahaha hahahahahahahahaha hahahahahahahahaha hahahahahahahahaha hahahahahahahahaha hahahahahahahahaha")
	TextBox.text.append("hahahahahahahahaha hahahahahahahahaha hahahahahahahahaha hahahahahahahahaha hahahahahahahahaha hahahahahahahahaha")
	TextBox.text.append("hahahahahahahahaha\n\nCough, cough. I am talking in your mind now, Mario.")
	TextBox.text.append("I've hidden the power stars in the painting worlds and kept the grand power star.")
	TextBox.text.append("With its power I can talk to you in your head Mario.")
	TextBox.init(0.2, 0.2, true, 400, 300)
	await TextBox.hidden
	advancedMario.MainMario.disableInputs = false
	cutscene = false
	trollMenu.unlock(TrollMenu.TROLL.BOWSER_MSG)

func unloadPreviousLevel(level, spawnPoint: int, startType: StartType):
	if levelRoot.get_child_count() > 0:
		levelRoot.remove_child(levelRoot.get_child(0))
	objectsToAdd.clear()
	levelRoot.add_child(level)
	if currentLevel == Levels.CASTLE_INTERIOR and not castleCutscenePlayed:
		castleCutscene()
	var hasStarSelect = false
	if currentLevel == Levels.LEVEL_BOB:
		hasStarSelect = true
		GameManager.Instance().PostProcessingManager.playWhiteIn(0.3, Color.WHITE)
		StarSelect.showStarSelect([0,1,2,3,4,5], 6)
		StarSelect.camera.current = true
	if currentLevel == Levels.VC:
		trollMenu.unlock(TrollMenu.TROLL.DID_NOT_DRAIN)
	if levelRoot.get_child(0).skyTexture == null:
		var voidSky = GradientTexture1D.new()
		voidSky.gradient = Gradient.new()
		voidSky.gradient.colors[1] = Color.BLACK
		worldEnvironment.environment.sky.sky_material.set_shader_parameter("skyTexture", voidSky)
	else:
		worldEnvironment.environment.sky.sky_material.set_shader_parameter("skyTexture", levelRoot.get_child(0).skyTexture)
	if hasStarSelect:
		HUD.visible = false
		cutscene = true
		advancedMario.MainMario.process_mode = Node.PROCESS_MODE_DISABLED
		advancedMario.VisualMario.process_mode = Node.PROCESS_MODE_DISABLED
	else:
		delayedMusic(level)
	advancedMario.setAngle(level.spawnPoints[spawnPoint].quaternion)
	advancedMario.teleport(level.spawnPoints[spawnPoint].position)
	if startType == StartType.DEATH_EXIT:
		advancedMario.setMarioAction(LibSM64.ACT_DEATH_EXIT)
		advancedMario.setMarioVelocity(levelRoot.get_child(0).respawnVelocity)
	elif startType == StartType.SUCCESS_EXIT:
		cutscene = true
		advancedMario.setIgnoreInputs(true)
		advancedMario.setMarioAction(LibSM64.ACT_SPAWN_NO_SPIN_AIRBORNE)
		await get_tree().create_timer(0.5).timeout
		# face opposite way
		LibSM64.set_mario_angle(advancedMario.MainMario.id, Quaternion(Vector3.UP, advancedMario.MainMario.rotation.y + PI))
		level.spawnPoints[spawnPoint].startGuideMario()
		resultMenu.visible = true
		resultMenu.updateCoinCount()
		#advancedMario.setMarioVelocity(levelRoot.get_child(0).respawnVelocity)
		await level.spawnPoints[spawnPoint].guidingFinished
		LibSM64.stop_background_music(LibSM64.get_current_background_music())
		LibSM64.play_music(LibSM64.SEQ_PLAYER_LEVEL, LibSM64.SEQ_EVENT_HIGH_SCORE)
		advancedMario.setMarioAction(LibSM64.ACT_EXIT_LAND_SAVE_DIALOG)
		resultMenu.showMenu()
		resultMenu.hasControl = true
		await resultMenu.hidden
		LibSM64.stop_background_music(LibSM64.SEQ_EVENT_HIGH_SCORE)
		LibSM64.play_music(LibSM64.SEQ_PLAYER_LEVEL, LibSM64.SEQ_LEVEL_INSIDE_CASTLE)
		resultMenu.hasControl = false
		cutscene = false
		advancedMario.setIgnoreInputs(false)
		advancedMario.setMarioAction(LibSM64.ACT_IDLE)
	elif startType == StartType.SPINNING:
		advancedMario.setMarioAction(LibSM64.ACT_SPAWN_SPIN_AIRBORNE)
	if level.deathArea:
		deathPlane.position.y = level.deathArea.position.y
	StaticSurfaceHandler.load_static_surfaces()
	SM64AudioStreamPlayer.play()
	
	for obj in objectsToAdd:
		ObjectSurfaceHandler.load_surface_object(obj)
	
	# done loading?
	levelLoaded.emit()
	levelRoot.get_child(0).onFullyLoaded()
	
	#create mario
	if not marioCreated:
		marioCreated = true
		advancedMario.createMario()
		advancedMario.interactCap(start_cap)
		await get_tree().create_timer(1).timeout
		advancedMario.lateInit()
		gameStartCutscene()
	if level.waterLevelNode and marioCreated:
		advancedMario.setWaterLevel(level.waterLevelNode.position.y)

func delayedMusic(level):
	await get_tree().create_timer(1.).timeout
	LibSM64.stop_background_music(LibSM64.get_current_background_music())
	if level.levelMusic not in [LibSM64.SEQ_SOUND_PLAYER, LibSM64.SEQ_COUNT]:
		LibSM64.play_music(LibSM64.SEQ_PLAYER_LEVEL, level.levelMusic)

func onStarSelect(starIdx: int):
	LibSM64.stop_background_music(LibSM64.SEQ_MENU_STAR_SELECT)
	LibSM64.play_sound_global(LibSM64.SOUND_MENU_STAR_SOUND_LETS_A_GO)
	GameManager.Instance().PostProcessingManager.playWhiteIn(2.34, Color.WHITE)
	StarSelect.visible = false
	StarSelect.UI.visible = false
	MarioCam.current = true
	HUD.visible = true
	cutscene = false
	advancedMario.MainMario.process_mode = Node.PROCESS_MODE_INHERIT
	advancedMario.VisualMario.process_mode = Node.PROCESS_MODE_INHERIT
	if levelRoot.get_child(0).levelMusic not in [LibSM64.SEQ_SOUND_PLAYER, LibSM64.SEQ_COUNT]:
		LibSM64.play_music(LibSM64.SEQ_PLAYER_LEVEL, levelRoot.get_child(0).levelMusic)
	
func doVoidOut():
	voidingOut = true
	PostProcessingManager.playFadeOut(2.34, 0, 6, 0)
	voidOutTimer = 7./8.

func onMarioActionStateChange(action: LibSM64.ActionFlags):
	if voidingOut:
		return
	if action & LibSM64.ActionFlags.ACT_FLAG_AIR == 0:
		lastSafePosition = advancedMario.MainMario.position

var timer = 0
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	timer -= delta
	if Input.is_key_pressed(KEY_G):
		if timer < 0:
			timer = 0.5
			LibSM64.stop_background_music(LibSM64.get_current_background_music())
	if dialogCooldown > 0:
		dialogCooldown -= delta
	if advancedMario.getHealth() <= 255 and not cutscene:
		if advancedMario.action in [AdvancedMario.CustomAction.HOLD_LIGHT, AdvancedMario.CustomAction.HOLD_HEAVY]:
			advancedMario.stopGrab()
		deathDone = false
		deathTimer += delta
	if deathTimer > 3 and not deathDone:
		if not deathLaugh:
			LibSM64.play_sound_global(LibSM64.SOUND_MENU_BOWSER_LAUGH)
			deathLaugh = true
			PostProcessingManager.playFadeOut(2.34, 0, 6, 3)
	if deathTimer > 6 and not deathDone:
		deathLaugh = false
		advancedMario.setVisible(true)
		# if inside of level respawn at entrance
		var targetArea = levelRoot.get_child(0).respawnArea
		var targetSpawn = levelRoot.get_child(0).respawnPoint
		advancedMario.setHealth(256)
		LibSM64.stop_background_music(levelRoot.get_child(0).levelMusic)
		switchToLevel(targetArea, targetSpawn, StartType.DEATH_EXIT)
		advancedMario.setMarioAction(LibSM64.ACT_DEATH_EXIT_LAND)
		healUp = true
		deathDone = true
		deathTimer = 0
		PostProcessingManager.playFadeIn(2.34, 6, 0, 0)
	if healUp and advancedMario.getHealth() <= 256*8:
		advancedMario.heal(256*7*delta*0.25)
		if previousHealthWedges != advancedMario.getHealthWedges():
			LibSM64.play_sound_global(LibSM64.SOUND_MENU_POWER_METER)
	elif advancedMario.getHealth() >= 256*8:
		healUp = false
	if voidingOut:
		if voidOutTimer > 0.:
			voidOutTimer -= delta
		if voidOutTimer <= 0.:
			advancedMario.takeDamage(256)
			advancedMario.setAction(LibSM64.ActionFlags.ACT_IDLE)
			advancedMario.teleport(lastSafePosition)
			PostProcessingManager.playFadeIn(2.34, 0, 6, 0)
			voidingOut = false
	#birdTimer -= delta
	#if birdTimer < 0:
	#	LibSM64.play_sound_global(LibSM64.SOUND_GENERAL2_BIRD_CHIRP2)
	#	birdTimer = 3#
	previousHealthWedges = advancedMario.getHealthWedges()

func _init_libsm64() -> void:
	_libsm64_was_init = LibSM64Global.init()
	if not _libsm64_was_init:
		push_error("Failed to initialize LibSM64Global")
		return
	#BombOmbBattlefieldSurfaces.load_static_surfaces()
	lastSafePosition = advancedMario.getPosition()
	HUD.mario = advancedMario.MainMario

	#LibSM64.play_sound_global(LibSM64.SOUND_OBJ_BIRD_CHIRP3)
	#LibSM64.play_music(LibSM64.SEQ_PLAYER_ENV, LibSM64.SOUND_ENV_WIND1)
	LibSM64.play_sound_global(LibSM64.ACT_BACKFLIP)
	
	# load start level
	SM64AudioStreamPlayer.play()
	#ObjectSurfaceHandler.load_surface_object()
	switchToLevel(Levels.OUTSIDE_CASTLE, 0, StartType.DEFAULT)

func _on_rom_picker_dialog_rom_loaded() -> void:
	_init_libsm64()

func onCollectCoins(count: int):
	coinCount += count
	HUD.updateCoinCounter(coinCount)

func updateStarCounter(id):
	if not starIds.has(id):
		starCount += 1
		starIds[id] = true
	HUD.updateStarCounter(starCount)

func talkCutscene(who: Node3D, id: int):
	advancedMario.setAction(LibSM64.ACT_READING_SIGN)
	advancedMario.MainMario.disableInputs = true
	#await get_tree().create_timer(2.)
	TextBox.text.clear()
	dialogs.dialogs[id].call(TextBox)
	await TextBox.hidden
	dialogCooldown = 0.5
	advancedMario.MainMario.disableInputs = false
	advancedMario.setAction(LibSM64.ACT_IDLE)
	who.dialogDone()
	
