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

func display_history():
	print(cards_drawn_history)
	cards_drawn_history = []
	

func clean_cards_in_game():
	var index = 0
	for card in cards_in_game:
		if !card:
			cards_in_game.remove_at(index)
		index += 1

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
