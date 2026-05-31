extends MeshInstance3D

var marioNearby = false
var canBeGrabbed = true

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if not marioNearby or not canBeGrabbed:
		return
	# hasn't grabbed yet
	if GameManager.Instance().advancedMario.action == AdvancedMario.CustomAction.DEFAULT:
		# grab action
		if GameManager.Instance().advancedMario.getAction() in [LibSM64.ACT_PUNCHING, LibSM64.ACT_MOVE_PUNCHING]:
			GameManager.Instance().advancedMario.grabLightObject(self)
			canBeGrabbed = false
			GameManager.Instance().trollMenu.unlock(TrollMenu.TROLL.FAKE_SIGN)

func onMarioEnter(area: Area3D):
	marioNearby = true

func onMarioExit(area:Area3D):
	marioNearby = false
