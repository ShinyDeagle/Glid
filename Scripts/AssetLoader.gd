extends Node

const PLAYER : PackedScene = preload("res://Scenes/Game/Player.tscn")
const PLAYER_ARROW : PackedScene = preload("res://Scenes/Game/Player_Arrow.tscn")
const CARD : PackedScene = preload("res://Scenes/Game/Card.tscn")

const GEM : Dictionary = {
	"Fire": preload("res://Scenes/Game/Gems/Gem_Fire.tscn"),
	"Water": preload("res://Scenes/Game/Gems/Gem_Water.tscn"),
	"Grass": preload("res://Scenes/Game/Gems/Gem_Grass.tscn"),
	"Electric": preload("res://Scenes/Game/Gems/Gem_Electric.tscn"),
	"Psychic": preload("res://Scenes/Game/Gems/Gem_Psychic.tscn"),
	"Gold": preload("res://Scenes/Game/Gems/Gem_Gold.tscn"),
}

static var CARD_MODULATE_COLOR : Dictionary = {
	"Fire": Color.from_string("ff9696", Color.WHITE),
	"Water": Color.from_string("96ecff", Color.WHITE),
	"Grass": Color.from_string("96ff9a", Color.WHITE),
	"Electric": Color.from_string("ffa154", Color.WHITE),
	"Psychic": Color.from_string("cc96ff", Color.WHITE),
}

const GEM_ICON : Dictionary = {
	"Fire": preload("res://Assets/Texture/Icon_Fire.png"),
	"Water": preload("res://Assets/Texture/Icon_Water.png"),
	"Grass": preload("res://Assets/Texture/Icon_Grass.png"),
	"Electric": preload("res://Assets/Texture/Icon_Electric.png"),
	"Psychic": preload("res://Assets/Texture/Icon_Psychic.png"),
}

const GEM_COIN : Dictionary = {
	"Fire": preload("res://Assets/Texture/Texture_Fire.png"),
	"Water": preload("res://Assets/Texture/Texture_Water.png"),
	"Grass": preload("res://Assets/Texture/Texture_Grass.png"),
	"Electric": preload("res://Assets/Texture/Texture_Electric.png"),
	"Psychic": preload("res://Assets/Texture/Texture_Psychic.png"),
	"Gold": preload("res://Assets/Texture/Texture_Gold.png"),
}

const GEM_PLAYER : Dictionary = {
	"Fire": preload("res://Scenes/Game/Gems/Player_Gem_Fire.tscn"),
	"Water": preload("res://Scenes/Game/Gems/Player_Gem_Water.tscn"),
	"Grass": preload("res://Scenes/Game/Gems/Player_Gem_Grass.tscn"),
	"Electric": preload("res://Scenes/Game/Gems/Player_Gem_Electric.tscn"),
	"Psychic": preload("res://Scenes/Game/Gems/Player_Gem_Psychic.tscn"),
	"Gold": preload("res://Scenes/Game/Gems/Player_Gem_Gold.tscn"),
}

const GEM_COST : Dictionary = {
	"Fire": preload("res://Scenes/Game/Gems/Gem_Cost_Fire.tscn"),
	"Water": preload("res://Scenes/Game/Gems/Gem_Cost_Water.tscn"),
	"Grass": preload("res://Scenes/Game/Gems/Gem_Cost_Grass.tscn"),
	"Electric": preload("res://Scenes/Game/Gems/Gem_Cost_Electric.tscn"),
	"Psychic": preload("res://Scenes/Game/Gems/Gem_Cost_Psychic.tscn"),
}

const GEM_STASH : Dictionary = {
	"Fire": preload("res://Scenes/Game/Stash/Stash_Fire.tscn"),
	"Water": preload("res://Scenes/Game/Stash/Stash_Water.tscn"),
	"Grass": preload("res://Scenes/Game/Stash/Stash_Grass.tscn"),
	"Electric": preload("res://Scenes/Game/Stash/Stash_Electric.tscn"),
	"Psychic": preload("res://Scenes/Game/Stash/Stash_Psychic.tscn"),
}
