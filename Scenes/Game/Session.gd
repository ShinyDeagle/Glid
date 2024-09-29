class_name Session
extends Control

static var instance : Session = null
func _init() -> void:
	instance = self

static func inst() -> Session:
	return instance

var players : Array[Player] = []
var ordered_players : Array[Player] = []
var player_to_visual : Dictionary = {}

var current_index : int = -1
var current_player : Player = null
func _next_player() -> void:
	current_index += 1
	if current_index >= players.size():
		current_index = 0
	
	current_player = ordered_players[current_index]
	
	var index : int = 0
	for arrow : TextureRect in %Arrows.get_children().duplicate():
		var show_arrow : bool = index == current_index
		arrow.visibility_layer = 0 if not show_arrow else 1
		index += 1

func _ready() -> void:
	%Gem_Fire.get_node("%Button").mouse_entered.connect(_hover_enter_gem.bind("Fire"))
	%Gem_Fire.get_node("%Button").mouse_exited.connect(_hover_exit_gem)
	%Gem_Fire.get_node("%Button").gui_input.connect(_gem_press)
	%Gem_Fire.get_node("%Button").visible = true
	
	%Gem_Water.get_node("%Button").mouse_entered.connect(_hover_enter_gem.bind("Water"))
	%Gem_Water.get_node("%Button").mouse_exited.connect(_hover_exit_gem)
	%Gem_Water.get_node("%Button").gui_input.connect(_gem_press)
	%Gem_Water.get_node("%Button").visible = true
	
	%Gem_Grass.get_node("%Button").mouse_entered.connect(_hover_enter_gem.bind("Grass"))
	%Gem_Grass.get_node("%Button").mouse_exited.connect(_hover_exit_gem)
	%Gem_Grass.get_node("%Button").gui_input.connect(_gem_press)
	%Gem_Grass.get_node("%Button").visible = true
	
	%Gem_Electric.get_node("%Button").mouse_entered.connect(_hover_enter_gem.bind("Electric"))
	%Gem_Electric.get_node("%Button").mouse_exited.connect(_hover_exit_gem)
	%Gem_Electric.get_node("%Button").gui_input.connect(_gem_press)
	%Gem_Electric.get_node("%Button").visible = true
	
	%Gem_Psychic.get_node("%Button").mouse_entered.connect(_hover_enter_gem.bind("Psychic"))
	%Gem_Psychic.get_node("%Button").mouse_exited.connect(_hover_exit_gem)
	%Gem_Psychic.get_node("%Button").gui_input.connect(_gem_press)
	%Gem_Psychic.get_node("%Button").visible = true
	
	%Buy_Control.visible = false
	%Buy.pressed.connect(_on_buy, CONNECT_DEFERRED)
	%Hold.pressed.connect(_on_hold, CONNECT_DEFERRED)
	
	%T1.get_node("%Button").pressed.connect(_on_select_deck.bind(%T1))
	%T2.get_node("%Button").pressed.connect(_on_select_deck.bind(%T2))
	%T3.get_node("%Button").pressed.connect(_on_select_deck.bind(%T3))

var hover_gem_type : String = ""
func _hover_enter_gem(type: String) -> void:
	hover_gem_type = type

func _hover_exit_gem() -> void:
	hover_gem_type = ""

func _gem_press(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if not event.is_released():
			return
		
		var add : bool = event.button_index == MOUSE_BUTTON_LEFT
		if not add and event.button_index == MOUSE_BUTTON_RIGHT:
			add = false
		
		if add:
			_on_add_gem(hover_gem_type)
		else:
			_on_putback_gem(hover_gem_type)

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey:
		if not event.is_released():
			return
		
		if event.keycode == KEY_BACKSPACE:
			setup()
		elif event.keycode == KEY_SPACE:
			_on_end_turn()

const MAX_CARDS_PER_TIER : int = 4
const NOBLES_PER_GAME : int = 3
func setup() -> void:
	Utils.free_children(%Nobles, true)
	Utils.free_children(%Tier_1, true)
	Utils.free_children(%Tier_2, true)
	Utils.free_children(%Tier_3, true)
	
	players.clear()
	
	players.append(Player.new())
	players.append(Player.new())
	
	Utils.free_children(%Players, true)
	Utils.free_children(%Arrows, true)
	for p : Player in players:
		var visual : GamePlayer = AssetLoader.PLAYER.instantiate() as GamePlayer
		var arrow : TextureRect = AssetLoader.PLAYER_ARROW.instantiate() as TextureRect
		
		%Arrows.add_child(arrow)
		%Players.add_child(visual)
		visual.setup(p)
		visual.update.emit()
		
		player_to_visual[p] = visual
	
	ordered_players = players.duplicate()
	current_player = ordered_players.front()
	
	t1_pool.clear()
	t2_pool.clear()
	t3_pool.clear()
	
	for card : CardData in CardData.all_cards.duplicate():
		if card.card_tier == 1:
			t1_pool.append(card)
		elif card.card_tier == 2:
			t2_pool.append(card)
		elif card.card_tier == 3:
			t3_pool.append(card)
	
	t1_pool.shuffle()
	t2_pool.shuffle()
	t3_pool.shuffle()
	
	for i in range(MAX_CARDS_PER_TIER):
		add_new_card(1, i)
		add_new_card(2, i)
		add_new_card(3, i)
	
	var nobles : Array[NobleData] = NobleData.all_nobles.duplicate()
	nobles.shuffle()
	
	nobles = nobles.slice(0, NOBLES_PER_GAME)
	
	for noble_data : NobleData in nobles:
		var noble : Noble = AssetLoader.get_noble()
		%Nobles.add_child(noble)
		
		noble.setup(noble_data)
		noble.update()
		noble.get_node("%Button").pressed.connect(_on_select_noble.bind(noble))
		noble.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	
	_next_player()
	update()

static var t1_pool : Array[CardData] = []
static var t2_pool : Array[CardData] = []
static var t3_pool : Array[CardData] = []

func buy_card(who: Player, what: Card) -> void:
	var visual : GamePlayer = player_to_visual[who] as GamePlayer
	var success : bool = visual.buy_card(what)
	
	if not success:
		return
	
	var data : CardData = what.data
	current_player.deck.erase(data)
	
	var index : int = get_child_index(what)
	if not held_card:
		erase_from_pool(what)
	
	what.queue_free()
	if not held_card:
		add_new_card(data.card_tier, index)
	
	%Buy_Control.visible = false
	_on_end_turn()

func buy_noble(who: Player, what: Noble) -> void:
	var success : bool = what.data.can_afford(who)
	if not success:
		return
	
	who.points += what.data.noble_points
	what.modulate = Color.WHITE.darkened(0.6)
	what.get_node("%Button").visible = false
	
	_on_end_turn()

func erase_from_pool(card: Card) -> void:
	var data : CardData = card.data
	if data.card_tier == 1:
		t1_pool.erase(data)
	elif data.card_tier == 2:
		t2_pool.erase(data)
	elif data.card_tier == 3:
		t3_pool.erase(data)

func get_child_index(card: Card) -> int:
	var data : CardData = card.data
	var index : int = -1
	if data.card_tier == 1:
		index = %Tier_1.get_children().find(card)
	elif data.card_tier == 2:
		index = %Tier_2.get_children().find(card)
	elif data.card_tier == 3:
		index = %Tier_3.get_children().find(card)
	return index

func add_new_card(tier: int, index: int) -> void:
	var new_card : CardData = null
	
	if tier == 1:
		new_card = t1_pool.pop_front()
	elif tier == 2:
		new_card = t2_pool.pop_front()
	elif tier == 3:
		new_card = t3_pool.pop_front()
	
	if not new_card:
		return
	
	var card : Card = AssetLoader.CARD.instantiate() as Card
	card.setup(new_card)
	
	if tier == 1:
		%Tier_1.add_child(card)
		%Tier_1.move_child(card, index)
		%T1.get_node("%Amount").text = str(t1_pool.size())
	elif tier == 2:
		%Tier_2.add_child(card)
		%Tier_2.move_child(card, index)
		%T2.get_node("%Amount").text = str(t2_pool.size())
	elif tier == 3:
		%Tier_3.add_child(card)
		%Tier_3.move_child(card, index)
		%T3.get_node("%Amount").text = str(t3_pool.size())
	
	card.get_node("%Button").pressed.connect(_on_select_card.bind(card))
	card.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	card.update()

var gold : int = 5
var fire_taking : int = 0
var fire_gems : int = 4
var water_taking : int = 0
var water_gems : int = 4
var grass_taking : int = 0
var grass_gems : int = 4
var electric_taking : int = 0
var electric_gems : int = 4
var psychic_taking : int = 0
var psychic_gems : int = 4

var spread_take : bool = false
var takes : Array[String] = []
var gems_taken : int = 0
var bad_dip : bool = false
const MAX_GEMS_PER_PLAYER : int = 10
func _on_add_gem(type: String) -> void:
	if gems_taken + current_player.get_gem_total() >= MAX_GEMS_PER_PLAYER:
		return
	
	if gems_taken >= 3:
		return
	
	match type:
		"Fire":
			bad_dip = fire_taking >= 1 and fire_gems <= 2 and takes.count(type) == 1
		"Water":
			bad_dip = water_taking >= 1 and water_gems <= 2 and takes.count(type) == 1
		"Grass":
			bad_dip = grass_taking >= 1 and grass_gems <= 2 and takes.count(type) == 1
		"Electric":
			bad_dip = electric_taking >= 1 and electric_gems <= 2 and takes.count(type) == 1
		"Psychic":
			bad_dip = psychic_taking >= 1 and psychic_gems <= 2 and takes.count(type) == 1
	
	spread_take = not takes.any(func(take: String):
		return takes.count(take) > 1)
	
	if not spread_take or bad_dip:
		return
	
	if gems_taken == 2 and takes.any(func(take: String):
		return takes.count(take) > 1):
		return
	
	if not spread_take and gems_taken == 2:
		return
	elif spread_take and gems_taken == 2:
		if takes.count(type) > 0:
			return
	
	match type:
		"Fire":
			if fire_gems <= 0:
				return
			
			takes.append("Fire")
			fire_taking += 1
			fire_gems -= 1
			%Gem_Fire.get_node("%Amount").text = str(fire_gems)
			%Gem_Fire.get_node("%Taking").text = "+" + str(fire_taking)
			%Gem_Fire.get_node("%Taking").visible = fire_taking > 0
		"Water":
			if water_gems <= 0:
				return
			
			takes.append("Water")
			water_taking += 1
			water_gems -= 1
			%Gem_Water.get_node("%Amount").text = str(water_gems)
			%Gem_Water.get_node("%Taking").text = "+" + str(water_taking)
			%Gem_Water.get_node("%Taking").visible = water_taking > 0
		"Grass":
			if grass_gems <= 0:
				return
			
			takes.append("Grass")
			grass_taking += 1
			grass_gems -= 1
			%Gem_Grass.get_node("%Amount").text = str(grass_gems)
			%Gem_Grass.get_node("%Taking").text = "+" + str(grass_taking)
			%Gem_Grass.get_node("%Taking").visible = grass_taking > 0
		"Electric":
			if electric_gems <= 0:
				return
			
			takes.append("Electric")
			electric_taking += 1
			electric_gems -= 1
			%Gem_Electric.get_node("%Amount").text = str(electric_gems)
			%Gem_Electric.get_node("%Taking").text = "+" + str(electric_taking)
			%Gem_Electric.get_node("%Taking").visible = electric_taking > 0
		"Psychic":
			if psychic_gems <= 0:
				return
			
			takes.append("Psychic")
			psychic_taking += 1
			psychic_gems -= 1
			%Gem_Psychic.get_node("%Amount").text = str(psychic_gems)
			%Gem_Psychic.get_node("%Taking").text = "+" + str(psychic_taking)
			%Gem_Psychic.get_node("%Taking").visible = psychic_taking > 0
	
	gems_taken += 1

func _on_putback_gem(type: String) -> void:
	match type:
		"Fire":
			if fire_taking <= 0:
				return
			
			takes.erase("Fire")
			
			fire_taking -= 1
			fire_gems += 1
			%Gem_Fire.get_node("%Amount").text = str(fire_gems)
			%Gem_Fire.get_node("%Taking").text = "+" + str(fire_taking)
			%Gem_Fire.get_node("%Taking").visible = fire_taking > 0
		"Water":
			if water_taking <= 0:
				return
			
			takes.erase("Water")
			
			water_taking -= 1
			water_gems += 1
			%Gem_Water.get_node("%Amount").text = str(water_gems)
			%Gem_Water.get_node("%Taking").text = "+" + str(water_taking)
			%Gem_Water.get_node("%Taking").visible = water_taking > 0
		"Grass":
			if grass_taking <= 0:
				return
			
			takes.erase("Grass")
			
			grass_taking -= 1
			grass_gems += 1
			%Gem_Grass.get_node("%Amount").text = str(grass_gems)
			%Gem_Grass.get_node("%Taking").text = "+" + str(grass_taking)
			%Gem_Grass.get_node("%Taking").visible = grass_taking > 0
		"Electric":
			if electric_taking <= 0:
				return
			
			takes.erase("Electric")
			
			electric_taking -= 1
			electric_gems += 1
			%Gem_Electric.get_node("%Amount").text = str(electric_gems)
			%Gem_Electric.get_node("%Taking").text = "+" + str(electric_taking)
			%Gem_Electric.get_node("%Taking").visible = electric_taking > 0
		"Psychic":
			if psychic_taking <= 0:
				return
			
			takes.erase("Psychic")
			
			psychic_taking -= 1
			psychic_gems += 1
			%Gem_Psychic.get_node("%Amount").text = str(psychic_gems)
			%Gem_Psychic.get_node("%Taking").text = "+" + str(psychic_taking)
			%Gem_Psychic.get_node("%Taking").visible = psychic_taking > 0
	
	gems_taken -= 1

var selected_card : Card = null
var held_card : bool = false
const PLAYER_MAX_DECK_SIZE : int = 3
func _on_select_card(card: Card, held: bool = false) -> void:
	if card == null:
		return
	
	if selected_card != null and selected_card == card:
		_on_deselect()
		return
	
	if selected_card != null:
		selected_card.get_node("%Button").set_pressed_no_signal(false)
	if selected_noble != null:
		selected_noble.get_node("%Button").set_pressed_no_signal(false)
	
	held_card = held
	%Buy_Control.visible = true
	%Buy_Control.global_position = card.get_node("%Scaler").global_position
	selected_card = card
	
	var data : CardData = selected_card.data
	%Buy.disabled = not data.can_afford(current_player)
	%Hold.disabled = current_player.deck.size() >= PLAYER_MAX_DECK_SIZE \
		or gold <= 0 \
		or held \
		or current_player.get_gem_total() >= MAX_GEMS_PER_PLAYER

var selected_noble : Noble = null
func _on_select_noble(noble: Noble) -> void:
	if noble == null:
		return
	
	if selected_noble != null and selected_noble == noble:
		_on_deselect()
		return
	
	if selected_card != null:
		selected_card.get_node("%Button").set_pressed_no_signal(false)
	if selected_noble != null:
		selected_noble.get_node("%Button").set_pressed_no_signal(false)
	
	%Buy_Control.visible = true
	%Buy_Control.global_position = noble.get_node("%Scaler").global_position
	selected_noble = noble
	
	var data : NobleData = selected_noble.data
	%Buy.disabled = not data.can_afford(current_player)
	%Hold.disabled = true

func _on_buy() -> void:
	if not selected_card:
		return
	
	var data : CardData = selected_card.data
	if not data.can_afford(current_player):
		return
	
	buy_card(current_player, selected_card)

func _on_sell() -> void:
	if not selected_card:
		return
	
	var data : NobleData = selected_noble.data
	if not data.can_afford(current_player):
		return
	
	buy_noble(current_player, selected_noble)

func _on_hold() -> void:
	if not selected_card and not selected_deck:
		return
	
	if gold <= 0:
		return
	
	if selected_card != null:
		var data : CardData = selected_card.data
		
		var visual : GamePlayer = player_to_visual[current_player] as GamePlayer
		var success : bool = visual.hold_card(selected_card)
		
		if not success:
			return
		
		var index : int = get_child_index(selected_card)
		erase_from_pool(selected_card)
		
		selected_card.queue_free()
		add_new_card(data.card_tier, index)
		update()
		
		_on_deselect()
		_on_end_turn()
	elif selected_deck != null and selected_tier != -1:
		var pool : Array[CardData] = []
		match selected_tier:
			1:
				pool = t1_pool
			2:
				pool = t2_pool
			3:
				pool = t3_pool
		
		if pool.is_empty():
			return
		
		if current_player.deck.size() >= PLAYER_MAX_DECK_SIZE:
			return
		
		var card : CardData = pool.pop_front()
		var visual : GamePlayer = player_to_visual[current_player] as GamePlayer
		visual.hold_card_from_deck(card)
		
		update()
		
		_on_deselect()
		_on_end_turn()
		return

var selected_deck : Control = null
var selected_tier : int = -1
func _on_select_deck(deck: Control) -> void:
	selected_card = null
	
	if selected_deck != null and deck == selected_deck:
		_on_deselect()
		return
	
	selected_deck = deck
	
	%Buy_Control.global_position = deck.get_node("%Scaler").global_position
	
	%Buy.disabled = true
	%Hold.disabled = current_player.deck.size() >= PLAYER_MAX_DECK_SIZE \
		or gold <= 0 \
		or current_player.get_gem_total() >= MAX_GEMS_PER_PLAYER
	
	if deck == %T1:
		selected_tier = 1
	if deck == %T2:
		selected_tier = 2
	if deck == %T3:
		selected_tier = 3

func _on_deselect() -> void:
	if selected_card != null:
		selected_card.get_node("%Button").set_pressed_no_signal(false)
	if selected_deck != null:
		selected_deck.get_node("%Button").set_pressed_no_signal(false)
	
	%Buy_Control.visible = false
	selected_tier = -1
	selected_card = null

func _on_end_turn() -> void:
	%Gem_Fire.get_node("%Taking").visible = false
	%Gem_Water.get_node("%Taking").visible = false
	%Gem_Grass.get_node("%Taking").visible = false
	%Gem_Electric.get_node("%Taking").visible = false
	%Gem_Psychic.get_node("%Taking").visible = false
	
	var visual : GamePlayer = player_to_visual[current_player] as GamePlayer
	if fire_taking > 0:
		current_player.fire_gems += fire_taking
	if water_taking > 0:
		current_player.water_gems += water_taking
	if grass_taking > 0:
		current_player.grass_gems += grass_taking
	if electric_taking > 0:
		current_player.electric_gems += electric_taking
	if psychic_taking > 0:
		current_player.psychic_gems += psychic_taking
	
	fire_taking = 0
	water_taking = 0
	grass_taking = 0
	electric_taking = 0
	psychic_taking = 0
	
	spread_take = false
	bad_dip = false
	takes.clear()
	gems_taken = 0
	
	visual.update.emit()
	
	for p : GamePlayer in player_to_visual.values():
		p.toggle_deck(false)
	
	_next_player()

func update() -> void:
	%Gem_Gold.get_node("%Amount").text = str(gold)
	%Gem_Fire.get_node("%Amount").text = str(fire_gems)
	%Gem_Water.get_node("%Amount").text = str(water_gems)
	%Gem_Grass.get_node("%Amount").text = str(grass_gems)
	%Gem_Electric.get_node("%Amount").text = str(electric_gems)
	%Gem_Psychic.get_node("%Amount").text = str(psychic_gems)
	
	%T1.get_node("%Amount").text = str(t1_pool.size())
	%T2.get_node("%Amount").text = str(t2_pool.size())
	%T3.get_node("%Amount").text = str(t3_pool.size())
