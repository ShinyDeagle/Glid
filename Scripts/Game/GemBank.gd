class_name GemBank
extends RefCounted

var fire_gems : int = 0
var water_gems : int = 0
var grass_gems : int = 0
var electric_gems : int = 0
var psychic_gems : int = 0
var gold : int = 0

func to_data() -> Dictionary:
	return {
		"Fire": fire_gems,
		"Water": water_gems,
		"Grass": grass_gems,
		"Electric": electric_gems,
		"Psychic": psychic_gems,
	}

func from_data(data: Dictionary) -> void:
	for type in data:
		match type:
			"Fire":
				fire_gems = data[type]
			"Water":
				water_gems = data[type]
			"Grass":
				grass_gems = data[type]
			"Electric":
				electric_gems = data[type]
			"Psychic":
				psychic_gems = data[type]
			"Gold":
				gold = data[type]

func can_afford(cost: Dictionary) -> bool:
	var bank : Dictionary = to_data()
	
	var missing : int = 0
	for type in bank:
		var to_pay : int = cost.get(type, 0) as int
		if to_pay <= 0:
			continue
		
		var bank_amount : int = bank.get(type, 0) as int
		if bank_amount < to_pay:
			missing += to_pay - bank_amount
		else:
			bank[type] -= to_pay
	
	if missing > 0:
		if self.gold < missing:
			return false
		
		self.gold -= missing
	
	return true

func difference(other: GemBank) -> GemBank:
	var bank : Dictionary = to_data()
	var other_bank : Dictionary = other.to_data()
	var result : Dictionary = bank.duplicate()
	
	var result_bank : GemBank = GemBank.new()
	
	for type in bank:
		result[type] = abs(bank.get(type, 0) - other_bank.get(type, 0))
	
	result_bank.from_data(result)
	
	result_bank.gold = abs(self.gold - other.gold)
	
	return result_bank

func add_to(other: GemBank) -> void:
	var bank : Dictionary = to_data()
	var other_bank : Dictionary = other.to_data()
	var result : Dictionary = bank.duplicate()
	
	for type in bank:
		result[type] = bank.get(type, 0) + other_bank.get(type, 0)
	
	other.from_data(result)
	other.gold = self.gold + other.gold

func buy(cost: Dictionary) -> bool:
	if not can_afford(cost):
		return false
	
	var bank : Dictionary = to_data()
	
	var missing : int = 0
	for type in bank:
		var to_pay : int = cost.get(type, 0) as int
		if to_pay <= 0:
			continue
		
		var bank_amount : int = bank.get(type, 0) as int
		if bank_amount < to_pay:
			missing += to_pay - bank_amount
		else:
			bank[type] -= to_pay
	
	if missing > 0:
		if self.gold < missing:
			return false
		
		self.gold -= missing
	
	from_data(bank)
	return true
