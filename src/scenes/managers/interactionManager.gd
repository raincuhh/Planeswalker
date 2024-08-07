extends Node


@onready var player = Utils.get_player()
@onready var interactLabel = $InteractLabel

const baseInteractText: String = "[E/C] to interact"
const interactLabelZIndex = 20
const interactLabelOffset = 32

var registeredAreas = []
var canInteract: bool = true

func register_area(area: InteractionAreaComponent) -> void:
	registeredAreas.push_back(area)

func unregister_area(area: InteractionAreaComponent) -> void:
	var areaIndex = registeredAreas.find(area)
	if areaIndex != -1:
		registeredAreas.remove_at(areaIndex)

func _process(_delta: float) -> void:
	interactLabel.z_index = interactLabelZIndex
	if registeredAreas.size() > 0 && canInteract:
		registeredAreas.sort_custom(_sort_by_distance_to_player)
		interactLabel.text = baseInteractText
		interactLabel.global_position = registeredAreas[0].global_position
		interactLabel.global_position.y -= interactLabelOffset
		interactLabel.global_position.x -= interactLabel.size.x / 2
		interactLabel.show()
	else:
		interactLabel.hide()

func _sort_by_distance_to_player(area1: InteractionAreaComponent, area2: InteractionAreaComponent) -> bool:
	var area1ToPlayer = player.global_position.distance_squared_to(area1.global_position)
	var area2ToPlayer = player.global_position.distance_squared_to(area2.global_position)
	return area1ToPlayer < area2ToPlayer

func _input(event):
	if event.is_action_pressed("interact") && canInteract:
		if registeredAreas.size() > 0:
			canInteract = false
			interactLabel.hide()
			
			await registeredAreas[0].interact.call()
			
			canInteract = true
