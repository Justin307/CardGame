extends Area2D

# Territory ID
@export var territory_id: int = 0
# Territory owner
var owner_id: int = -1
# Card count
var cards: int = 0
# Active
var active: bool = false

var neighbors = []

# Signal when territory is selected/clicked
signal territory_selected(territory_id: int)

# Set owner of territory
func set_territory_owner(player_id: int) -> void:
	owner_id = player_id
	update_color()

# Set card count
func set_card_count(count: int) -> void:
	cards = count
	$Label.text = str(cards)
	
# Set active
func set_active(state: bool) -> void:
	active = state
	update_color()
	
func add_neighbor(neighbor_id: int):
	neighbors.append(neighbor_id)

# Get owner of territory
func get_territory_owner() -> int:
	return owner_id
	
# Get card count
func get_card_count() -> int:
	return cards
	
func get_neighbors() -> Array:
	return neighbors
	
func update_color() -> void:
	if Global.player_colors.has(owner_id):
		if active:
			$Polygon2D.color = Global.player_colors[owner_id][1]
		else:
			$Polygon2D.color = Global.player_colors[owner_id][0]
	else:
		$Polygon2D.color = Color(1, 1, 1) # White

func _draw() -> void:
	$Label.add_theme_color_override("font_color", Color(0,0,0))

func _ready() -> void:
	# Add this territory to the territories group
	add_to_group("territories")
	# Connect to input_event signal of Area2D
	connect("input_event", Callable(self, "_on_input_event"))
	connect("draw", Callable(self, "_draw"))

# When mouse clicked
func _on_input_event(_viewport, event, _shape_idx) -> void:
	if event is InputEventMouseButton and event.pressed:
		print("Clicked on territory ID:", territory_id, " | player:", owner_id, " | cards:", cards)
		# Emit signal for other parts of the game
		territory_selected.emit(territory_id)
