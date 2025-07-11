extends Node

# Source of the attack / Current player territory
var source_territory_id := -1
# Target of the attack / Other player territory
var target_territory_id := -1
# List of territories
var territories := {}
# Current player
var current_player := 1
# Number of players
var player_count := 3 # Change this to desired number of players
# Territory adjacency map - defines which territories are neighbors
var territory_neighbors := {
	1: [2,8],				# 2					
	2: [1,9,3],				# 3					
	3: [2,9,10],			# 3		
	4: [5,6,11],			# 3			
	5: [4,6,7],				# 3							
	6: [4,5,11,25],			# 4			
	7: [5,25,24],			# 3			
	8: [1,9,14],			# 3
	9: [2,3,8,14,13,10],	# 6	
	10: [3,9,12,11],		# 4	
	11: [10,4,6,12],		# 4	
	12: [10,11,21,19,13],	# 5
	13: [9,12,19,18],		# 4	
	14: [8,9,16,15],		# 4	
	15: [14,16],			# 2	
	16: [15,14,17],			# 3	
	17: [16,18],			# 2	
	18: [17,13],			# 2
	19: [20,13,12],			# 3
	20: [19,21,22],			# 3
	21: [12,20,22,23],		# 4
	22: [20,21,23,26],		# 4
	23: [26,22,21,25,24],	# 5
	24: [7,25,23],			# 3
	25: [6,7,24,23],		# 4
	26: [22,23],			# 2
}
# Reference to UI elements
var current_player_label
var win_dialog
var win_label
var reset_confirm_dialog
var battle_result_attacker_label
var battle_result_defender_label
var battle_result_outcome_label

# Constants
const MAX_INIT_CARDS_PER_TERRITORY := 4 ## Max initial number of cards per territory
const MAX_CARDS_PER_TERRITORY := 6 ## Max number of cards per territory
const CARDS_COEFFICIENT := 0.8 ## Percentage of owned territories to calculate new dice
const MIN_CARDS_TO_ADD := 1 ## Minimum number of cards to add in turn

## Called when the node is ready
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
	reset_game()

## Input event handler
func _input(event):
	if event is InputEventKey and event.pressed:
		if event.keycode == KEY_ESCAPE:
			get_tree().quit()
		elif event.keycode == KEY_SPACE:
			if win_dialog and not win_dialog.visible:
				_on_end_turn_pressed()

## When territory is selected/clicked
##
## This function is connected to the territory_selected signal of each territory
func _on_territory_selected(territory_id):
	# Get clicked territory owner
	var territory_owner = territories[territory_id].get_territory_owner()

	if territory_owner == current_player:
		clicked_own_territory(territory_id)
	else:
		clicked_other_territory(territory_id)

## End turn button pressed
##
## This function is called when the "End Turn" button is pressed
func _on_end_turn_pressed():
	# Deactivate selected territory
	if source_territory_id != -1:
		territories[source_territory_id].set_active(false)
	# Get all territories owned by current player
	var owned_territories = []
	for territory in territories.values():
		if territory.get_territory_owner() == current_player:
			owned_territories.append(territory)
	var owned_count = owned_territories.size()
	# Calculate number of new dice to add
	var new_dice = int(round(owned_count * CARDS_COEFFICIENT))
	new_dice = max(new_dice, MIN_CARDS_TO_ADD)
	# Shuffle and pick random territories to add dice
	owned_territories.shuffle()
	while new_dice > 0 and owned_territories.size() > 0:
		var idx = randi() % owned_territories.size()
		var territory = owned_territories[idx]
		var current_count = territory.get_card_count()
		if current_count >= MAX_CARDS_PER_TERRITORY:
			owned_territories.remove_at(idx)
			continue
		territory.set_card_count(current_count + 1)
		new_dice -= 1
	# Switch to next player who has at least one territory
	var next_player = current_player
	var found = false
	for i in range(player_count):
		next_player = (next_player % player_count) + 1
		for territory in territories.values():
			if territory.get_territory_owner() == next_player:
				found = true
				break
		if found:
			current_player = next_player
			break
	# Reset selection
	reset_selection()
	update_ui()
	# Check for win condition
	check_win_condition()

## Reset button pressed
##
## This function is called when the "Reset" button is pressed
## It shows a confirmation dialog before resetting the game
func _on_reset_button_pressed():
	reset_confirm_dialog.popup_centered()

## Reset game confirmed
## 
## This function is called when the reset confirmation dialog's confirm button is pressed
func _on_reset_confirm_pressed():
	reset_confirm_dialog.hide()
	reset_game()

## Reset game cancelled
## 
## This function is called when the reset confirmation dialog's cancel button is pressed
func _on_reset_cancel_pressed():
	reset_confirm_dialog.hide()

## Play again button pressed
##
## This function is called when the "Play Again" button is pressed
func _on_play_again_pressed():
	win_dialog.hide()
	reset_game()

## Close button pressed
## 
## This function is called when the "Close" button is pressed
func _on_close_pressed():
	win_dialog.hide()
	get_tree().quit()

## When own territory is clicked
## 
## This function is called when the player clicks on their own territory
## It checks if the territory is already selected, if not, verifies if it has more than one card,
## and sets it as the source territory for an attack
func clicked_own_territory(territory_id):
	# Deselect source territory if clicked again
	if source_territory_id == territory_id:
		territories[territory_id].set_active(false)
		source_territory_id = -1
	elif territories[territory_id].get_card_count() <= 1:
		return
	else:
		if source_territory_id != -1:
			territories[source_territory_id].set_active(false)
		territories[territory_id].set_active(true)
		source_territory_id = territory_id

## When other/not_owned territory is clicked
## 
## This function is called when the player clicks on a territory owned by another player
## It checks if the source territory is selected, verifies if the territories are neighbors,
## and initiates the attack if valid
func clicked_other_territory(territory_id):
	if source_territory_id == -1:
		return
	# Check if territories are neighbors
	if not are_territories_neighbors(source_territory_id, territory_id):
		return
	territories[source_territory_id].set_active(false)
	target_territory_id = territory_id
	fight()

## Reset selection
##
## This function resets the selected source and target territories
func reset_selection():
	source_territory_id = -1
	target_territory_id = -1

## Fight between two territories
##
## This function handles the battle logic between the source and target territories
## It generates random cards for both attacker and defender, calculates their total values,
## and determines the winner based on the game rules.
## If the attacker wins, they take over the target territory; otherwise, they lose cards
func fight():
	var source_territory_card_count = territories[source_territory_id].get_card_count()
	var target_territory_card_count = territories[target_territory_id].get_card_count()
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
	# Determine winner based on game rules
	var attacker_wins = false
	var result_text = ""
	if source_total_value > target_total_value:
		attacker_wins = true
		result_text = "Attacker wins with higher total value!"
	elif source_total_value < target_total_value:
		attacker_wins = false
		result_text = "Defender wins with higher total value!"
	else:
		# Tie - check for same suit bonus (all cards same color)
		var source_all_same_suit = check_all_same_suit(source_cards)
		var target_all_same_suit = check_all_same_suit(target_cards)
		if source_all_same_suit and not target_all_same_suit:
			attacker_wins = true
			result_text = "Tie broken - Attacker wins with all same suit!"
		elif target_all_same_suit and not source_all_same_suit:
			attacker_wins = false
			result_text = "Tie broken - Defender wins with all same suit!"
		else:
			attacker_wins = false
			result_text = "Tie - Defender wins by default!"
	# Apply battle results
	if attacker_wins:
		# Attacker wins - takes over the territory
		territories[target_territory_id].set_card_count(territories[source_territory_id].get_card_count() - 1)
		territories[target_territory_id].set_territory_owner(territories[source_territory_id].get_territory_owner())
		territories[source_territory_id].set_card_count(1)
	else:
		# Defender wins - attacker loses cards
		territories[source_territory_id].set_card_count(1)

	# Update battle result panel
	update_battle_result_panel(source_cards, target_cards, source_total_value, target_total_value, result_text)
	check_win_condition()
	reset_selection()

## Check if all cards in the array have the same suit
## 
## This function checks if all cards in the provided array have the same suit
## Returns true if all cards have the same suit, false otherwise
func check_all_same_suit(cards: Array) -> bool:
	if cards.size() <= 1:
		return true
	
	var first_suit = cards[0].suit
	for card in cards:
		if card.suit != first_suit:
			return false
	return true

## Check if two territories are neighbors
##
## This function checks if the two given territory IDs are neighbors
## Returns true if they are neighbors, false otherwise
func are_territories_neighbors(source_id: int, target_id: int) -> bool:
	if territory_neighbors.has(source_id):
		return target_id in territory_neighbors[source_id]
	return false

## Generate a random card
##
## This function generates a random card with a value and suit
## Returns a dictionary with card value (2-14), suit (♥,♦,♣,♠), and display value (2-10, J, Q, K, A)
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

## Get card display value
##
## This function converts numeric card value to display string
## Returns "J", "Q", "K", "A" for face cards, otherwise returns the numeric value as string
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

## Update UI with current player information
##
## This function updates the current player label with the player's color name
## It retrieves the color name from the Global player colors dictionary
## and sets the label text accordingly
func update_ui():
	if current_player_label:
		var color_name = Global.player_colors[current_player][2]
		current_player_label.text = "Current Player: " + color_name

## Update battle result panel
##
## This function updates the battle result panel with the cards and results
## It takes the attacker and defender cards, their total values, and the result text
## and updates the corresponding labels in the UI
func update_battle_result_panel(attacker_cards: Array, defender_cards: Array, attacker_total: int, defender_total: int, result_text: String):
	# Update attacker info
	var attacker_player = territories[source_territory_id].get_territory_owner()
	var attacker_color = Global.player_colors[attacker_player][2]
	var attacker_cards_text = ""
	for card in attacker_cards:
		attacker_cards_text += card.display_value + card.suit + " "
	battle_result_attacker_label.text = "Attacker (" + attacker_color + "): " + attacker_cards_text.strip_edges() + " (Total: " + str(attacker_total) + ")"
	# Update defender info
	var defender_player = territories[target_territory_id].get_territory_owner()
	var defender_color = Global.player_colors[defender_player][2]
	var defender_cards_text = ""
	for card in defender_cards:
		defender_cards_text += card.display_value + card.suit + " "
	battle_result_defender_label.text = "Defender (" + defender_color + "): " + defender_cards_text.strip_edges() + " (Total: " + str(defender_total) + ")"
	# Update result
	battle_result_outcome_label.text = result_text

## Reset game to initial state
## 
## This function resets the game to its initial state
## It randomly assigns territories to players, resets the selection,
## updates the UI, and clears the battle result panel
func reset_game():
	# Reset player
	current_player = randi()%player_count+1
	
	# Get all territory IDs and shuffle them for random assignment
	var territory_ids = territories.keys()
	territory_ids.shuffle()
	
	# Assign territories to players
	for i in range(territory_ids.size()):
		var territory_id = territory_ids[i]
		var player_owner = (i % player_count) + 1
		var random_card_count = randi_range(1, MAX_INIT_CARDS_PER_TERRITORY)
		
		territories[territory_id].set_territory_owner(player_owner)
		territories[territory_id].set_card_count(random_card_count)
	
	# Reset selection
	reset_selection()
	update_ui()
	
	# Clear battle result panel
	battle_result_attacker_label.text = "Attacker: -"
	battle_result_defender_label.text = "Defender: -"
	battle_result_outcome_label.text = "No battles yet"

## Check win condition
##
## This function checks if there is only one player left with territories
## If so, it declares that player as the winner and shows the win dialog
func check_win_condition():
	var remaining_players = []
	for territory in territories.values():
		var territory_owner = territory.get_territory_owner()
		if not remaining_players.has(territory_owner):
			remaining_players.append(territory_owner)
	if remaining_players.size() == 1:
		show_win_dialog(remaining_players[0])

## Show win dialog
##
## This function shows the win dialog with the winner's color name
## It updates the dialog text and centers it on the screen
func show_win_dialog(winner_player: int):
	# Update win dialog text
	var color_name = Global.player_colors[winner_player][2]
	win_label.text = color_name + " Wins!"
	# Show the dialog
	win_dialog.popup_centered()
