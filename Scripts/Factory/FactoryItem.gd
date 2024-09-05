class_name FactoryItem
extends Resource

static func _generate(_ddata: Array[String]) -> FactoryItem:
	return null

const DATABASE_DUMMY_ROWS : int = 1
var _key_map : Dictionary = {}
func set_keys(keys: Array[String]) -> void:
	if keys.size() > 0:
		for i in range(keys.size()):
			_key_map[keys[i]] = i

var _data : Array[String] = []
func assign_data(data: Array[String]) -> void:
	_data = data

## Frees up some memory after assigning data, 
## Weird operation because you can't set _data to null, 
## Hence, does it even release shit?
func release() -> void:
	_data.clear()
	_key_map.clear()
	
func valid(index: int) -> bool:
	return not _data.is_empty() and not _data.size() <= index

func is_null(index: int) -> bool:
	return _data[index] == "-"

func get_index(key: String) -> int:
	if not key in _key_map:
		return -1
	return _key_map[key]

func read_int(key: String, def: int = -1) -> int:
	var index : int = get_index(key)
	
	if not valid(index):
		print("Factory Item: " + self.resource_name + " - Invalid Read on Int at Index: " + str(index))
		return def
	
	if is_null(index):
		return def
	
	return int(_data[index])

func read_float(key: String, def: float = -1.0) -> float:
	var index : int = get_index(key)
	
	if not valid(index):
		print("Factory Item: " + self.resource_name + " - Invalid Read on Float at Index: " + str(index))
		return def
	
	if is_null(index):
		return def
	
	return float(_data[index])

func read_string(key: String, def: String = "") -> String:
	var index : int = get_index(key)
	
	if not valid(index):
		print("Factory Item: " + self.resource_name + " - Invalid Read on String at Index: " + str(index))
		return def
	
	if is_null(index):
		return def
	
	return _data[index]

func read_bool(key: String, def: bool = false) -> bool:
	var index : int = get_index(key)
	
	if not valid(index):
		print("Factory Item: " + self.resource_name + " - Invalid Read on Bool at Index: " + str(index))
		return def
	
	if is_null(index):
		return def
	
	return _data[index] == "Yes"

func read_array(key: String, split = ",", def: Array[String] = []) -> Array[String]:
	var index : int = get_index(key)
	
	if not valid(index):
		print("Factory Item: " + self.resource_name + " - Invalid Read on Array at Index: " + str(index))
		return def
	
	if is_null(index):
		return def
	
	return Utils.unpack_strings(_data[index].split(split, false))

func read_int_array(key: String, split = ",", range_split = "-", def: Array[int] = []) -> Array[int]:
	var index : int = get_index(key)
	
	if not valid(index):
		print("Factory Item: " + self.resource_name + " - Invalid Read on Int Array at Index: " + str(index))
		return def
	
	if is_null(index):
		return def
	
	var result : Array[int] = []
	var int_data : Array[String] = Utils.unpack_strings(_data[index].split(split, false))
	
	for int_str : String in int_data:
		var int_split : Array[String] = Utils.unpack_strings(int_str.split(range_split))
		if int_split.size() == 2 and not int_split.front() == "":
			for num in range(int(int_split.front()), int(int_split.back())):
				result.append(int(num))
		else:
			result.append(int(int_str))
	
	return result

func read_float_array(key: String, split = ",", range_split = "-", def: Array[float] = []) -> Array[float]:
	var index : int = get_index(key)
	
	if not valid(index):
		print("Factory Item: " + self.resource_name + " - Invalid Read on Float Array at Index: " + str(index))
		return def
	
	if is_null(index):
		return def
	
	var result : Array[float] = []
	var float_data : Array[String] = Utils.unpack_strings(_data[index].split(split, false))
	
	for float_str : String in float_data:
		var float_split : Array[String] = Utils.unpack_strings(float_str.split(range_split))
		if float_split.size() == 2 and not float_split.front() == "":
			for num in range(float(float_split.front()), float(float_split.back())):
				result.append(float(num))
		else:
			result.append(float(float_str))
	
	return result

func read_dict(key: String, split: String = ",", seperator: String = ":", prefix: String = "", def: Dictionary = {}) -> Dictionary:
	var index : int = get_index(key)
	
	if not valid(index):
		print("Factory Item: " + self.resource_name + " - Invalid Read on Array at Index: " + str(index))
		return def
	
	if is_null(index):
		return def
	
	var array : Array[String] = Utils.unpack_strings(_data[index].split(split, false))
	var result : Dictionary = {}
	for e in array:
		var data : Array[String] = Utils.unpack_strings(e.split(seperator))
		if not data.size() == 2:
			continue
		
		result[prefix + data[0]] = data[1]
	
	return result

func read_vector_grid(key: String, split: String = ",", seperator: String = ":", def: Dictionary = {}) -> Dictionary:
	var index : int = get_index(key)
	
	if not valid(index):
		print("Factory Item: " + self.resource_name + " - Invalid Read on Array at Index: " + str(index))
		return def
	
	if is_null(index):
		return def
	
	var array : Array[String] = Utils.unpack_strings(_data[index].split(split, false))
	var result : Dictionary = {}
	for e in array:
		var data : Array[String] = Utils.unpack_strings(e.split(seperator))
		if not data.size() == 2:
			continue
		
		var vector : Vector2i = Utils.get_vector2i(data[0])
		result[vector] = data[1]
	
	return result

func read_grid(key: String, x_split: String = ",", y_split: String = " ", def: Dictionary = {}) -> Dictionary:
	var index : int = get_index(key)
	
	if not valid(index):
		print("Factory Item: " + self.resource_name + " - Invalid Read on Array at Index: " + str(index))
		return def
	
	if is_null(index):
		return def
	
	var result : Dictionary = {}
	var array : Array[String] = Utils.unpack_strings(_data[index].split(y_split, false))
	var y : int = 0
	for row in array:
		var cols : Array[String] = Utils.unpack_strings(row.split(x_split, false))
		var x : int = 0
		for col in cols:
			result[Vector2i(x, y)] = col
			x += 1
		y += 1
	
	return result

func read_vector3(key: String, split = "x", def: Vector3 = Vector3.ONE) -> Vector3:
	var index : int = get_index(key)
	
	if not valid(index):
		print("Factory Item: " + self.resource_name + " - Invalid Read on Array at Index: " + str(index))
		return def
	
	if is_null(index):
		return def
	
	var array : Array[String] = Utils.unpack_strings(_data[index].split(split, false))
	if not array.size() == 3:
		return def
	
	return Vector3(float(array[0]), float(array[1]), float(array[2]))
	
func read_vector3i(key: String, split = "x", def: Vector3 = Vector3i.ONE) -> Vector3i:
	var index : int = get_index(key)
	
	if not valid(index):
		print("Factory Item: " + self.resource_name + " - Invalid Read on Array at Index: " + str(index))
		return def
	
	if is_null(index):
		return def
	
	var array : Array[String] = Utils.unpack_strings(_data[index].split(split, false))
	if not array.size() == 3:
		return def
	
	return Vector3i(int(array[0]), int(array[1]), int(array[2]))

func read_color(key: String, def: Color = Color.RED) -> Color:
	var index : int = get_index(key)
	
	if not valid(index):
		print("Factory Item: " + self.resource_name + " - Invalid Read on Color at Index: " + str(index))
		return def
	
	if is_null(index):
		return def
	
	# Supports Hex and Named Colors
	return Color.from_string( _data[index], Color.BLACK)

func read_range(key: String, def: Array[int] = [1, 1]) -> Array[int]:
	var index : int = get_index(key)
	
	if not valid(index):
		print("Factory Item: " + self.resource_name + " - Invalid Read on Range at Index: " + str(index))
		return def
	
	if is_null(index):
		return def
	
	var range_data : Array[String] = Utils.unpack_strings(_data[index].split("-"))
	if range_data.size() < 2:
		return [1, int(range_data[0])]
	
	return [int(range_data[0]), int(range_data[1])]
