extends Area2D

# Territory ID
@export var territory_id: int = 0
# Territory owner
var owner_id: int = -1
# Card count
var cards: int = 0
# Active
var active: bool = false

## Signal when territory is selected/clicked
##
## This signal is emitted when the territory is clicked
## It carries the territory ID to allow other parts of the game to respond
signal territory_selected(territory_id: int)

## Draw function to set label color
func _draw() -> void:
	$Label.add_theme_color_override("font_color", Color(0,0,0))

## Called when the node is ready
func _ready() -> void:
	# Add this territory to the territories group
	add_to_group("territories")
	# Connect to input_event signal of Area2D
	connect("input_event", Callable(self, "_on_input_event"))
	connect("draw", Callable(self, "_draw"))

## Called when the territory is clicked
##
## This function is called when the mouse button is pressed on the territory
func _on_input_event(_viewport, event, _shape_idx) -> void:
	if event is InputEventMouseButton and event.pressed:
		# Emit signal for other parts of the game
		territory_selected.emit(territory_id)

## Set territory owner
func set_territory_owner(player_id: int) -> void:
	owner_id = player_id
	update_color()

## Set card count
func set_card_count(count: int) -> void:
	cards = count
	$Label.text = str(cards)
	
## Set active state
func set_active(state: bool) -> void:
	active = state
	update_color()

## Get territory owner
func get_territory_owner() -> int:
	return owner_id
	
## Ger card count
func get_card_count() -> int:
	return cards

## Update color based on owner and active state
##
## This function updates the color of the territory based on the owner ID and active state
## If the owner ID is in the Global.player_colors dictionary, it uses the corresponding color
## If the owner ID is not found, it defaults to white
## If the territory is active, it uses the second color; otherwise, it uses the first
## color from the Global.player_colors dictionary
func update_color() -> void:
	if Global.player_colors.has(owner_id):
		if active:
			$Polygon2D.color = Global.player_colors[owner_id][1]
		else:
			$Polygon2D.color = Global.player_colors[owner_id][0]
	else:
		$Polygon2D.color = Color(1, 1, 1) # White
