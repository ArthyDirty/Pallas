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
	cards_in_game = cards_in_game.filter(func(card): return card != null)


func get_stats() -> Dictionary:
	var initial = {}
	var drawn = {}
	var remaining = {}
	var total = 0

	for card in deck.deck_data.cards:
		var name = CardNames.CardName.keys()[card.name]
		initial[name] = initial.get(name, 0) + 1
		drawn[name] = drawn.get(name, 0)
		remaining[name] = remaining.get(name, 0) + 1
		total += 1
	initial["TOTAL"] = total

	for name in cards_drawn_history:
		drawn[name] = drawn.get(name, 0) + 1
		drawn["TOTAL"] = drawn.get("TOTAL", 0) + 1
		remaining[name] = initial.get(name, 0) - drawn.get(name, 0)

	remaining["TOTAL"] = total - drawn.get("TOTAL", 0)

	return {
		"initial": initial,
		"drawn": drawn,
		"remaining": remaining
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
