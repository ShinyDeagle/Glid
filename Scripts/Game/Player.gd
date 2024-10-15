class_name Player
extends RefCounted

# Multiplayer ID | Random By Default
var id : int = randi()
var username : String = "Player"

var bank : GemBank = GemBank.new()
var card_bank : GemBank = GemBank.new()

var points : int = 0

var deck : Array[CardData] = []

func get_gem_total() -> int:
	return bank.gold + bank.fire_gems + bank.water_gems + bank.grass_gems + bank.electric_gems + bank.psychic_gems
