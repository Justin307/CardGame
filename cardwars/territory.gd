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

# Signal when terriroty is selected/clicked
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
	# Připojení k input_event signálu Area2D
	connect("input_event", Callable(self, "_on_input_event"))

# When mouse clicked
func _on_input_event(_viewport, event, _shape_idx) -> void:
	if event is InputEventMouseButton and event.pressed:
		print("Kliknuto na území ID:", territory_id, " | hráč:", owner_id, " | karty:", cards)
		# Emituje signál pro ostatní části hry
		territory_selected.emit(territory_id)
