extends Control

@export var darkness: PanelContainer
@export var menu: Control
@export var selections: Array[RichTextLabel]
@export var coinCounter: RichTextLabel
var hasControl = false
var selection = 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	darkness.visible = false
	menu.visible = false
	hasControl = false

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if not hasControl:
		return
	if Input.is_action_just_pressed("StickUp"):
		var currSelection = selection
		selection -= 1
		if selection < 0:
			selection = 0
		if currSelection != selection:
			LibSM64.play_sound_global(LibSM64.SOUND_MENU_CHANGE_SELECT)
		for i in range(3):
			selections[i].text = " "
		selections[selection].text = ">"
	if Input.is_action_just_pressed("StickDown"):
		var currSelection = selection
		selection += 2
		if selection > 2:
			selection = 2
		if currSelection != selection:
			LibSM64.play_sound_global(LibSM64.SOUND_MENU_CHANGE_SELECT)
		for i in range(3):
			selections[i].text = " "
		selections[selection].text = ">"
	if Input.is_action_just_pressed("A") or Input.is_action_just_pressed("Start"):
		if selection == 0:
			hasControl = false
			set_visible(false)
			darkness.visible = false
			menu.visible = false
			GameManager.Instance().trollMenu.unlock(TrollMenu.TROLL.GERMAN_ANTI)
			GameManager.Instance().switchToLevel(GameManager.Levels.GERMAN_ANTI, 0, GameManager.StartType.DEFAULT)
		elif selection == 1:
			hasControl = false
			visible = false
			darkness.visible = false
			menu.visible = false
		else:
			GameManager.Instance().trollMenu.unlock(TrollMenu.TROLL.DONT_SAVE_AND_QUIT)
			get_tree().quit()

func updateCoinCount():
	coinCounter.text = "[center]$*" + str(GameManager.Instance().coinCount)

func showMenu():
	selection = 0
	selections[0].text = " "
	selections[1].text = " "
	selections[2].text = " "
	selections[selection].text = ">"
	darkness.visible = true
	menu.visible = true
