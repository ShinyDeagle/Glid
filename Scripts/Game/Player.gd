class_name Player
extends RefCounted

# Multiplayer ID | Random By Default
var id : int = randi()
var username : String = "Player"

var fire_gems : int = 0
var water_gems : int = 0
var grass_gems : int = 0
var electric_gems : int = 0
var psychic_gems : int = 0

var fire_cards : int = 0
var water_cards : int = 0
var grass_cards : int = 0
var electric_cards : int = 0
var psychic_cards : int = 0

var gold : int = 0
var points : int = 0

var deck : Array[CardData] = []
