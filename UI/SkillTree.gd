extends Control

@export var currNodeTitle: RichTextLabel
@export var currNodeDesc: RichTextLabel
@export var templateNode: TextureRect
@export var templatePath: Line2D
@export var treeParent: Control
var nodeControls: Array[TextureRect]
var currentNode: int
var enableSkillMenu = false
var skillPoints = 1

func getTreeData():
	return {
		"clusters": [
			{
				# start
				"id": 0,
				"center": Vector2(0,0),
				"ringRadii": [30,80,180,280,330,450]
			},
			{
				# resistance node
				"id": 1,
				"center": Vector2(-80,120),
				"ringRadii": [50,130]
			},
			{
				#crawling & action speed
				"id": 2,
				"center": Vector2(180,-200),
				"ringRadii": [0,80,]
			},
			{
				# damage vs normal enemies
				"id": 3,
				"center": Vector2(450,0),
				"ringRadii": [30,80]	
			},
			{
				# maximum life
				"id": 4,
				"center": Vector2(0,-275),
				"ringRadii": [30,80]
			},
			{
				# maximum life
				"id": 5,
				"center": Vector2(0,-700),
				"ringRadii": [30,80,160]
			}
		],
		"nodes": [
			{
				"id": 0,
				"name": "ALERTNESS",
				"desc": "Mario falls asleep 0.5s slower.",
				"cluster": 0,
				"ring": 0,
				"angle": 0,
				"up": 2,
				"down": 1,
				"right": 10,
			},
			{
				"id": 1,
				"name": "ANTI TOXIC",
				"desc": "Mario now coughs slighty less when in gas.",
				"cluster": 0,
				"ring": 0,
				"angle": 2*PI/3.,
				"right": 0,
				"down": 4
			},
			{
				"id": 2,
				"name": "LUNG CAPACITY",
				"desc": "Less bubbles escape when Mario is underwater.",
				"cluster": 0,
				"ring": 0,
				"angle": 4*PI/3.,
				"right": 0,
				"up": 5,
			},
			{
				"id": 3,
				"name": "BIGFOOT",
				"desc": "The shoe during the kick is now slightly bigger.",
				"cluster": 0,
				"ring": 2,
				"angle": PI/16,
				"left": 10,
				"right": 11,
			},
			{
				"id": 4,
				"name": "BODYWARMTH",
				"desc": "Mario shivers less in the cold weather.",
				"cluster": 1,
				"ring": 0,
				"angle": 5*PI/3.,
				"up": 1,
				"left": 6,
				"right": 7,
			},
			{
				"id": 5,
				"name": "B SWIMMING",
				"desc": "Pressing ² while swimming makes Mario move a bit further.",
				"cluster": 0,
				"ring": 1,
				"angle": 4*PI/3.,
				"down": 2,
				"up": 14,
			},
			{
				"id": 6,
				"name": "COLD RESISTANCE",
				"desc": "Take 0.1 less damage from cold water.",
				"cluster": 1,
				"ring": 0,
				"angle": 5.*PI/3-PI/2.,
				"right": 4,
				"down": 9,
			},
			{
				"id": 7,
				"name": "FIRE RESISTANCE",
				"desc": "When burnt less smoke spawns.",
				"cluster": 1,
				"ring": 0,
				"angle": 5*PI/3.+PI/2,
				"up": 4,
				"down": 9,
			},
			{
				"id": 8,
				"name": "PUNCH SLIDE",
				"desc": "Slide a bit longer when sliding during a punch.",
				"cluster": 0,
				"ring": 2,
				"angle": -PI/16,
				"left": 10,
				"right": 11,
				"up": 12,
			},
			{
				"id": 9,
				"name": "CLOUDY NOT SNOWY",
				"desc": "No longer shiver in sky stages.",
				"cluster": 1,
				"ring": 0,
				"angle": 5*PI/3.+PI,
				"right": 7,
				"left": 6,
				"down": 22,
			},
			{
				"id": 10,
				"name": "RESTING",
				"desc": "Recover health ever so slightly when sleeping.",
				"cluster": 0,
				"ring": 1,
				"angle": 0,
				"left": 0,
				"up": 8,
				"down": 3,
			},
			{
				"id": 11,
				"name": "EASY TRIPLE",
				"desc": "Triple jumps require a little bit less speed.",
				"cluster": 0,
				"ring": 3,
				"angle": 0,
				"up": 8,
				"down": 3,
				"right": 21,
			},
			{
				"id": 12,
				"name": "POUND AND GO",
				"desc": "Recover slightly faster from ground pound landing.",
				"cluster": 2,
				"ring": 1,
				"angle": PI/2,
				"down": 8,
				"left": 13,
				"right": 15,
				"up": 18,
			},
			{
				"id": 13,
				"name": "BREAK DANCE",
				"desc": "Each repeated break dance speeds up action speed by 0.2% (up to 1%)",
				"cluster": 2,
				"ring": 1,
				"angle": PI,
				"down": 12,
				"up": 30,
			},
			{
				"id": 14,
				"name": "BREATH UP",
				"desc": "Recover 1 more life at the surface of normal water.",
				"cluster": 0,
				"ring": 2,
				"angle": 4*PI/3.,
				"down": 5,
				"up": 19,
				"left": 20,
			},
			{
				"id": 15,
				"name": "BABY STEPS",
				"desc": "Can now crawl up slightly steeper slopes.",
				"cluster": 2,
				"ring": 1,
				"angle": PI/4.,
				"down": 12,
				"up": 16,
			},
			{
				"id": 16,
				"name": "BABY RACE",
				"desc": "Increase crawl speed by 1%.",
				"cluster": 2,
				"ring": 1,
				"angle": 0,
				"down": 15,
				"up": 17,
			},
			{
				"id": 17,
				"name": "SHIMMYING UP",
				"desc": "Can now crawl up slightly steeper slopes.",
				"cluster": 2,
				"ring": 1,
				"angle": -PI/4,
				"down": 16,
				"up": 30,
			},
			{
				"id": 18,
				"name": "HARD BREAK",
				"desc": "Slightly reduce slide time when switching directions.",
				"cluster": 2,
				"ring": 0,
				"angle": 0,
				"down": 12,
				"up": 30,
			},
			{
				"id": 19,
				"name": "OXYGEN EFFICIENCY",
				"desc": "Reduces the life loss underwater by 0.01.",
				"cluster": 0,
				"ring": 3,
				"angle": 4*PI/3,
				"down": 14,
				"right": 33,
				"up": 39,
			},
			{
				"id": 20,
				"name": "MANY MARIOS",
				"desc": "Increase maximum extra lives by 1.",
				"cluster": 0,
				"ring": 3,
				"angle": PI,
				"right":14,
			},
			{
				"id": 21,
				"name": "DIGGING YOUR SHOES IN",
				"desc": "Provides an additional half a frame to triple jump on slopes",
				"cluster": 0,
				"ring": 4,
				"angle": 0,
				"left": 11,
				"down": 24,
				"right": 25,
				"up": 29,
			},
			{
				"id": 22,
				"name": "MIND OVER BODY",
				"desc": "Mario's run speed while burning is reduced by 5%",
				"cluster": 1,
				"ring": 1,
				"angle": 2*PI/3.,
				"up": 9,
				"right": 23,
			},
			{
				"id": 23,
				"name": "RICHES",
				"desc": "Adds a tiny chance to get twice the coins.",
				"cluster": 0,
				"ring": 3,
				"angle": PI/2.5,
				"left": 22,
				"up": 24,
				"right": 43,
			},
			{
				"id": 24,
				"name": "WHAT A STEAL",
				"desc": "Adds a tiny chance for enemeies to drop twice the coins.",
				"cluster": 0,
				"ring": 3,
				"angle": PI/4.5,
				"left": 23,
				"right": 21,
				"down": 43,
			},
			{
				"id": 25,
				"name": "JUST A GOOMBA",
				"desc": "Increases damage against normal enemies by 1.",
				"cluster": 3,
				"ring": 1,
				"angle": PI,
				"left": 21,
				"right": 26,
			},
			{
				"id": 26,
				"name": "JUST A GOOMBA",
				"desc": "Increases damage against normal enemies by 1.",
				"cluster": 3,
				"ring": 0,
				"angle": PI*0.8,
				"left": 25,
				"right": 27,
			},
			{
				"id": 27,
				"name": "JUST A GOOMBA",
				"desc": "Increases damage against normal enemies by 1.",
				"cluster": 3,
				"ring": 0,
				"angle": PI*0.3,
				"left": 26,
				"up": 28,
			},
			{
				"id": 28,
				"name": "JUST A GOOMBA",
				"desc": "Increases damage against normal enemies by 1.",
				"cluster": 3,
				"ring": 0,
				"angle": -PI*0.5,
				"right": 27,
			},
			{
				"id": 29,
				"name": "SCORE 1UPS",
				"desc": "Requirement for 1ups from highscore reduced by 1.",
				"cluster": 0,
				"ring": 5,
				"angle": -PI*0.2,
				"down": 21,
				"up": 32,
			},
			{
				"id": 30,
				"name": "TURN ME RIGHT ROUND",
				"desc": "Decreases Mario's turn radius when turning around.",
				"cluster": 2,
				"ring": 1,
				"angle": -PI*0.5,
				"left": 13,
				"right": 17,
				"down": 18,
				"up": 31,
			},
			{
				"id": 31,
				"name": "POLES 2ND ROUND",
				"desc": "Poles drop coins after running around them a second time.",
				"cluster": 0,
				"ring": 5,
				"angle": -PI*0.37,
				"down": 30,
				"right": 32,
				"left": 38,
			},
			{
				"id": 32,
				"name": "RICHES",
				"desc": "Adds a tiny chance to get twice the coins.",
				"cluster": 0,
				"ring": 5,
				"angle": -PI*0.3,
				"left": 31,
				"right": 29,
			},
			{
				"id": 33,
				"name": "MAXIMUM HEALTH",
				"desc": "Increases life by 1 (256th of a wedge).",
				"cluster": 4,
				"ring": 1,
				"angle": PI,
				"left": 19,
				"right": 34,
			},
			{
				"id": 34,
				"name": "MAXIMUM HEALTH",
				"desc": "Increases life by 1 (256th of a wedge).",
				"cluster": 4,
				"ring": 0,
				"angle": PI*0.9,
				"left": 33,
				"right": 35,
			},
			{
				"id": 35,
				"name": "MAXIMUM HEALTH",
				"desc": "Increases life by 1 (256th of a wedge).",
				"cluster": 4,
				"ring": 0,
				"angle": PI*0.4,
				"left": 34,
				"right": 36,
			},
			{
				"id": 36,
				"name": "MAXIMUM HEALTH",
				"desc": "Increases life by 1 (256th of a wedge).",
				"cluster": 4,
				"ring": 0,
				"angle": -PI*0.1,
				"down": 35,
				"up": 37,
			},
			{
				"id": 37,
				"name": "MAXIMUM HEALTH",
				"desc": "Increases life by 1 (256th of a wedge).",
				"cluster": 4,
				"ring": 0,
				"angle": -PI*0.6,
				"down": 35,
				"right": 36,
			},
			{
				"id": 38,
				"name": "WHAT A STEAL",
				"desc": "Adds a tiny chance for enemeies to drop twice the coins.",
				"cluster": 0,
				"ring": 5,
				"angle": -PI*0.5,
				"right": 31,
				"left": 41,
				"up": 42,
			},
			{
				"id": 39,
				"name": "HOLDING BREATH",
				"desc": "Lose slightly less health when on low life from water.",
				"cluster": 0,
				"ring": 4,
				"angle": 4*PI/3,
				"up": 40,
				"down": 19,
			},
			{
				"id": 40,
				"name": "BUOYANCY",
				"desc": "Gain more vertical movement when swimming upwards.",
				"cluster": 0,
				"ring": 5,
				"angle": 4*PI/3,
				"down": 39,
				"right": 41,
			},
			{
				"id": 41,
				"name": "SCORE 1UPS",
				"desc": "Requirement for 1ups from highscore reduced by 1.",
				"cluster": 0,
				"ring": 5,
				"angle": -PI*0.6,
				"left": 40,
				"right": 38,
			},
			{
				"id": 42,
				"name": "MANY MARIOS",
				"desc": "Increase maximum extra lives by 1.",
				"cluster": 5,
				"ring": 2,
				"angle": PI*0.5,
				"down": 38,
			},
			{
				"id": 43,
				"name": "NO TOXICITY",
				"desc": "Decreases the life loss of gas by 0.1.",
				"cluster": 0,
				"ring": 4,
				"angle": PI*0.3,
				"left": 23,
				"up": 24,
				"down": 44,
			},
			{
				"id": 44,
				"name": "NO LONG GROUND POUND",
				"desc": "Delays the input for ground pound to ensure long jumps when intended.",
				"cluster": 0,
				"ring": 5,
				"angle": PI*0.3,
				"up": 43,
			},
		]
	}
	
func getNodePosition(json, nodeId):
	var node = json["nodes"][nodeId]
	var cluster = json["clusters"][node["cluster"]]
	var offset = Vector2(1, 0).rotated(node["angle"]) * cluster["ringRadii"][node["ring"]]
	return cluster["center"] + offset

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	#print("DEBUG SKILLMENU ON")
	#enableSkillMenu = true
	var json = getTreeData()
	var startPos = Vector2(0, 0)
	var renderedNodes: Array
	var nodeIdx = 0
	const lineOffset = Vector2(25, 25)
	for node in json["nodes"]:
		var cluster = json["clusters"][node["cluster"]]
		var nodeInst = templateNode.duplicate()
		nodeInst.material = templateNode.material.duplicate(true)
		nodeInst.visible = true
		var offset = Vector2(1, 0).rotated(node["angle"]) * cluster["ringRadii"][node["ring"]]
		nodeInst.position = cluster["center"] + offset
		nodeInst.tooltip_text = node["name"] + "\n" + node["desc"]
		treeParent.add_child(nodeInst)
		nodeControls.append(nodeInst)
		var paths = []
		if node.has("up"):
			paths.append(node["up"])
		if node.has("down"):
			paths.append(node["down"])
		if node.has("right"):
			paths.append(node["right"])
		if node.has("left"):
			paths.append(node["left"])
		for path in paths:
			if path in renderedNodes:
				continue
			var nodeTo = json["nodes"][path]
			var endPos = getNodePosition(json, path)
			var thisPos = nodeInst.position
			var line = templatePath.duplicate()
			line.add_point(thisPos+lineOffset)
			line.visible = true
			if nodeTo["cluster"] == node["cluster"] and nodeTo["ring"] == node["ring"]:
				var radius = cluster["ringRadii"][node["ring"]]
				var angleFrom = node["angle"]
				var angleTo = nodeTo["angle"]
				# Compute shortest angular difference
				var angleDiff = fmod(angleTo - angleFrom, TAU)
				if angleDiff > PI:
					angleDiff -= TAU
				elif angleDiff < -PI:
					angleDiff += TAU
				angleDiff /= 4.
				for i in range(3):
					var finalAngle = angleFrom + angleDiff * (i + 1)
					finalAngle = fmod(finalAngle, TAU)
					if finalAngle < 0:
						finalAngle += TAU 
					line.add_point(Vector2(1, 0).rotated(finalAngle) * radius + lineOffset + cluster["center"])
			line.add_point(endPos + lineOffset)
			treeParent.add_child(line)
		renderedNodes.append(nodeIdx)
		nodeIdx += 1
	currentNode = 0
	currNodeTitle.text = json["nodes"][0]["name"]
	currNodeDesc.text = json["nodes"][0]["desc"]
	treeParent.position = -getNodePosition(json, 0) - Vector2(24,24)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if not visible:
		return
	if not enableSkillMenu:
		return
	if Input.is_action_just_pressed("StickUp"):
		var json = getTreeData()
		if json["nodes"][currentNode].has("up"):
			currentNode = json["nodes"][currentNode]["up"]
			LibSM64.play_sound_global(LibSM64.SOUND_MENU_MESSAGE_NEXT_PAGE)
		currNodeTitle.text = json["nodes"][currentNode]["name"]
		currNodeDesc.text = json["nodes"][currentNode]["desc"]
		treeParent.position = -getNodePosition(json, currentNode) - Vector2(24,24)
	if Input.is_action_just_pressed("StickLeft"):
		var json = getTreeData()
		if json["nodes"][currentNode].has("left"):
			currentNode = json["nodes"][currentNode]["left"]
			LibSM64.play_sound_global(LibSM64.SOUND_MENU_MESSAGE_NEXT_PAGE)
		currNodeTitle.text = json["nodes"][currentNode]["name"]
		currNodeDesc.text = json["nodes"][currentNode]["desc"]
		treeParent.position = -getNodePosition(json, currentNode) - Vector2(24,24)
	if Input.is_action_just_pressed("StickRight"):
		var json = getTreeData()
		if json["nodes"][currentNode].has("right"):
			currentNode = json["nodes"][currentNode]["right"]
			LibSM64.play_sound_global(LibSM64.SOUND_MENU_MESSAGE_NEXT_PAGE)
		currNodeTitle.text = json["nodes"][currentNode]["name"]
		currNodeDesc.text = json["nodes"][currentNode]["desc"]
		treeParent.position = -getNodePosition(json, currentNode) - Vector2(24,24)
	if Input.is_action_just_pressed("StickDown"):
		var json = getTreeData()
		if json["nodes"][currentNode].has("down"):
			currentNode = json["nodes"][currentNode]["down"]
			LibSM64.play_sound_global(LibSM64.SOUND_MENU_MESSAGE_NEXT_PAGE)
		currNodeTitle.text = json["nodes"][currentNode]["name"]
		currNodeDesc.text = json["nodes"][currentNode]["desc"]
		treeParent.position = -getNodePosition(json, currentNode) - Vector2(24,24)
	if Input.is_action_just_pressed("A"):
		if skillPoints > 0 and currentNode in [0, 1, 2]:
			LibSM64.play_sound_global(LibSM64.SOUND_MENU_STAR_SOUND_LETS_A_GO)
			skillPoints -= 1
			nodeControls[currentNode].material.set_shader_parameter("unlocked", true)
	if Input.is_action_just_pressed("Start") or Input.is_action_just_pressed("B"):
		enableSkillMenu = false
		visible = false
		get_tree().paused = false
		LibSM64.play_sound_global(LibSM64.SOUND_MENU_PAUSE_2)
