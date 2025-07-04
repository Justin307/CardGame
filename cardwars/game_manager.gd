extends Node

# Source of the attack / Current player territory
var source_territory_id := -1
# Target of the attack / Other player territory
var target_territory_id := -1
# List of territories
var territories := {}

# When ready
func _ready() -> void:
	# Register territories into list
	var map = get_parent().get_node("Map")
	for child in map.get_children():
		# Check if the child is territory
		if child.scene_file_path == "res://territory.tscn":
			territories[child.territory_id] = child

# When terriroty is selected/clicked
func on_territory_selected(territory_id):
	if source_territory_id == -1:
		if territories[territory_id].get_card_count() <= 1:
			print("Can't attack from territory  ", territory_id, ", not enought cards.")
		else:
			source_territory_id = territory_id
			print("Source territory id set to ", territory_id, " (Owner: ", territories[source_territory_id].get_territory_owner(), ")")
	elif source_territory_id == territory_id:
		source_territory_id = -1
	elif target_territory_id == -1:
		print("Checking target territory ", territory_id, " (Owner: ", territories[territory_id].get_territory_owner(), ")")
		# Check if the taret territory is from different player
		var source_owner = territories[source_territory_id].get_territory_owner()
		var target_owner = territories[territory_id].get_territory_owner()
		if source_owner == target_owner:
			print("CHYBA: Nelze útočit na vlastní území! Source owner: ", source_owner, ", Target owner: ", target_owner)
		elif source_owner == -1 or target_owner == -1:
			print("CHYBA: Jedno z území nemá vlastníka!")
		else:
			target_territory_id = territory_id
			print("ÚSPĚCH: Útok ze území hráče ", source_owner, " na území hráče ", target_owner)
			print("Target territory id set to ", territory_id)
			fight()
			reset_selection()
	print("Current source - ", source_territory_id)
	print("Current terget - ", target_territory_id)

# Reset saved territory ids
func reset_selection():
	source_territory_id = -1
	target_territory_id = -1

# Attack/fight logic
func fight():
	var source_territory_card_count = territories[source_territory_id].get_card_count()
	var target_territory_card_count = territories[target_territory_id].get_card_count()
	print("Source card count: ", source_territory_card_count)
	print("Target card count: ", target_territory_card_count)
	
	# Generate cards for attacker (source)
	var source_cards = []
	for i in range(source_territory_card_count):
		source_cards.append(generate_card())
	
	# Generate cards for defender (target)
	var target_cards = []
	for i in range(target_territory_card_count):
		target_cards.append(generate_card())
	
	# Calculate card values
	var source_total_value = 0
	for card in source_cards:
		source_total_value += card.value
	
	var target_total_value = 0
	for card in target_cards:
		target_total_value += card.value
	
	# Print cards and values
	print("Útočník (hráč ", territories[source_territory_id].get_territory_owner(), ") karty:")
	for card in source_cards:
		print("  ", card.value, card.suit)
	print("  Celková hodnota: ", source_total_value)
	
	print("Obránce (hráč ", territories[target_territory_id].get_territory_owner(), ") karty:")
	for card in target_cards:
		print("  ", card.value, card.suit)
	print("  Celková hodnota: ", target_total_value)
	
	if source_total_value == target_total_value:
		territories[source_territory_id].set_card_count(1)
	elif source_total_value > target_total_value:
		territories[target_territory_id].set_card_count(territories[source_territory_id].get_card_count() - 1)
		territories[target_territory_id].set_territory_owner(territories[source_territory_id].get_territory_owner())
		territories[source_territory_id].set_card_count(1)
	else:
		territories[source_territory_id].set_card_count(1)

func generate_card():
	# Card values: 2-10, J=11, Q=12, K=13, A=14
	var card_values = [2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14]
	# Card suits: ♥ ♦ ♣ ♠
	var card_suits = ["♥", "♦", "♣", "♠"]
	
	# Generate random value and suit
	var random_value = card_values[randi() % card_values.size()]
	var random_suit = card_suits[randi() % card_suits.size()]
	
	# Return as dictionary
	return {
		"value": random_value,
		"suit": random_suit
	}
	
