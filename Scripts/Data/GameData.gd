extends Node


var cards_drawn_history = []
var cards_in_game: Array[CardManager] = []
var deck: Deck = null

var last_card_drawn: CardManager


func _ready() -> void:
	print("GameData loaded")


func _process(_delta: float) -> void:
	clean_cards_in_game()


func _on_card_drawn(card: CardManager):
	cards_in_game.append(card)
	cards_drawn_history.append(CardNames.CardName.keys()[card.data.name])
	last_card_drawn = card
	print(get_stats())

func display_history():
	print(cards_drawn_history)
	cards_drawn_history = []
	

func clean_cards_in_game():
	cards_in_game = cards_in_game.filter(func(card): return card != null)


func get_stats():
	var initial_deck_card_count := {}
	var game_card_count := {}
	var deck_card_count := {}
	var total_initial := 0
	var total_drawn := 0
	
	# Comptage des cartes dans le deck initial
	for card in deck.deck_data.cards:
		var card_name = CardNames.CardName.keys()[card.name]
		initial_deck_card_count[card_name] = initial_deck_card_count.get(card_name, 0) + 1
		total_initial += 1
	
	# Comptage des cartes tirées
	for card_name in cards_drawn_history:
		game_card_count[card_name] = game_card_count.get(card_name, 0) + 1
		total_drawn += 1
	
	# Calcul des cartes restantes
	for card_name in initial_deck_card_count.keys():
		var drawn = game_card_count.get(card_name, 0)
		deck_card_count[card_name] = initial_deck_card_count[card_name] - drawn
	
	# Ajout des totaux
	initial_deck_card_count["TOTAL"] = total_initial
	game_card_count["TOTAL"] = total_drawn
	deck_card_count["TOTAL"] = total_initial - total_drawn
	
	return {
		"initial": initial_deck_card_count,
		"drawn": game_card_count,
		"remaining": deck_card_count
	}


func reset_level():
	display_history()
	get_tree().reload_current_scene()
	WinManager.cleanup()
	ScoreManager.cleanup()
	

func set_deck(new_deck: Deck) -> void:
	cards_in_game = []
	deck = new_deck
	if deck:
		deck.card_drawn.connect(_on_card_drawn)
