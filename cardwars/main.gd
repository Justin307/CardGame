extends Node2D

func _ready() -> void:
	$Map/Territory1.set_territory_owner(1)
	$Map/Territory1.set_card_count(2)
	$Map/Territory2.set_territory_owner(1)
	$Map/Territory2.set_card_count(1)
	$Map/Territory3.set_territory_owner(2)
	$Map/Territory3.set_card_count(4)
	$Map/Territory4.set_territory_owner(2)
	$Map/Territory4.set_card_count(3)
