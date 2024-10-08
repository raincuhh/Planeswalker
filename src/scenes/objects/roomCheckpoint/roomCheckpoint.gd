class_name RoomCheckpoint
extends Node2D

@onready var player: Player = Utils.get_player()
@onready var spawnPosMarker: Marker2D = $Marker2D

var playerInside: bool = false
var parentRoom: Node2D
var checkpointSizeIsEdited: bool = false

signal entered_checkpoint(checkpoint: RoomCheckpoint)

func _ready() -> void:
	pass

func _on_area_2d_body_entered(body: Node2D) -> void:
	if !body == player || !body is Player:
		return
	
	playerInside = true
	handle_entering()

func _on_area_2d_body_exited(body: Node2D) -> void:
	if !body == player || !body is Player:
		return
	
	playerInside = false

func handle_entering() -> void:
	print("entered checkpoint")
	
	entered_checkpoint.emit(self)

func resize_checkpoint_size() -> void:
	if !checkpointSizeIsEdited:
		pass

func get_spawn_position() -> Vector2:
	var spawnPos: Vector2
	spawnPos = spawnPosMarker.global_position
	return spawnPos
