class_name Utils
extends Node

# These are bitmask values. Check the layers to make sure.
const MASK_COLLISION_ANY : int = 1
const MASK_COLLISION_FLOOR : int = 2
const MASK_COLLISION_UNITS : int = 4

static func enum_to_str(value: int, dict: Dictionary) -> String:
	return dict.find_key(value).capitalize()

static func find_enum_value(string: String, dict: Dictionary) -> int:
	return dict.get(string.to_upper(), -1)

static func find_enum_similar(value: int, o1: Dictionary, o2: Dictionary) -> int:
	var enum_name : String = o1.find_key(value)
	
	for key in o2.keys():
		if enum_name == key:
			return o2[key]
	
	return -1

static func clear_signal(object: Object, _sig: Signal) -> void:
	if object == null:
		return
	
	for _signal in object.get_signal_list():
		if _signal["name"] != _sig.get_name():
			continue
		
		for _connection in object.get_signal_connection_list(_signal["name"]):
			object.disconnect(_connection["signal"].get_name(), _connection["callable"])

static func clear_signals(object: Object) -> void:
	if object == null:
		return
	
	for _signal in object.get_signal_list():
		for _connection in object.get_signal_connection_list(_signal["name"]):
			object.disconnect(_connection["signal"].get_name(), _connection["callable"])

static func get_directories(dir: DirAccess) -> Array[String]:
	if not dir:
		return []
	
	var dirs : Array[String] = []
	
	dir.list_dir_begin()
	
	var file_name : String = dir.get_next()
	while not file_name.is_empty():
		if dir.current_is_dir():
			var dir_path : String = dir.get_current_dir() + "/" + file_name
			dirs.append(dir_path)
			dirs.append_array(get_directories(DirAccess.open(dir_path)))
		
		file_name = dir.get_next()
	
	dir.list_dir_end()
	return dirs

static func get_files(dir: DirAccess) -> Array[String]:
	if not dir:
		return []
	
	var files : Array[String] = []
	
	dir.list_dir_begin()
	
	var file_name : String = dir.get_next()
	while not file_name.is_empty():
		if not dir.current_is_dir():
			var dir_path : String = dir.get_current_dir() + "/" + file_name
			files.append(dir_path)
			files.append_array(get_directories(DirAccess.open(dir_path)))
		
		file_name = dir.get_next()
	
	dir.list_dir_end()
	return files

const BYTE_MASK: int = 0b11111111

static func uuidbin():
	randomize()
	# 16 random bytes with the bytes on index 6 and 8 modified
	return [
		randi() & BYTE_MASK, randi() & BYTE_MASK, randi() & BYTE_MASK, randi() & BYTE_MASK,
		randi() & BYTE_MASK, randi() & BYTE_MASK, ((randi() & BYTE_MASK) & 0x0f) | 0x40, randi() & BYTE_MASK,
		((randi() & BYTE_MASK) & 0x3f) | 0x80, randi() & BYTE_MASK, randi() & BYTE_MASK, randi() & BYTE_MASK,
		randi() & BYTE_MASK, randi() & BYTE_MASK, randi() & BYTE_MASK, randi() & BYTE_MASK,
	]


static func generate_uuid() -> String:
	# 16 random bytes with the bytes on index 6 and 8 modified
	var b = uuidbin()
	return '%02x%02x%02x%02x-%02x%02x-%02x%02x-%02x%02x-%02x%02x%02x%02x%02x%02x' % [
	# low
	b[0], b[1], b[2], b[3],
	# mid
	b[4], b[5],
	# hi
	b[6], b[7],
	# clock
	b[8], b[9],
	# clock
	b[10], b[11], b[12], b[13], b[14], b[15]
	]

static func get_file_name(path: String, remove_suffix = false) -> String:
	var last_slash : int = path.rfind("/")
	var file_name : String = path.substr(last_slash + 1)
	if remove_suffix:
		file_name = file_name.replace(".tres", "")
		file_name = file_name.replace(".tscn", "")
		file_name = file_name.replace(".remap", "")
	
	return file_name

const RAY_LENGTH = 100
static func draw_ray(viewport: Viewport, bit_mask = MASK_COLLISION_ANY) -> Dictionary:
#	var mouse_pos = event.global_position
#	emit_signal("on_game_interact", mouse_pos)
	var Camera : Camera3D = viewport.get_camera_3d()
	var mouse_pos : Vector2 = viewport.get_mouse_position()
	var ray_from = Camera.project_ray_origin(viewport.get_mouse_position()) as Vector3
	var ray_to = ray_from + Camera.project_ray_normal(mouse_pos) * RAY_LENGTH

	var physics_params := PhysicsRayQueryParameters3D.create(ray_from, ray_to, bit_mask)
	var space_state = viewport.get_world_3d().direct_space_state
	var result : Dictionary = space_state.intersect_ray(physics_params)

	return result

static func draw_ray_from(viewport: Viewport, from: Vector3, to: Vector3i, bit_mask = MASK_COLLISION_ANY) -> Dictionary:
	var physics_params := PhysicsRayQueryParameters3D.create(from, to, bit_mask)
	var space_state = viewport.get_world_3d().direct_space_state
	var result : Dictionary = space_state.intersect_ray(physics_params)

	return result

# Credit to Dileeep
# https://godotengine.org/qa/74010/how-to-get-all-children-from-a-node
static func get_all_children(in_node, arr: Array[Node] = []) -> Array[Node]:
	arr.push_back(in_node)
	for child in in_node.get_children():
		arr = get_all_children(child, arr)
	return arr

static func free_children(node: Node, free: bool = false, exempt: Callable = Callable()) -> void:
	for child : Node in node.get_children().duplicate():
		if child == null:
			continue
		
		if exempt and not exempt.is_null() and exempt.call(child):
			continue
		
		if free:
			child.free()
		else:
			child.queue_free()

static func unpack_strings(data: PackedStringArray) -> Array[String]:
	var array : Array[String] = []
	array.append_array(data)
	
	for i in range(array.size()):
		var string : String = array[i]
		if string.begins_with(" "):
			array[i] = string.substr(1)
		if string.ends_with(" "):
			array[i] = string.substr(0, string.length() - 1)
	
	return array

static func get_damage_string(value: int, zero_plus = false) -> String:
	if value > 0:
		return "+" + str(value)
	elif value == 0 and zero_plus:
		return "+0"
	else:
		return str(value)

static func ease_in_cubic(x: float) -> float:
	return x * x * x

# https://www.geeksforgeeks.org/python-program-to-convert-integer-to-roman/
# Function to calculate Roman values
static func to_roman(num: int):
	# Storing roman values of digits from 0-9
	# when placed at different places
	var m : Array[String] = ["", "M", "MM", "MMM"]
	var c : Array[String] = ["", "C", "CC", "CCC", "CD", "D",
		"DC", "DCC", "DCCC", "CM "]
	var x : Array[String] = ["", "X", "XX", "XXX", "XL", "L",
		"LX", "LXX", "LXXX", "XC"]
	var i : Array[String] = ["", "I", "II", "III", "IV", "V",
		"VI", "VII", "VIII", "IX"]
	
	# Converting to roman
	@warning_ignore("integer_division")
	var thousands : String = m[floori(num / 1000)]
	@warning_ignore("integer_division")
	var hundreds : String = c[floori((num % 1000) / 100)]
	@warning_ignore("integer_division")
	var tens : String = x[floori((num % 100) / 10)]
	var ones : String = i[num % 10]
	
	var ans : String = (thousands + hundreds + tens + ones)
	
	return ans

# https://www.delftstack.com/howto/python/roman-to-integer-python/
static func from_roman(roman: String):
	# dictionary to store the roman-integer values
	var map_symbols : Dictionary = {"I": 1, "V": 5, "X": 10, "L": 50, "C": 100, "D": 500, "M": 1000}
	
	var ans : int = 0
	for i in range(len(roman)):
		if i > 0 and map_symbols[roman[i]] > map_symbols[roman[i - 1]]:
			ans += map_symbols[roman[i]] - 2 * map_symbols[roman[i - 1]]
		else:
			ans += map_symbols[roman[i]]
	return ans

static func remove_duplicates(array: Array) -> Array:
	var arr : Array = []
	var keys : Array = []
	for element in array:
		if not element in keys:
			keys.append(element)
			arr.append(element)
	
	return arr

static func str_in_array(what: String, array: Array[String]) -> bool:
	for string : String in array:
		if string.contains(what):
			return true
	return false

static func get_str_in_array(what: String, array: Array[String]) -> String:
	for string : String in array:
		if string.contains(what):
			return String(string)
	return ""

static func string_compare(value: int, comparitor: String, max_value: int = -1) -> bool:
	var compare : int = int(comparitor)
	
	var equals : bool = "=" in comparitor
	var more : bool = ">" in comparitor
	var less : bool = "<" in comparitor
	
	var percent : bool = "%" in comparitor
	
	if percent and max_value > -1:
		# Percentages should be used comparitively with more or less.
		# Equals would be weird
		var value_percent : float = value as float / max_value as float
		if more:
			return value_percent >= compare
		elif less:
			return value_percent <= compare
	else:
		if more:
			return value >= compare if equals else value > compare
		elif less:
			return value <= compare if equals else value < compare
		elif equals:
			return value == compare
	
	# Always fail if the comparitor is invalid
	#Main.inst().debug("String Compare", "Comparitor was invalid: " + comparitor, Main.DEBUG_LEVEL.ERROR)
	assert(false)
	return false

static func string_compare_float(value: float, comparitor: String, max_value: float = -1) -> bool:
	var clean : String = comparitor.replace("=", "")
	clean = clean.replace(">", "")
	clean = clean.replace("<", "")
	clean = clean.replace("%", "")
	var compare : float = float(clean)
	
	var equals : bool = "=" in comparitor
	var more : bool = ">" in comparitor
	var less : bool = "<" in comparitor
	
	var percent : bool = "%" in comparitor
	
	if percent and max_value > -1:
		# Percentages should be used comparitively with more or less.
		# Equals would be weird
		var value_percent : float = value as float / max_value as float
		if more:
			return value_percent >= compare
		elif less:
			return value_percent <= compare
	else:
		if more:
			return value >= compare if equals else value > compare
		elif less:
			return value <= compare if equals else value < compare
		elif equals:
			return value == compare
	
	# Always fail if the comparitor is invalid
	#Main.inst().debug("String Compare", "Comparitor was invalid: " + comparitor, Main.DEBUG_LEVEL.ERROR)
	assert(false)
	return false

static func unpack_vector2i(array: PackedVector2Array) -> Array[Vector2i]:
	var result : Array[Vector2i] = []
	for e : Vector2 in array:
		result.append(Vector2i(e))
	
	return result

static func unpack_vector3(array: PackedVector3Array) -> Array[Vector3]:
	var result : Array[Vector3] = []
	for e in array:
		result.append(e)
	
	return result

static func get_path_length(array: Array[Vector3]) -> float:
	if array.is_empty() or array.size() == 1:
		return 0.0
	
	var total : float = 0.0
	var prev : Vector3 = array.front()
	for e in array:
		if e == array.front():
			continue
		
		total += e.distance_to(prev)
		prev = e
	
	return total

static func create_noise(freq: float) -> FastNoiseLite:
	var noise := FastNoiseLite.new()
	noise.frequency = freq
	noise.fractal_type = FastNoiseLite.FRACTAL_NONE
	noise.fractal_gain = 0.0
	noise.seed = randi()
	noise.offset.x += randi_range(0, 200)
	return noise

static func format_amount(amount: int) -> String:
	var amt_str : String = str(amount)
	if amt_str.length() >= 5:
		return amt_str.substr(0, 2) + "." + amt_str.substr(2, 1) + "K"
	elif amt_str.length() >= 4:
		return amt_str.substr(0, 1) + "." + amt_str.substr(1, 1) + "K"
	else:
		return amt_str

static func truncate(amount: float, decimals: int = 2) -> String:
	var amount_str : String = str(amount)
	if "." in amount_str:
		var data : Array[String] = Utils.unpack_strings(amount_str.split("."))
		return data[0] + "." + data[1].substr(0, decimals)
	else:
		amount_str += "."
		for i in range(decimals):
			amount_str += "0"
		return amount_str

static func chop(amount: float) -> int:
	var amount_str : String = str(amount)
	if "." in amount_str:
		var data : Array[String] = Utils.unpack_strings(amount_str.split("."))
		return int(data[0])
	return amount as int

static func extract_int(key: String, data: Array[String], def: int = 0) -> int:
	var extracted : String = Utils.get_str_in_array(key, data)
	
	if not extracted.is_empty():
		return int(extracted.split(":")[1])
	return def

static func extract_float(key: String, data: Array[String], def: float = 0.0) -> float:
	var extracted : String = Utils.get_str_in_array(key, data)
	
	if not extracted.is_empty():
		return float(extracted.split(":")[1])
	return def

static func extract_string(key: String, data: Array[String], def: String = "") -> String:
	var extracted : String = Utils.get_str_in_array(key, data)
	
	if not extracted.is_empty():
		return extracted.split(":")[1]
	return def

static func get_vector2i(string: String, delimiter: String = ",") -> Vector2i:
	var vec_data : String = string
	vec_data = vec_data.replace("(", "").replace(")", "")
	vec_data = vec_data.replace("[", "").replace("]", "")
	vec_data = vec_data.replace(" ", "")
	
	var split : Array[String] = Utils.unpack_strings(vec_data.split(delimiter))
	if split.size() == 2:
		return Vector2i(int(split[0]), int(split[1]))
	return Vector2i(-50, -50)

# Any entity or tile can never have a game position less than Vector2i(-1, -1)
# Therefore this will be the NULL position that we will use
const NULL_VECTOR : Vector2i = Vector2i(50, 50)

const NORTH_WEST_2i : Vector2i = Vector2i.DOWN + Vector2i.RIGHT
const NORTH_2i : Vector2i = Vector2i.DOWN
const NORTH_EAST_2i : Vector2i = Vector2i.DOWN + Vector2i.LEFT
const EAST_2i : Vector2i = Vector2i.LEFT
const SOUTH_EAST_2i : Vector2i = Vector2i.UP + Vector2i.LEFT
const SOUTH_2i : Vector2i = Vector2i.UP
const SOUTH_WEST_2i : Vector2i = Vector2i.UP  + Vector2i.RIGHT
const WEST_2i : Vector2i = Vector2i.RIGHT

static func get_adjacent(pos: Vector2i, corners: bool = true) -> Array[Vector2i]:
	var sides : Array[Vector2i] = [pos + NORTH_2i, 
		pos + EAST_2i, 
		pos + SOUTH_2i, 
		pos + WEST_2i]
	
	var _corners : Array[Vector2i] = [pos + NORTH_WEST_2i, 
		pos + NORTH_EAST_2i, 
		pos + SOUTH_EAST_2i, 
		pos + SOUTH_WEST_2i]
	
	if corners:
		return sides + _corners
	return sides

static func get_box(pos: Vector2i, size: int) -> Array[Vector2i]:
	var tiles : Array[Vector2i] = []
	
	for x in range(-size, size + 1):
		for y in range(-size, size + 1):
			tiles.append(pos + Vector2i(x, y))
	return tiles

## NOTE: UP and DOWN are reflected when drawing tiles.
## Because the map draws from [0, 0] to [-INF, -INF]
static func get_adjacency_map(pos: Vector2i) -> Dictionary:
	return {
		"ME": pos,
		"UP": pos + NORTH_2i,
		"RIGHT": pos + EAST_2i,
		"DOWN": pos + SOUTH_2i,
		"LEFT": pos + WEST_2i,
		"UP_RIGHT": pos + NORTH_EAST_2i,
		"DOWN_RIGHT": pos + SOUTH_EAST_2i,
		"DOWN_LEFT": pos + SOUTH_WEST_2i,
		"UP_LEFT": pos + NORTH_WEST_2i,
	}

static func get_opposite(dir: Vector2i) -> Vector2i:
	match dir:
		NORTH_WEST_2i:
			return SOUTH_EAST_2i
		NORTH_2i:
			return SOUTH_2i
		NORTH_EAST_2i:
			return SOUTH_WEST_2i
		EAST_2i:
			return WEST_2i
		SOUTH_EAST_2i:
			return NORTH_WEST_2i
		SOUTH_2i:
			return NORTH_2i
		SOUTH_WEST_2i:
			return NORTH_EAST_2i
		WEST_2i:
			return EAST_2i
	return Vector2i.ZERO

static func get_right(dir: Vector2i, corners: bool = false) -> Vector2i:
	if corners:
		match dir:
			NORTH_WEST_2i:
				return NORTH_2i
			NORTH_2i:
				return NORTH_EAST_2i
			NORTH_EAST_2i:
				return EAST_2i
			EAST_2i:
				return SOUTH_EAST_2i
			SOUTH_EAST_2i:
				return SOUTH_2i
			SOUTH_2i:
				return SOUTH_WEST_2i
			SOUTH_WEST_2i:
				return WEST_2i
			WEST_2i:
				return NORTH_WEST_2i
	
	match dir:
		NORTH_2i:
			return EAST_2i
		EAST_2i:
			return SOUTH_2i
		SOUTH_2i:
			return WEST_2i
		WEST_2i:
			return NORTH_2i
	return Vector2i.ZERO

static func get_left(dir: Vector2i, corners: bool = false) -> Vector2i:
	if corners:
		match dir:
			NORTH_WEST_2i:
				return WEST_2i
			NORTH_2i:
				return NORTH_WEST_2i
			NORTH_EAST_2i:
				return NORTH_2i
			EAST_2i:
				return NORTH_EAST_2i
			SOUTH_EAST_2i:
				return EAST_2i
			SOUTH_2i:
				return SOUTH_EAST_2i
			SOUTH_WEST_2i:
				return SOUTH_2i
			WEST_2i:
				return SOUTH_WEST_2i
	
	match dir:
		NORTH_2i:
			return WEST_2i
		EAST_2i:
			return NORTH_2i
		SOUTH_2i:
			return EAST_2i
		WEST_2i:
			return SOUTH_2i
	return Vector2i.ZERO

static func get_angle_from_dir(dir: Vector2i) -> int:
	match dir:
		NORTH_2i:
			return 0
		EAST_2i:
			return -90
		SOUTH_2i:
			return -180
		WEST_2i:
			return -270
	return 0

## NOTE: UP and DOWN are reflected when drawing tiles.
## Pass Adjusted to account for this!
static func get_dir_to(from: Vector2i, to: Vector2i, adjusted: bool = false) -> Vector2i:
	# Test Cases
	#Vector2i(round(Vector2(1, 2).direction_to(Vector2(0, 2))))
	#Vector2i(round(Vector2(0, 0).direction_to(Vector2(0, 1))))
	#Vector2i(round(Vector2(0, 0).direction_to(Vector2(1, 1))))
	#Vector2i(round(Vector2(0, 0).direction_to(Vector2(1, 2))))
	var dir : Vector2i = Vector2i(round(Vector2(from).direction_to(Vector2(to))))
	return Utils.get_opposite(dir) if not adjusted else dir

static func get_infront(from: Vector2i, to: Vector2i) -> Array[Vector2i]:
	var tiles : Array[Vector2i] = []
	var dir : Vector2i = get_dir_to(from, to, true)
	
	tiles.append(from + dir)
	tiles.append(from + Utils.get_left(dir, true))
	tiles.append(from + Utils.get_right(dir, true))
	
	return tiles

static func get_backwards(from: Vector2i, to: Vector2i) -> Array[Vector2i]:
	var tiles : Array[Vector2i] = []
	var dir : Vector2i = get_dir_to(from, to, true)
	
	tiles.append(from - dir)
	tiles.append(from - Utils.get_left(dir, true))
	tiles.append(from - Utils.get_right(dir, true))
	
	return tiles

static func get_line(from: Vector2i, to: Vector2i, dist: int) -> Array[Vector2i]:
	var tiles : Array[Vector2i] = []
	var dir : Vector2i = get_dir_to(from, to, true)
	
	for i in range(dist + 1):
		var offset : Vector2i = from + dir * i
		tiles.append(offset)
	
	return tiles

#static var instance : Main = null
#func _init() -> void:
	#instance = self
#
#static func inst() -> Main:
	#return instance

	#var start = Time.get_ticks_usec()
	#var end = Time.get_ticks_usec()
	#var worker_time = (end-start)/1000000.0
	#print("Worker time: %s" % [worker_time])
	
	#print("Draw Calls: " \
		#+ str(Performance.get_monitor(Performance.RENDER_TOTAL_DRAW_CALLS_IN_FRAME)))
