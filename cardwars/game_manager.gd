extends Node

var source_territory_id := -1
var target_territory_id := -1

func _on_territory_selected(territory_id):
	if source_territory_id == -1:
		source_territory_id = territory_id
		print("Source territory id set to ", territory_id)
	elif target_territory_id == -1:
		target_territory_id = territory_id
		print("Target territory id set to ", territory_id)
		_reset_selection()

func _reset_selection():
	source_territory_id = -1
	target_territory_id = -1
