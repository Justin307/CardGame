extends Area2D

# Territory ID
@export var territory_id: int = 0
# Territory owner
var owner_id: int = -1
# Card count
var cards: int = 0
# Player colors
var player_colors = {
	0: Color(1, 0, 0),   # Červená
	1: Color(0, 0, 1),   # Modrá
	2: Color(0, 1, 0),   # Zelená
	3: Color(1, 1, 0)    # Žlutá
}

# Signal when territory is selected/clicked
signal territory_selected(territory_id: int)

# Set owner of territory
func set_territory_owner(player_id: int) -> void:
	owner_id = player_id
	if player_colors.has(player_id):
		$Polygon2D.color = player_colors[player_id]
	else:
		$Polygon2D.color = Color(1, 1, 1) # VWhite

# Set card count
func set_card_count(count: int) -> void:
	cards = count
	$Label.text = str(cards)

# Get owner of territory
func get_territory_owner() -> int:
	return owner_id
	
# Get card count
func get_card_count() -> int:
	return cards

func _ready() -> void:
	# Connect to input_event signal of Area2D
	connect("input_event", Callable(self, "_on_input_event"))

# When mouse clicked
func _on_input_event(_viewport, event, _shape_idx) -> void:
	if event is InputEventMouseButton and event.pressed:
		print("Clicked on territory ID:", territory_id, " | player:", owner_id, " | cards:", cards)
		# Emit signal for other parts of the game
		territory_selected.emit(territory_id)
