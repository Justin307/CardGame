extends Node

## Colors for players
## This dictionary maps player IDs to their colors and names
## Each entry contains a list with two colors and the player's name
## The first color is used when the territory is inactive, and the second color is used when
## the territory is active, third is the name of the player
var player_colors = {
	1: [Color(1, 0.5, 0.5), Color(1, 0.2, 0.2), "Red"],
	2: [Color(0.5, 0.5, 1), Color(0.2, 0.2, 1), "Blue"],
	3: [Color(0.5, 1, 0.5), Color(0, 1, 0), "Green"],
	4: [Color(1, 1, 0.5), Color(1, 1, 0), "Yellow"]
}
