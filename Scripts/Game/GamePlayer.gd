class_name GamePlayer
extends Control

var player : Player = null

func setup(_player: Player) -> void:
	player = _player
	
	%Name.text = player.username

func _ready() -> void:
	update.connect(_update, CONNECT_DEFERRED)
	
	var deck_button : Button = %Player_Deck.get_node("%Button") as Button
	deck_button.visible = true
	deck_button.toggled.connect(toggle_deck)

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
	
	_update_deck()
	toggle_deck(false)

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

func _update_deck() -> void:
	%Player_Deck.visibility_layer = 0 if player.deck.is_empty() else 1
	%Player_Deck.get_node("%Amount").text = str(player.deck.size())

func buy_card(what: Card) -> bool:
	var data : CardData = what.data
	
	if not data.can_afford(player):
		return false
	
	var fire_to_pay : int = max(0, data.card_fire_cost - player.fire_cards)
	var water_to_pay : int = max(0, data.card_water_cost - player.water_cards)
	var grass_to_pay : int = max(0, data.card_grass_cost - player.grass_cards)
	var electric_to_pay : int = max(0, data.card_electric_cost - player.electric_cards)
	var psychic_to_pay : int = max(0, data.card_psychic_cost - player.psychic_cards)
	
	var gold_cost : int = (max(0, fire_to_pay - player.fire_gems)) + \
		(max(0, water_to_pay - player.water_gems)) + \
		(max(0, grass_to_pay - player.grass_gems)) + \
		(max(0, electric_to_pay - player.electric_gems)) + \
		(max(0, psychic_to_pay - player.psychic_gems))
	
	Session.inst().gold += gold_cost
	Session.inst().fire_gems += min(player.fire_gems, fire_to_pay)
	Session.inst().water_gems += min(player.water_gems, water_to_pay)
	Session.inst().grass_gems += min(player.grass_gems, grass_to_pay)
	Session.inst().electric_gems += min(player.electric_gems, electric_to_pay)
	Session.inst().psychic_gems += min(player.psychic_gems, psychic_to_pay)
	Session.inst().update()
	
	player.fire_gems = clampi(player.fire_gems - fire_to_pay, 0, 4)
	player.water_gems = clampi(player.water_gems - water_to_pay, 0, 4)
	player.grass_gems = clampi(player.grass_gems - grass_to_pay, 0, 4)
	player.electric_gems = clampi(player.electric_gems - electric_to_pay, 0, 4)
	player.psychic_gems = clampi(player.psychic_gems - psychic_to_pay, 0, 4)
	player.gold -= max(0, gold_cost)
	
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

func hold_card(card: Card) -> bool:
	if player.deck.size() >=  Session.PLAYER_MAX_DECK_SIZE:
		return false
	var data : CardData = card.data
	
	player.gold += 1
	Session.inst().gold -= 1
	player.deck.append(data)
	
	_update_deck()
	return true

func hold_card_from_deck(card: CardData) -> void:
	player.gold += 1
	Session.inst().gold -= 1
	player.deck.append(card)
	
	_update_deck()

func get_gem_total() -> int:
	return player.gold \
		+ player.fire_gems \
		+ player.water_gems \
		+ player.grass_gems \
		+ player.electric_gems \
		+ player.psychic_gems

func toggle_deck(flag: bool) -> void:
	%Deck_Control.visible = flag
	
	Utils.free_children(%Deck)
	
	if flag:
		for card : CardData in player.deck:
			var visual : Card = AssetLoader.get_card()
			visual.setup(card)
			
			%Deck.add_child(visual)
			visual.update()
			
			visual.get_node("%Button").visible = true
			if Session.inst().current_player == player:
				visual.get_node("%Button").pressed.connect(Session.inst()._on_select_card.bind(visual, true))
	else:
		Session.inst()._on_deselect()
		%Player_Deck.get_node("%Button").set_pressed_no_signal(false)
