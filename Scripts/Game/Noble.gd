class_name Noble
extends Control

var data : NobleData = null

func setup(_data: NobleData) -> void:
	data = _data

func update() -> void:
	Utils.free_children(%Costs, true)
	%Points.text = str(data.noble_points)
	%Points.visible = data.noble_points > 0
	
	var cost_data : Dictionary = data.get_cost_data()
	for type in cost_data:
		var amount : int = cost_data[type] as int
		
		if amount > 0:
			var cost : Control = AssetLoader.GEM_STASH[type].instantiate() as Control
			%Costs.add_child(cost)
			
			cost.get_node("%Amount").text = str(amount)
	
	refresh_modulation()

func refresh_modulation() -> void:
	modulate = Color.WHITE.darkened(0.35) \
		if not Session.inst().current_player.card_bank.can_afford(data.get_cost_data()) else \
		Color.WHITE
