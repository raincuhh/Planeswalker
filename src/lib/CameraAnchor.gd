extends Marker2D

@onready var player: CharacterBody2D = NodeUtility.get_player()
@onready var mainCamera: Camera2D = NodeUtility.get_main_camera()


func _process(delta) -> void:
	var target: Vector2 = player.global_position
	var targetPosX: int
	var targetPosY: int
	
	
	targetPosX = NodeUtility.int_lerp(global_position.x, target.x, 0.6)
	
	targetPosY = NodeUtility.int_lerp(global_position.y, target.y, 0.6)
	
	#targetPosX = int(target.x)
	#targetPosY = int(target.y)
	
	global_position = Vector2(targetPosX, targetPosY)
	mainCamera.position = global_position


