extends Node

# Source of the attack / Current player territory
var source_territory_id := -1
# Target of the attack / Other player territory
var target_territory_id := -1
# List of territories
var territories := {}
# Current player (1 or 2)
var current_player := 1
# Reference to UI elements
var current_player_label
var win_dialog
var win_label

# When ready
func _ready() -> void:
	# Register territories into list
	var map = get_parent().get_node("Map")
	for child in map.get_children():
		# Check if the child is territory
		if child.scene_file_path == "res://territory.tscn":
			territories[child.territory_id] = child
	
	# Get reference to UI elements
	current_player_label = get_parent().get_node("UI/BottomPanel/VBoxContainer/CurrentPlayerLabel")
	win_dialog = get_parent().get_node("UI/WinDialog")
	win_label = get_parent().get_node("UI/WinDialog/WinLabel")
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
	else:
		target_territory_id = territory_id
		fight()
		print("Clicked other territory ", territory_id, " (Owner: ", territories[territory_id].get_territory_owner(), ")")

	
	return

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
		print("  ", card.value, card.suit)
	print("  Total value: ", source_total_value)
	
	print("Defender (player ", territories[target_territory_id].get_territory_owner(), ") cards:")
	for card in target_cards:
		print("  ", card.value, card.suit)
	print("  Total value: ", target_total_value)
	
	# Determine winner based on game rules
	var attacker_wins = false
	
	if source_total_value > target_total_value:
		attacker_wins = true
		print("RESULT: Attacker wins with higher total value!")
	elif source_total_value < target_total_value:
		attacker_wins = false
		print("RESULT: Defender wins with higher total value!")
	else:
		# Tie - check for same suit bonus (all cards same color)
		var source_all_same_suit = check_all_same_suit(source_cards)
		var target_all_same_suit = check_all_same_suit(target_cards)
		
		if source_all_same_suit and not target_all_same_suit:
			attacker_wins = true
			print("RESULT: Tie broken - Attacker wins with all same suit!")
		elif target_all_same_suit and not source_all_same_suit:
			attacker_wins = false
			print("RESULT: Tie broken - Defender wins with all same suit!")
		else:
			attacker_wins = false
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

# Update UI elements
func update_ui():
	if current_player_label:
		current_player_label.text = "Current Player: " + str(current_player)

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

# Reset game button pressed
func _on_reset_pressed():
	print("Reset game pressed")
	reset_game()

# Reset the entire game to initial state
func reset_game():
	# Reset player
	current_player = 1
	
	# Reset territories to initial state (from main.gd)
	territories[1].set_territory_owner(1)
	territories[1].set_card_count(2)
	territories[2].set_territory_owner(1)
	territories[2].set_card_count(1)
	territories[3].set_territory_owner(2)
	territories[3].set_card_count(4)
	territories[4].set_territory_owner(2)
	territories[4].set_card_count(3)
	
	# Reset selection
	reset_selection()
	update_ui()
	
	print("Game reset to initial state")

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
