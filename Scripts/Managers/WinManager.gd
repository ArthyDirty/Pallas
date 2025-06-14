extends Node

var deck : Deck

var Card_slots

var col_max = 0
var row_max = 0

var cards_in_game: Array[CardManager] = []
var jeu = []
var jeu_card_slots = []
var jeu_carte = []
var won = false

signal score_changed(score)


func _process(_delta: float) -> void:
	cards_in_game = GameData.cards_in_game


# appelée lorsqu'une carte est placée sur un card_slot
func _on_card_placed(emp_col, emp_row, card, card_name, node: CardSlot):
	jeu[emp_col][emp_row] = card_name
	jeu_card_slots[emp_col][emp_row] = node
	jeu_carte[emp_col][emp_row] = card
	if !won:
		if !_check_alignement():
			var card_count = 0
			for i in jeu_carte:
				for j in i:
					if j is CardManager:
						card_count += 1
			if card_count == 9:
				end_game()

#verifie les alignements plus grand que 3
func _check_alignement():
	var max_len = max(col_max + 1,row_max + 1)
	var align = false
	
	for n in range(max_len):
		if max_len - n > 2:
			if _check_n_align(max_len - n):
				align = true
	return align


func end_game():
	won = true
	deck.can_draw = false
	await get_tree().create_timer(0.5).timeout
	for card in cards_in_game:
		card.show_card()
		await get_tree().create_timer(0.1).timeout
	for card in cards_in_game:
		if card:
			card.card_animated_sprite.play_dissolve(true)
			await get_tree().create_timer(0.1).timeout
	await get_tree().create_timer(2.5).timeout
	GameData.reset_level()
	
	
	


#verifie si n mêmes cartes sont alignées
func _check_n_align(n_align: int = 3) -> bool:
	var directions = [
		Vector2(1, 0),   # → horizontal
		Vector2(0, 1),   # ↓ vertical
		Vector2(1, 1),   # ↘ diagonale
		Vector2(-1, 1),  # ↙ diagonale inversée
	]

	var alignment = 0
	var score = 0
	var aligned_positions: Array[Vector2] = []

	for dir in directions:
		var dx = int(dir.x)
		var dy = int(dir.y)

		for x in range(col_max + 1):
			for y in range(row_max + 1):
				var last_card := CardNames.CardName.BLANK
				var count := 0
				var positions := []
				var i := 0

				while true:
					var cx = x + dx * i
					var cy = y + dy * i

					if cx < 0 or cy < 0 or cx > col_max or cy > row_max:
						break

					var card: CardNames.CardName = jeu[cx][cy]

					if card == last_card and card != CardNames.CardName.BLANK:
						count += 1
						positions.append(Vector2(cx, cy))
						if count >= n_align:
							for k in range(n_align):
								var pos = positions[-(k + 1)]
								if pos not in aligned_positions:
									aligned_positions.append(pos)
									score += jeu_carte[pos.x][pos.y].data.damage
							alignment += 1
					else:
						last_card = card
						count = 1 if card != CardNames.CardName.BLANK else 0
						positions = [Vector2(cx, cy)] if card != CardNames.CardName.BLANK else []

					i += 1

	# Libération des card_slots après détection
	for pos in aligned_positions:
		jeu_card_slots[pos.x][pos.y].free_card_slot()
		jeu_card_slots[pos.x][pos.y] = null
		jeu[pos.x][pos.y] = CardNames.CardName.BLANK
		jeu_carte[pos.x][pos.y] = 0

	
	if score > 0:
		score_changed.emit(alignment * score)
	
	return score > 0



func cleanup():
	for emp in Card_slots:
		if is_instance_valid(emp):
			emp.card_placed.disconnect(_on_card_placed)


func reset_win_manager():
	col_max = 0
	row_max = 0
	cards_in_game = []
	jeu = []
	jeu_card_slots = []
	jeu_carte = []
	won = false
	
	Card_slots = get_tree().get_nodes_in_group("play_slots")
	for element in Card_slots:
		element.card_placed.connect(_on_card_placed)
		var col = element.get_col()
		var row = element.get_row()
		if col > col_max:
			col_max = col
		if row > row_max:
			row_max = row
		
	for i in range(col_max + 1):
		var col = []
		for j in range(row_max + 1):
			col.append(CardNames.CardName.BLANK)
		jeu.append(col)
	
	for i in range(col_max + 1):
		var col = []
		for j in range(row_max + 1):
			col.append(CardNames.CardName.BLANK)
		jeu_card_slots.append(col)
	
	for i in range(col_max + 1):
		var col = []
		for j in range(row_max + 1):
			col.append(0)
		jeu_carte.append(col)


func set_deck(new_deck: Deck) -> void:
	deck = new_deck
	# Connecter ou reconnecter le signal, par exemple
	if deck:
		reset_win_manager()
		
