class_name DeckData

extends Resource

@export var deck_name: String = ""
@export var cards: Array[CardData]

func get_deck_copy() -> Array[CardData]:
	return cards.duplicate(true)  # 'true' pour une duplication profonde
