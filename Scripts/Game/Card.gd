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
	
	if data.card_fire_cost > 0:
		var cost : Control = AssetLoader.GEM_COST["Fire"].instantiate() as Control
		%Costs.add_child(cost)
		
		cost.get_node("%Cost").text = str(data.card_fire_cost)
	
	if data.card_water_cost > 0:
		var cost : Control = AssetLoader.GEM_COST["Water"].instantiate() as Control
		%Costs.add_child(cost)
		
		cost.get_node("%Cost").text = str(data.card_water_cost)
	
	if data.card_grass_cost > 0:
		var cost : Control = AssetLoader.GEM_COST["Grass"].instantiate() as Control
		%Costs.add_child(cost)
		
		cost.get_node("%Cost").text = str(data.card_grass_cost)
	
	if data.card_electric_cost > 0:
		var cost : Control = AssetLoader.GEM_COST["Electric"].instantiate() as Control
		%Costs.add_child(cost)
		
		cost.get_node("%Cost").text = str(data.card_electric_cost)
	
	if data.card_psychic_cost > 0:
		var cost : Control = AssetLoader.GEM_COST["Psychic"].instantiate() as Control
		%Costs.add_child(cost)
		
		cost.get_node("%Cost").text = str(data.card_psychic_cost)
