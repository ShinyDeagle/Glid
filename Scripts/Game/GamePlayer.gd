class_name GamePlayer
extends Control

var player : Player = null

func setup(_player: Player) -> void:
	player = _player
	
	%Name.text = player.username

func _ready() -> void:
	update.connect(_update, CONNECT_DEFERRED)

signal update
func _update() -> void:
	if not player:
		return
	
	_update_points()
	
	_update_gem(%Player_Gem_Gold, player.gold)
	_update_gem(%Player_Gem_Fire, player.fire_gems)
	_update_gem(%Player_Gem_Water, player.water_gems)
	_update_gem(%Player_Gem_Grass, player.grass_gems)
	_update_gem(%Player_Gem_Electric, player.electric_gems)
	_update_gem(%Player_Gem_Psychic, player.psychic_gems)
	
	_update_stash(%Stash_Fire, player.fire_cards)
	_update_stash(%Stash_Water, player.water_cards)
	_update_stash(%Stash_Grass, player.grass_cards)
	_update_stash(%Stash_Electric, player.electric_cards)
	_update_stash(%Stash_Psychic, player.psychic_cards)

func _update_points() -> void:
	if not player:
		return
	
	%Points.text = str(player.points)

func _update_gem(what: Control, amt: int) -> void:
	var label : Label = what.get_node("%Amount") as Label
	label.text = str(amt)
	
	what.modulate = Color.WHITE.darkened(0.5) if amt <= 0 else Color.WHITE

func _update_stash(what: Control, amt: int) -> void:
	var label : Label = what.get_node("%Amount") as Label
	label.text = str(amt)
	
	what.modulate = Color.WHITE.darkened(0.5) if amt <= 0 else Color.WHITE

func buy_card(what: Card) -> bool:
	var data : CardData = what.data
	
	if not data.can_afford(player):
		return false
	
	var fire_to_pay : int = max(0, data.card_fire_cost - player.fire_cards)
	var water_to_pay : int = max(0, data.card_water_cost - player.water_cards)
	var grass_to_pay : int = max(0, data.card_grass_cost - player.grass_cards)
	var electric_to_pay : int = max(0, data.card_electric_cost - player.electric_cards)
	var psychic_to_pay : int = max(0, data.card_psychic_cost - player.psychic_cards)
	
	var gold_cost : int = (fire_to_pay - player.fire_gems) + \
		(water_to_pay - player.water_gems) + \
		(grass_to_pay - player.grass_gems) + \
		(electric_to_pay - player.electric_gems) + \
		(psychic_to_pay - player.psychic_gems)
	
	Session.inst().fire_gems += min(player.fire_gems, fire_to_pay)
	Session.inst().water_gems += min(player.water_gems, water_to_pay)
	Session.inst().grass_gems += min(player.grass_gems, grass_to_pay)
	Session.inst().electric_gems += min(player.electric_gems, electric_to_pay)
	Session.inst().psychic_gems += min(player.psychic_gems, psychic_to_pay)
	
	player.fire_gems -= fire_to_pay
	player.water_gems -= water_to_pay
	player.grass_gems -= grass_to_pay
	player.electric_gems -= electric_to_pay
	player.psychic_gems -= psychic_to_pay
	player.gold -= gold_cost
	
	player.points += data.card_points
	
	_on_card_bought(data)
	_update()
	
	return true

func _on_card_bought(card: CardData) -> void:
	match card.card_type:
		"Fire":
			player.fire_cards += 1
		"Water":
			player.water_cards += 1
		"Grass":
			player.grass_cards += 1
		"Electric":
			player.electric_cards += 1
		"Psychic":
			player.psychic_cards += 1

func get_gem_total() -> int:
	return player.fire_gems \
		+ player.water_gems \
		+ player.grass_gems \
		+ player.electric_gems \
		+ player.psychic_gems
