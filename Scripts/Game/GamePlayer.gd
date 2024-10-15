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
	
	_update_gem(%Player_Gem_Gold, player.bank.gold)
	_update_gem(%Player_Gem_Fire, player.bank.fire_gems)
	_update_gem(%Player_Gem_Water, player.bank.water_gems)
	_update_gem(%Player_Gem_Grass, player.bank.grass_gems)
	_update_gem(%Player_Gem_Electric, player.bank.electric_gems)
	_update_gem(%Player_Gem_Psychic, player.bank.psychic_gems)
	
	# It says gems but this updates the player's card bank instead!
	_update_stash(%Stash_Fire, player.card_bank.fire_gems)
	_update_stash(%Stash_Water, player.card_bank.water_gems)
	_update_stash(%Stash_Grass, player.card_bank.grass_gems)
	_update_stash(%Stash_Electric, player.card_bank.electric_gems)
	_update_stash(%Stash_Psychic, player.card_bank.psychic_gems)
	
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
	
	var card_bank : GemBank = GemBank.new()
	card_bank.from_data(what.data.get_cost_data())
	
	# TODO: Make the player's bank take into account the cards he has.
	var difference : GemBank = player.bank.difference(card_bank)
	
	difference.add_to(Session.bank)
	Session.inst().update()
	
	player.bank.buy(data.get_cost_data())
	
	player.points += data.card_points
	
	_on_card_bought(data)
	_update()
	
	return true

func _on_card_bought(card: CardData) -> void:
	# It says gems but this updates the player's card bank instead.
	match card.card_type:
		"Fire":
			player.card_bank.fire_gems += 1
		"Water":
			player.card_bank.water_gems += 1
		"Grass":
			player.card_bank.grass_gems += 1
		"Electric":
			player.card_bank.electric_gems += 1
		"Psychic":
			player.card_bank.psychic_gems += 1

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
