class_name Main
extends Node

static var instance : Main = null

# Debug Levels stack. So printing at a Game level will print everything including Data
# NONE won't print anything
# ERROR will print any errors
# DATA will print Data being handles by the Data Manager and Factories
# Game will print Game Information from abilities, attacks
# System will print anything major from important systems in the game like DevRoomEditor
# Verbose will print EVERYTHING like InputHandler information
enum DEBUG_LEVEL {NONE = 0, ERROR = 1, DATA = 2, GAME = 3, SYSTEM = 4, VERBOSE = 5}
@export var debug_level : DEBUG_LEVEL = DEBUG_LEVEL.NONE

func _init() -> void:
	instance = self

#func _enter_tree() -> void:
	#GameAbility.load_database()
	#AbilityData.load_database()
	#WeaponData.load_database()
	#UnitData.load_database()

func _ready() -> void:
	print_rich("[color=red][b]Game Is Loading![/b][/color]")
	await get_tree().create_timer(1.0, false).timeout
	
	CardData.load_database()
	
	print()
	EventBus.on_game_load.emit()
	print_rich("[color=green][b]Game Is Ready![/b][/color]")
	print("Took: " + str((Time.get_ticks_msec() as float / 1000)) + "s")
	
	Session.inst().setup()
	#scene_manager.scene_finished()

func _input(_event: InputEvent):
	pass

static func inst() -> Main:
	return instance

func debug(caller: String, object: Variant, level: DEBUG_LEVEL) -> void:
	if level <= self.debug_level:
		var color : String = _get_color(level)
		print_rich("[color=" + color + "]" \
			+ "[b]" + caller + "[/b]: " \
			+ str(object))

func debug_empty() -> void:
	print()

const DEBUG_COLOR_MAP : Dictionary = {
	DEBUG_LEVEL.ERROR: "white",
	DEBUG_LEVEL.DATA: "cyan",
	DEBUG_LEVEL.GAME: "orange",
	DEBUG_LEVEL.SYSTEM: "pink",
	DEBUG_LEVEL.VERBOSE: "yellow"
}

func _get_color(level: DEBUG_LEVEL) -> String:
	return DEBUG_COLOR_MAP.get(level, "gray")

func _unhandled_input(_event: InputEvent) -> void:
	pass
	#if event.is_action_released("Game_Save", true):
		#on_save()

func _notification(what: int) -> void:
	if what != NOTIFICATION_WM_CLOSE_REQUEST \
		and what != NOTIFICATION_CRASH:
			return
	
	on_save()

signal on_game_save()
func on_save() -> void:
	debug("Main", "Saving Game...", DEBUG_LEVEL.NONE)
	EventBus.on_game_save.emit()
	debug("Main", "Game Saved!", DEBUG_LEVEL.NONE)

signal on_game_load()
func on_load() -> void:
	debug("Main", "Loading Game...", DEBUG_LEVEL.NONE)
	EventBus.on_game_load.emit()
	debug("Main", "Game Loaded!", DEBUG_LEVEL.NONE)

const GLOBAL_TIMER_FREEZE : float = 1.0 / 60.0
signal freeze_timeout
func freeze_time(time: float) -> void:
	if get_tree().paused:
		# Wait 1 frame so that await aren't broken
		await get_tree().create_timer(GLOBAL_TIMER_FREEZE).timeout
		
		freeze_timeout.emit()
		return
	
	get_tree().paused = true
	# get_node("/root").add_child(self)
	
	await get_tree().create_timer(time).timeout
	
	get_tree().paused = false
	freeze_timeout.emit()
