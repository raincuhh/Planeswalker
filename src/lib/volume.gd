class_name Volume
extends Node2D

@onready var rooms: Node2D = $Rooms
@onready var objects: Node2D = $Objects
@onready var worldEnvironment: WorldEnvironment = $WorldEnvironment
@onready var canvasModulate: CanvasModulate = $CanvasModulate

@export var volumeGivenName: String
@export_range(1,3) var volumeID: int
@export var volumeSpawn: Marker2D
@export var volumeDebugSpawn: Marker2D
@export var spawnDefault: bool

var roomPositions: Dictionary = {}
var roomBoundaries: Dictionary = {}

const roomAdjacencyThreshold: float = 100.0

var currentRoom: Room
var currentCamera: Camera2D

var player: Player

func _ready() -> void:
	#TODO change the worldenvironments and canvasmodulate based on volume in levelmanager or something?
	
	update_current_volume()
	save_room_global_positions()
	save_room_global_bounds()
	#free_all_rooms()
	#load_current_room()
	get_important_info()
	
	SaveManager.save_game()

func load_current_room() -> void:
	var roomName: String = SaveManager.get_slot_data("current_room")
	var progress: LevelManager.SceneLoadProgress
	
	if roomName == null || roomName == "":
		Utils.debug_print(self, "no saved room found, loading default")
		var defaultFirstRoom: String = get_first_room()
		
		progress = LevelManager.load_room(defaultFirstRoom, Callable(self, "on_room_load"))
		handle_room_load_progress(progress)
		return
	
	progress = LevelManager.load_room(roomName, Callable(self, "on_room_load"))
	handle_room_load_progress(progress)

func handle_room_load_progress(progress: LevelManager.SceneLoadProgress) -> void:
	match progress:
		LevelManager.SceneLoadProgress.LOADING:
			pass
			#Utils.debug_print(self, "loading ")
		LevelManager.SceneLoadProgress.ADDED_TO_LOAD_QUEUE:
			pass

func on_room_load(loadedScene: PackedScene, sceneName: String) -> void:
	if !loadedScene is PackedScene:
		Utils.debug_print(self, "failed to load scene '%s'", [loadedScene])
		return
	
	var instance: Room = loadedScene.instantiate()
	var roomPosition: Vector2 = roomPositions[sceneName]
	instance.global_position = roomPosition
	rooms.add_child(instance)

func update_current_volume() -> void:
	Utils.debug_print(self, "updating current volume")
	
	LevelManager.currentVolume = self
	LevelManager.currentVolumeName = get_name()
	LevelManager.currentVolumePath = str(LevelManager.volumePath + "/" + LevelManager.currentVolumeName.to_lower())
	
	var slot: int = SaveManager.currentSaveSlot
	var latestVolumeID: int = int(SaveManager.get_slot_data("current_volume"))
	
	if volumeID > latestVolumeID:
		Utils.debug_print(self, "new volume reached")
		
		SaveManager.set_specific_slot_meta_data(slot, "current_volume", volumeID)
		SaveManager.set_specific_slot_meta_data(slot, "latest_volume_name", volumeGivenName)
		SaveManager.save_current_meta_data()
		
		SaveManager.set_slot_data("current_volume", volumeID)
		SaveManager.save_slot(slot, SaveManager.currentSlotData)
	else:
		Utils.debug_print(self, "current volume ID not higher than saved, no update required")

func update_current_room(room: Room) -> void:
	print("[volume] Updating current room")
	
	currentRoom = room
	LevelManager.currentRoom = currentRoom
	LevelManager.currentRoomName = currentRoom.roomName
	LevelManager.currentRoomGlobalPosition = currentRoom.global_position

func get_first_room() -> String:
	var volume: String = LevelManager.currentVolumeName.to_lower()
	var defaultVolume1Room: String = "room1"
	var defaultVolume2Room: String = "room65"
	
	match volume:
		"volume1":
			return defaultVolume1Room
		"volume2":
			return defaultVolume2Room
	return "room1"

func player_died() -> void:
	Utils.debug_print(self, "player died")
	
	reload_room()
	reload_camera()
	
	player.global_position = LevelManager.currentSpawn.round() + Vector2.UP

func free_all_rooms() -> void:
	for room: Room in rooms.get_children():
		room.queue_free()

func save_room_global_positions() -> void:
	roomPositions.clear()
	
	for room: Room in rooms.get_children():
		roomPositions[room.name.to_lower()] = room.global_position
	print(roomPositions)

func save_room_global_bounds() -> void:
	roomBoundaries.clear()
	
	for room: Room in rooms.get_children():
		var roomBounds = room.get_room_bounds()
		roomBoundaries[room.name.to_lower()] = roomBounds
	print(roomBoundaries)

func process_room() -> void:
	pass

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("debug_reload_room"):
		#if GlobalManager.debugMode:
		#reload_camera()
		reload_room()

func reload_room() -> void:
	print("reloading room")
	
	var _roomPath: String = str(LevelManager.currentRoomPath)
	#var roomInstance: Room = load(roomPath).instantiate()
	#var oldRoom: Room = currentRoom

func reload_camera() -> void:
	var camera: Camera2D = currentCamera
	camera.queue_free()
	camera = LevelManager.create_camera_instance()
	add_child(camera)
	#camera.reset_camera()

func get_important_info() -> void: 
	get_important_objects()

func get_important_objects() -> void:
	for room in rooms.get_children():
		#var index: int = 0
		
		for object: Variant in room.get_node("Objects").get_children():
			if object.is_in_group("uniqueCollectable"):
				var collectibleComponent: CollectableComponent = object.get_node("CollectableComponent")
				
				if collectibleComponent != null:
					pass
				
				LevelManager.collectableDict[object] = room
				LevelManager.collectiblesCount += 1
				#print(LevelManager.collectableDict)
			#print("[volume] Object: %s" % object)
	
	return
	#print(LevelManager.collectiblesCount)


func save_player_global_pos() -> void:
	pass
	#SaveManager.set_slot_data("current_chapter_position_x", player.global_position.x)
	#SaveManager.set_slot_data("current_chapter_position_y", player.global_position.y)
