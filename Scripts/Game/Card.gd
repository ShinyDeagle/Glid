class_name Card
extends Control

var data : CardData = null

func setup(_data: CardData) -> void:
	data = _data

func update() -> void:
	%Points.text = str(data.card_points)
	%Points.visible = data.card_points > 0
	
	var coin : Texture2D = AssetLoader.GEM_COIN[data.card_type]
	%Type.texture = coin
	
	Utils.free_children(%Costs, true)
	
	var modulate_color : Color = AssetLoader.CARD_MODULATE_COLOR[data.card_type]
	%Border.self_modulate = modulate_color
	%Foreground.self_modulate = modulate_color
	%Highlight.self_modulate = modulate_color
	
	var cost_data : Dictionary = data.get_cost_data()
	for type in cost_data:
		var amount : int = cost_data[type] as int
		
		if amount > 0:
			var cost : Control = AssetLoader.GEM_COST[type].instantiate() as Control
			%Costs.add_child(cost)
			
			cost.get_node("%Cost").text = str(amount)
	
	refresh_modulation()

func refresh_modulation() -> void:
	var player : Player = Session.inst().current_player
	var full_bank : GemBank = GemBank.new()
	
	player.bank.add_to(full_bank)
	player.card_bank.add_to(full_bank)
	
	modulate = Color.WHITE.darkened(0.35) \
		if not full_bank.can_afford(data.get_cost_data()) else \
		Color.WHITE
