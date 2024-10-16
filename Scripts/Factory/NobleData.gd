class_name NobleData
extends FactoryItem

var noble_id : int = 0
var noble_fire_cost : int = 0
var noble_water_cost : int = 0
var noble_grass_cost : int = 0
var noble_electric_cost : int = 0
var noble_psychic_cost : int = 0
var noble_points : int = 0

const NOBLE_DATABASE_PATH : String = "res://Data/Database_Nobles.tsv"
static var all_nobles : Array[NobleData] = []
static var noble_map : Dictionary = {}
static var keys : Array[String] = []
static func load_database() -> void:
	var database_dir : FileAccess = FileAccess.open(NOBLE_DATABASE_PATH, FileAccess.READ)
	if not database_dir:
		Main.inst().debug("Noble Loader", "DATABASE DOES NOT EXIST", Main.DEBUG_LEVEL.ERROR)
		assert(false)
	
	var database : String = database_dir.get_as_text(true)
	database_dir.close()
	
	var index : int = 0
	for line in database.split("\n"):
		line = line as String
		var array : Array[String] = Utils.unpack_strings(line.split("	"))
		
		if index < DATABASE_DUMMY_ROWS:
			keys = array.duplicate()
			index += 1 
			continue
		
		var noble : NobleData = _generate(array)
		
		all_nobles.append(noble)
		noble_map[noble.noble_id] = noble
		
		index += 1
		Main.inst().debug("Noble Data", "Loaded Noble #" + str(index - DATABASE_DUMMY_ROWS) + " - " \
			+ "ID: " + str(noble.noble_id), Main.DEBUG_LEVEL.DATA)
	
	var last_noble : NobleData = all_nobles.pop_back() as NobleData
	noble_map.erase(last_noble.noble_id)
	
	Main.inst().debug("Noble Data", "Loaded " + str(index - DATABASE_DUMMY_ROWS) \
		+ " Nobles", Main.DEBUG_LEVEL.DATA)

static func _generate(data: Array[String]) -> NobleData:
	var noble : NobleData = NobleData.new()
	noble.assign_data(data)
	noble.set_keys(keys)
	
	noble.noble_id = all_nobles.size()
	noble.noble_fire_cost = noble.read_int("Fire", 0)
	noble.noble_water_cost = noble.read_int("Water", 0)
	noble.noble_grass_cost = noble.read_int("Grass", 0)
	noble.noble_electric_cost = noble.read_int("Electric", 0)
	noble.noble_psychic_cost = noble.read_int("Psychic", 0)
	noble.noble_points = noble.read_int("Points", 0)
	
	noble.release()
	
	return noble

func get_cost_data() -> Dictionary:
	return {
		"Fire": noble_fire_cost,
		"Water": noble_water_cost,
		"Grass": noble_grass_cost,
		"Electric": noble_electric_cost,
		"Psychic": noble_psychic_cost,
	}

func can_afford(who: Player) -> bool:
	if who == null:
		return false
	
	var bank : Dictionary = who.bank.to_data()
	var cost_data : Dictionary = get_cost_data()
	for type in cost_data:
		if cost_data[type] > bank[type]:
			return false
	
	return true
