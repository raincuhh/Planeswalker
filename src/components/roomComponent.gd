class_name Room
extends Node2D

@onready var doors: Node2D = $Doors
@onready var decorations: Node2D = $Decorations
@onready var objects: Node2D = $Objects
@onready var world: Node2D = get_parent().get_parent()
@onready var tileSolidLayer: TileMapLayer = $TileSolidLayer

var usedCheckpoint: Node2D = null
var objectChildren: Array = []
var adjacentRooms: Array = []

var minX: int
var minY: int
var maxX: int
var maxY: int


signal enteredRoom(room: Room)


func _ready() -> void:
	#var fileName = get_name()
	#print(fileName)
	enteredRoom.emit(self)
	
	for door: RoomSwitcher in doors.get_children():
		door.playerEntered.connect(room_entered)
	
	calculate_room_bounds()
	print("[roomComponent] Room bounds: (%d, %d, %d, %d)" % [minX, minY, maxX, maxY])

func room_entered() -> void:
	pass

func calculate_room_bounds() -> void:
	var cells = tileSolidLayer.get_used_cells()
	if cells.size() == 0:
		return
	
	minX = cells[0].x
	minY = cells[0].y
	maxX = cells[0].x
	maxY = cells[0].y
	
	for cell in cells:
		if cell.x < minX:
			minX = cell.x
		if cell.x > maxX:
			maxX = cell.x
		if cell.y < minY:
			minY = cell.y
		if cell.y > maxY:
			maxY = cell.y

func set_parent_for_room_switchers() -> void:
	for door: RoomSwitcher in doors.get_children():
		door.parentRoom = self

func get_adjacent_rooms() -> Array:
	adjacentRooms.append(self)
	for door: RoomSwitcher in doors.get_children():
		if door.get_adjacent_room() != null:
			adjacentRooms.append(door.get_adjacent_room())
	return adjacentRooms
