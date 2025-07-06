extends Node

# Source of the attack / Current player territory
var source_territory_id := -1
# Target of the attack / Other player territory
var target_territory_id := -1
# List of territories
var territories := {}
# Current player (1 or 2)
var current_player := 1
# Territory adjacency map - defines which territories are neighbors
var territory_neighbors := {
	1: [2, 3],
	2: [1, 5],
	3: [1, 4],
	4: [3, 5],
	5: [2, 4]
}
# Reference to UI elements
var current_player_label
var win_dialog
var win_label
var reset_confirm_dialog
var battle_result_attacker_label
var battle_result_defender_label
var battle_result_outcome_label

# When ready
func _ready() -> void:
	# Register territories into list
	var map = get_parent().get_node("Map")
	for child in map.get_children():
		# Check if the child is in the "territories" group
		if child.is_in_group("territories"):
			territories[child.territory_id] = child
			# Auto-connect the territory_selected signal
			child.territory_selected.connect(_on_territory_selected)
	
	# Get reference to UI elements
	current_player_label = get_parent().get_node("UI/BottomPanel/VBoxContainer/CurrentPlayerLabel")
	win_dialog = get_parent().get_node("UI/WinDialog")
	win_label = get_parent().get_node("UI/WinDialog/WinLabel")
	reset_confirm_dialog = get_parent().get_node("UI/ResetConfirmDialog")
	battle_result_attacker_label = get_parent().get_node("UI/BattleResultPanel/VBoxContainer/AttackerLabel")
	battle_result_defender_label = get_parent().get_node("UI/BattleResultPanel/VBoxContainer/DefenderLabel")
	battle_result_outcome_label = get_parent().get_node("UI/BattleResultPanel/VBoxContainer/ResultLabel")
	update_ui()

# Handle input events (like Escape key)
func _input(event):
	if event is InputEventKey and event.pressed:
		if event.keycode == KEY_ESCAPE:
			print("Escape pressed - closing application")
			get_tree().quit()

# When territory is selected/clicked
func _on_territory_selected(territory_id):
	# Get clicked territory owner
	var territory_owner = territories[territory_id].get_territory_owner()

	if territory_owner == current_player:
		clicked_own_territory(territory_id)
	else:
		clicked_other_territory(territory_id)

# When own territory is clicked
func clicked_own_territory(territory_id):
	# Deselect source territory if clicked again
	if source_territory_id == territory_id:
		source_territory_id = -1
		print("Source territory deselected")
	elif territories[territory_id].get_card_count() <= 1:
		print("Cannot select territory with one or less cards!")
		return
	else:
		source_territory_id = territory_id
		print("Clicked own territory ", territory_id, " (Owner: ", territories[territory_id].get_territory_owner(), ")")

# When other player's territory is clicked
func clicked_other_territory(territory_id):
	if source_territory_id == -1:
		print("ERROR: No source territory selected! Cannot attack.")
		return
	
	# Check if territories are neighbors
	if not are_territories_neighbors(source_territory_id, territory_id):
		print("ERROR: Can only attack neighboring territories! Territory ", source_territory_id, " is not adjacent to ", territory_id)
		return
	
	target_territory_id = territory_id
	print("Attacking territory ", territory_id, " (Owner: ", territories[territory_id].get_territory_owner(), ")")
	fight()

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
	print("Attacker (player ", territories[source_territory_id].get_territory_owner(), ") cards:")
	for card in source_cards:
		print("  ", card.display_value, card.suit)
	print("  Total value: ", source_total_value)
	
	print("Defender (player ", territories[target_territory_id].get_territory_owner(), ") cards:")
	for card in target_cards:
		print("  ", card.display_value, card.suit)
	print("  Total value: ", target_total_value)
	
	# Determine winner based on game rules
	var attacker_wins = false
	var result_text = ""
	
	if source_total_value > target_total_value:
		attacker_wins = true
		result_text = "Attacker wins with higher total value!"
		print("RESULT: Attacker wins with higher total value!")
	elif source_total_value < target_total_value:
		attacker_wins = false
		result_text = "Defender wins with higher total value!"
		print("RESULT: Defender wins with higher total value!")
	else:
		# Tie - check for same suit bonus (all cards same color)
		var source_all_same_suit = check_all_same_suit(source_cards)
		var target_all_same_suit = check_all_same_suit(target_cards)
		
		if source_all_same_suit and not target_all_same_suit:
			attacker_wins = true
			result_text = "Tie broken - Attacker wins with all same suit!"
			print("RESULT: Tie broken - Attacker wins with all same suit!")
		elif target_all_same_suit and not source_all_same_suit:
			attacker_wins = false
			result_text = "Tie broken - Defender wins with all same suit!"
			print("RESULT: Tie broken - Defender wins with all same suit!")
		else:
			attacker_wins = false
			result_text = "Tie - Defender wins by default!"
			print("RESULT: Tie - Defender wins by default!")
	
	# Apply battle results
	if attacker_wins:
		# Attacker wins - takes over the territory
		territories[target_territory_id].set_card_count(territories[source_territory_id].get_card_count() - 1)
		territories[target_territory_id].set_territory_owner(territories[source_territory_id].get_territory_owner())
		territories[source_territory_id].set_card_count(1)
		print("Territory ", target_territory_id, " conquered!")
	else:
		# Defender wins - attacker loses cards
		territories[source_territory_id].set_card_count(1)
		print("Attack failed - attacker loses cards!")

	# Update battle result panel
	update_battle_result_panel(source_cards, target_cards, source_total_value, target_total_value, result_text)
	check_win_condition()
	reset_selection()

# Check if all cards have the same suit
func check_all_same_suit(cards: Array) -> bool:
	if cards.size() <= 1:
		return true
	
	var first_suit = cards[0].suit
	for card in cards:
		if card.suit != first_suit:
			return false
	return true

# Check if two territories are neighbors
func are_territories_neighbors(source_id: int, target_id: int) -> bool:
	if territory_neighbors.has(source_id):
		return target_id in territory_neighbors[source_id]
	return false

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
		"suit": random_suit,
		"display_value": get_card_display_value(random_value)
	}

# Convert numeric card value to display string
func get_card_display_value(value: int) -> String:
	match value:
		11:
			return "J"
		12:
			return "Q"
		13:
			return "K"
		14:
			return "A"
		_:
			return str(value)

# Update UI elements
func update_ui():
	if current_player_label:
		current_player_label.text = "Current Player: " + str(current_player)

# Update battle result panel with cards and results
func update_battle_result_panel(attacker_cards: Array, defender_cards: Array, attacker_total: int, defender_total: int, result_text: String):
	# Update attacker info
	var attacker_player = territories[source_territory_id].get_territory_owner()
	var attacker_cards_text = ""
	for card in attacker_cards:
		attacker_cards_text += card.display_value + card.suit + " "
	battle_result_attacker_label.text = "Attacker (Player " + str(attacker_player) + "): " + attacker_cards_text.strip_edges() + " (Total: " + str(attacker_total) + ")"
	
	# Update defender info
	var defender_player = territories[target_territory_id].get_territory_owner()
	var defender_cards_text = ""
	for card in defender_cards:
		defender_cards_text += card.display_value + card.suit + " "
	battle_result_defender_label.text = "Defender (Player " + str(defender_player) + "): " + defender_cards_text.strip_edges() + " (Total: " + str(defender_total) + ")"
	
	# Update result
	battle_result_outcome_label.text = result_text

# End turn button pressed
func _on_end_turn_pressed():
	print("End turn pressed by player ", current_player)
	
	# Add cards to all territories at end of turn
	for territory in territories.values():
		if territory.get_card_count() < 6:  # Max 6 cards per territory
			territory.set_card_count(territory.get_card_count() + 1)
	
	# Switch to next player
	current_player = 3 - current_player  # Switches between 1 and 2
	print("Switched to player ", current_player)
	
	# Reset selection
	reset_selection()
	update_ui()
	
	# Check for win condition
	check_win_condition()

# Reset game button pressed - show confirmation dialog
func _on_reset_button_pressed():
	print("Reset button pressed - showing confirmation")
	reset_confirm_dialog.popup_centered()

# Reset game confirmed
func _on_reset_confirm_pressed():
	print("Reset confirmed")
	reset_confirm_dialog.hide()
	reset_game()

# Reset game cancelled
func _on_reset_cancel_pressed():
	print("Reset cancelled")
	reset_confirm_dialog.hide()

# Reset the entire game to initial state
func reset_game():
	# Reset player
	current_player = 1
	
	# Get all territory IDs and shuffle them for random assignment
	var territory_ids = territories.keys()
	territory_ids.shuffle()
	
	# Assign territories randomly to players (split evenly)
	var territories_per_player = int(territory_ids.size() / 2)
	
	# Assign first half to player 1, second half to player 2
	for i in range(territory_ids.size()):
		var territory_id = territory_ids[i]
		var player_owner = 1 if i < territories_per_player else 2
		var random_card_count = randi_range(1, 4)
		
		territories[territory_id].set_territory_owner(player_owner)
		territories[territory_id].set_card_count(random_card_count)
		
		print("Territory ", territory_id, " assigned to Player ", player_owner, " with ", random_card_count, " cards")
	
	# Reset selection
	reset_selection()
	update_ui()
	
	# Clear battle result panel
	battle_result_attacker_label.text = "Attacker: -"
	battle_result_defender_label.text = "Defender: -"
	battle_result_outcome_label.text = "No battles yet"
	
	print("Game reset to initial state with random territory assignment")

# Check if someone won the game
func check_win_condition():
	var player_id = -1
	
	for territory in territories.values():
		var territory_owner = territory.get_territory_owner()
		if player_id == -1:
			player_id = territory_owner
		elif player_id != territory_owner:
			# If we find a territory owned by a different player, we can stop
			return
	print("GAME OVER: Player ", player_id, " wins!")
	show_win_dialog(player_id)

# Show win dialog (placeholder for now)
func show_win_dialog(winner_player: int):
	print("Player ", winner_player, " has won the game!")
	
	# Update win dialog text
	win_label.text = "Player " + str(winner_player) + " Wins!"
	
	# Show the dialog
	win_dialog.popup_centered()

# Play again button pressed
func _on_play_again_pressed():
	print("Play again pressed")
	win_dialog.hide()
	reset_game()

# Close button pressed
func _on_close_pressed():
	print("Close pressed")
	win_dialog.hide()
	get_tree().quit()
