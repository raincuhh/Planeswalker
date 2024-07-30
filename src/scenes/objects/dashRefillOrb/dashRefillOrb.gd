extends Node2D

@onready var player: CharacterBody2D = Utils.get_player()

var rotSpeed: float = 0.05

func _on_area_2d_body_entered(body) -> void:
	if !body == player:
		return
	
	player.refill_dashes()
	queue_free()

func _process(delta: float) -> void:
	rotation += rotSpeed
