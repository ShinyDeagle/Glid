class_name CardData
extends FactoryItem

var card_id : int = 0
var card_tier : int = 0
var card_type : String = "Fire"
var card_fire_cost : int = 0
var card_water_cost : int = 0
var card_grass_cost : int = 0
var card_electric_cost : int = 0
var card_psychic_cost : int = 0
var card_points : int = 0

const CARD_DATABASE_PATH : String = "res://Data/Database_Player.tsv"
static var all_cards : Array[CardData] = []
static var card_map : Dictionary = {}
static var keys : Array[String] = []
static func load_database() -> void:
	var database_dir : FileAccess = FileAccess.open(CARD_DATABASE_PATH, FileAccess.READ)
	if not database_dir:
		Main.inst().debug("Card Loader", "DATABASE DOES NOT EXIST", Main.DEBUG_LEVEL.ERROR)
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
		
		var card : CardData = _generate(array)
		
		all_cards.append(card)
		card_map[card.card_id] = card
		
		index += 1
		Main.inst().debug("Card Data", "Loaded Card #" + str(index - DATABASE_DUMMY_ROWS) + " - " \
			+ "ID: " + str(card.card_id), Main.DEBUG_LEVEL.DATA)
	Main.inst().debug("Card Data", "Loaded " + str(index - DATABASE_DUMMY_ROWS) \
		+ " Cards", Main.DEBUG_LEVEL.DATA)

static func _generate(data: Array[String]) -> CardData:
	var card : CardData = CardData.new()
	card.assign_data(data)
	card.set_keys(keys)
	
	card.card_id = all_cards.size()
	card.card_tier = card.read_int("Tier", 1)
	card.card_type = card.read_string("Type", "Fire")
	card.card_fire_cost = card.read_int("Fire", 0)
	card.card_water_cost = card.read_int("Water", 0)
	card.card_grass_cost = card.read_int("Grass", 0)
	card.card_electric_cost = card.read_int("Electric", 0)
	card.card_psychic_cost = card.read_int("Psychic", 0)
	card.card_points = card.read_int("Points", 0)
	
	card.release()
	
	return card

func can_afford(who: Player) -> bool:
	if who == null:
		return false
	
	var fire_to_pay : int = max(0, card_fire_cost - who.fire_cards - who.fire_gems)
	var water_to_pay : int = max(0, card_water_cost - who.water_cards - who.water_gems)
	var grass_to_pay : int = max(0, card_grass_cost - who.grass_cards - who.grass_gems)
	var electric_to_pay : int = max(0, card_electric_cost - who.electric_cards - who.electric_gems)
	var psychic_to_pay : int = max(0, card_psychic_cost - who.psychic_cards - who.psychic_gems)
	var leftover : int = fire_to_pay + \
		water_to_pay + \
		grass_to_pay + \
		electric_to_pay + \
		psychic_to_pay
	
	return not (leftover > 0 and who.gold < leftover)
