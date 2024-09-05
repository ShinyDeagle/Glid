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
	
	for arrow : TextureRect in %Arrows.get_children().duplicate():
		var show_arrow : bool = int(arrow.name) - 1 == current_index
		arrow.visibility_layer = 0 if not show_arrow else 1

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
func setup() -> void:
	Utils.free_children(%Nobles, true)
	Utils.free_children(%Tier_1, true)
	Utils.free_children(%Tier_2, true)
	Utils.free_children(%Tier_3, true)
	
	players.clear()
	
	players.append(Player.new())
	players.append(Player.new())
	
	Utils.free_children(%Players, true)
	for p : Player in players:
		var visual : GamePlayer = AssetLoader.PLAYER.instantiate() as GamePlayer
		var arrow : TextureRect = AssetLoader.PLAYER_ARROW.instantiate() as TextureRect
		
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
		add_new_card(1)
		add_new_card(2)
		add_new_card(3)
	
	_next_player()

static var t1_pool : Array[CardData] = []
static var t2_pool : Array[CardData] = []
static var t3_pool : Array[CardData] = []

func buy_card(who: Player, what: Card) -> void:
	var visual : GamePlayer = player_to_visual[who] as GamePlayer
	var success : bool = visual.buy_card(what)
	
	if not success:
		return
	
	var data : CardData = what.data
	if data.card_tier == 1:
		t1_pool.erase(data)
	elif data.card_tier == 2:
		t2_pool.erase(data)
	elif data.card_tier == 3:
		t3_pool.erase(data)
	
	what.queue_free()
	add_new_card(data.card_tier)

func add_new_card(tier: int) -> void:
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
		%T1.get_node("%Amount").text = str(t1_pool.size())
	elif tier == 2:
		%Tier_2.add_child(card)
		%T2.get_node("%Amount").text = str(t2_pool.size())
	elif tier == 3:
		%Tier_3.add_child(card)
		%T3.get_node("%Amount").text = str(t3_pool.size())
	
	card.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	card.update()

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
var first_take : String = ""
var second_take : String = ""
var gems_taken : int = 0
const MAX_GEMS_PER_PLAYER : int = 10
func _on_add_gem(type: String) -> void:
	if gems_taken >= 3:
		return
	
	if gems_taken == 1:
		spread_take = not type == first_take
	
	if not spread_take and gems_taken == 2:
		return
	elif spread_take and gems_taken == 2:
		if type == first_take or type == second_take:
			return
	
	match type:
		"Fire":
			if fire_gems <= 0:
				return
			
			fire_taking += 1
			fire_gems -= 1
			%Gem_Fire.get_node("%Amount").text = str(fire_gems)
			%Gem_Fire.get_node("%Taking").text = "+" + str(fire_taking)
			%Gem_Fire.get_node("%Taking").visible = fire_taking > 0
		"Water":
			if water_gems <= 0:
				return
			
			water_taking += 1
			water_gems -= 1
			%Gem_Water.get_node("%Amount").text = str(water_gems)
			%Gem_Water.get_node("%Taking").text = "+" + str(water_taking)
			%Gem_Water.get_node("%Taking").visible = water_taking > 0
		"Grass":
			if grass_gems <= 0:
				return
			
			grass_taking += 1
			grass_gems -= 1
			%Gem_Grass.get_node("%Amount").text = str(grass_gems)
			%Gem_Grass.get_node("%Taking").text = "+" + str(grass_taking)
			%Gem_Grass.get_node("%Taking").visible = grass_taking > 0
		"Electric":
			if electric_gems <= 0:
				return
			
			electric_taking += 1
			electric_gems -= 1
			%Gem_Electric.get_node("%Amount").text = str(electric_gems)
			%Gem_Electric.get_node("%Taking").text = "+" + str(electric_taking)
			%Gem_Electric.get_node("%Taking").visible = electric_taking > 0
		"Psychic":
			if psychic_gems <= 0:
				return
			
			psychic_taking += 1
			psychic_gems -= 1
			%Gem_Psychic.get_node("%Amount").text = str(psychic_gems)
			%Gem_Psychic.get_node("%Taking").text = "+" + str(psychic_taking)
			%Gem_Psychic.get_node("%Taking").visible = psychic_taking > 0
	
	if gems_taken == 0:
		first_take = type
	if gems_taken == 1:
		second_take = type
	
	gems_taken += 1

func _on_putback_gem(type: String) -> void:
	match type:
		"Fire":
			if fire_taking <= 0:
				return
			
			fire_taking -= 1
			fire_gems += 1
			%Gem_Fire.get_node("%Amount").text = str(fire_gems)
			%Gem_Fire.get_node("%Taking").text = "+" + str(fire_taking)
			%Gem_Fire.get_node("%Taking").visible = fire_taking > 0
		"Water":
			if water_taking <= 0:
				return
			
			water_taking -= 1
			water_gems += 1
			%Gem_Water.get_node("%Amount").text = str(water_gems)
			%Gem_Water.get_node("%Taking").text = "+" + str(water_taking)
			%Gem_Water.get_node("%Taking").visible = water_taking > 0
		"Grass":
			if grass_taking <= 0:
				return
			
			grass_taking -= 1
			grass_gems += 1
			%Gem_Grass.get_node("%Amount").text = str(grass_gems)
			%Gem_Grass.get_node("%Taking").text = "+" + str(grass_taking)
			%Gem_Grass.get_node("%Taking").visible = grass_taking > 0
		"Electric":
			if electric_taking <= 0:
				return
			
			electric_taking -= 1
			electric_gems += 1
			%Gem_Electric.get_node("%Amount").text = str(electric_gems)
			%Gem_Electric.get_node("%Taking").text = "+" + str(electric_taking)
			%Gem_Electric.get_node("%Taking").visible = electric_taking > 0
		"Psychic":
			if psychic_taking <= 0:
				return
			
			psychic_taking -= 1
			psychic_gems += 1
			%Gem_Psychic.get_node("%Amount").text = str(psychic_gems)
			%Gem_Psychic.get_node("%Taking").text = "+" + str(psychic_taking)
			%Gem_Psychic.get_node("%Taking").visible = psychic_taking > 0
	
	gems_taken -= 1
	if gems_taken == 1:
		second_take = ""
	if gems_taken == 0:
		first_take = ""

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
	
	first_take = ""
	second_take = ""
	spread_take = false
	gems_taken = 0
	
	visual.update.emit()
	_next_player()
