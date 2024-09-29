class_name Noble
extends Control

var data : NobleData = null

func setup(_data: NobleData) -> void:
	data = _data

func update() -> void:
	Utils.free_children(%Costs, true)
	%Points.text = str(data.noble_points)
	%Points.visible = data.noble_points > 0
	
	if data.noble_fire_cost > 0:
		var cost : Control = AssetLoader.GEM_STASH["Fire"].instantiate() as Control
		%Costs.add_child(cost)
		
		cost.get_node("%Amount").text = str(data.noble_fire_cost)
	
	if data.noble_water_cost > 0:
		var cost : Control = AssetLoader.GEM_STASH["Water"].instantiate() as Control
		%Costs.add_child(cost)
		
		cost.get_node("%Amount").text = str(data.noble_water_cost)
	
	if data.noble_grass_cost > 0:
		var cost : Control = AssetLoader.GEM_STASH["Grass"].instantiate() as Control
		%Costs.add_child(cost)
		
		cost.get_node("%Amount").text = str(data.noble_grass_cost)
	
	if data.noble_electric_cost > 0:
		var cost : Control = AssetLoader.GEM_STASH["Electric"].instantiate() as Control
		%Costs.add_child(cost)
		
		cost.get_node("%Amount").text = str(data.noble_electric_cost)
	
	if data.noble_psychic_cost > 0:
		var cost : Control = AssetLoader.GEM_STASH["Psychic"].instantiate() as Control
		%Costs.add_child(cost)
		
		cost.get_node("%Amount").text = str(data.noble_psychic_cost)
