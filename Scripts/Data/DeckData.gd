class_name DeckData

extends Resource

@export var deck_name: String = ""
@export var cards: Array[CardData]

@export var common_cards: Array[CardData]
@export var uncommon_cards: Array[CardData]
@export var rare_cards: Array[CardData]


# rajouter de la rareté aux cartes
# pour créer un deck avec rareté il faut créer des decks par rareté puis générer un nombre aléatoire
# pour piocher dans un des decks (rare 5%, uncommon 25%, common 70%)

func get_deck_copy() -> Array[CardData]:
	return cards.duplicate(true)  # 'true' pour une duplication profonde
