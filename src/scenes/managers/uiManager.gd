extends CanvasLayer

@onready var vignette: CanvasLayer = $Vignette
@onready var pauseMenu: CanvasLayer = $PauseMenu
@onready var main: Node = Utils.get_main()

@export var playerUi: PackedScene
@export var debugManager: PackedScene 
@export var mainMenu: PackedScene
@export var savePopupIcon: PackedScene


var loaded: Dictionary = {}

var scenesDict: Dictionary = {
	"mainMenu": "mainMenu",
	"debugManager": "debugManager"
}

func init() -> void:
	instance_vignette()
	instance_main_menu()
	instance_debug_menu()

func instance_main_menu() -> void:
	open_ui_component(scenesDict.mainMenu, mainMenu, true)

func free_main_menu() -> void:
	free_ui_component(scenesDict.mainMenu)

func instance_vignette() -> void:
	if SaveManager.get_config_data("settings_special", "vignette"):
		vignette.visible = true
		var colorRect: ColorRect = vignette.get_node("ColorRect")
		colorRect.material.set_shader_parameter("Vignette Opacity", lerp(0.5, 0.261, 0.50))
	else:
		Utils.debug_print(self, "vignette off")

func instance_debug_menu() -> void:
	if GlobalManager.debugMode:
		open_ui_component(scenesDict.debugManager, debugManager, false)

func open_debug_mode() -> void:
	if loaded[scenesDict.debugManager] == null:
		return
	
	if !loaded[scenesDict.debugManager].visible:
		Utils.debug_print(self, "debug on")
		loaded[scenesDict.debugManager].visible = true
	
	elif loaded[scenesDict.debugManager].visible:
		Utils.debug_print(self, "debug off")
		loaded[scenesDict.debugManager].visible = false

func open_pause_menu(hideMouse: bool) -> void:
	if pauseMenu == null:
		return
	
	#open menu
	if !pauseMenu.visible && canPause:
		Utils.debug_print(self, "paused")
		#Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		pauseMenu.visible = true
		get_tree().paused = true
	
	#close menu
	elif pauseMenu.visible:
		Utils.debug_print(self, "not paused")
		#Input.mouse_mode = Input.MOUSE_MODE_CONFINED
		if hideMouse:
			pass
			#Input.mouse_mode = Input.MOUSE_MODE_CONFINED_HIDDEN
		pauseMenu.visible = false
		get_tree().paused = false

func open_ui_component(_name: String, component: PackedScene, showOnready: bool) -> void:
	if !loaded.has(_name):
		var node = component.instantiate()
		loaded[_name] = node
		add_child(node)
		if node is CanvasLayer:
			node.hide() 
		elif node is Node2D:
			node.visible = false
	
	if !showOnready:
		return
	
	var instance = loaded[_name]
	if instance is CanvasLayer:
		instance.show()
	elif instance is Node2D:
		instance.visible = true

func free_ui_component(_name: String) -> void:
	if loaded.has(_name):
		var instance = loaded[_name]
		instance.queue_free()
		loaded.erase(_name)

func create_save_icon_notification() -> void:
	var instance: Control = savePopupIcon.instantiate()
	add_child(instance)

#getters
var canPause: bool:
	get:
		return GlobalManager.canPause

var canDebug: bool:
	get: 
		return GlobalManager.debugMode

func check_if_main_screen() -> bool:
	if main.get_node("Volume").get_children().size() > 0: #checks if a volume is instantiated 
		Utils.debug_print(self, "can pause")
		return true
	else:
		Utils.debug_print(self, "cant pause")
		return false
