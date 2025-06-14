class_name Deck

extends Node2D

@onready var deck_animated_sprite: AnimatedSprite2D = $DeckAnimatedSprite
@onready var surbrillance_animated_sprite: AnimatedSprite2D = $SurbrillanceAnimatedSprite

const card_scene = preload("res://Scenes/Cards/CardScene.tscn")

@export var deck_data: DeckData

@export var draw_delay := 1.0  # secondes entre deux tirages

var cards: Array[CardData]
var deck_empty = true

var can_draw := true

signal card_drawn(card)
signal card_added(card)

func _ready() -> void:
	PowerManager.set_deck(self)
	WinManager.set_deck(self)
	GameData.set_deck(self)
	
	if deck_data and !deck_data.cards.is_empty():
		cards = deck_data.get_deck_copy()
		deck_empty = false
		deck_animated_sprite.play("not_empty")
		cards.shuffle()


func _on_button_up() -> void:
	if can_draw:
		spawn_card()
		can_draw = false


func _on_button_mouse_entered() -> void:
	if !deck_empty and can_draw:
		surbrillance_animated_sprite.play("surbrillance")


func _on_button_mouse_exited() -> void:
	surbrillance_animated_sprite.play("default")


func spawn_card(card: CardData = null):
	var card_data: CardData
	
	if card:
		card_data = card
	elif deck_empty:
		return null
	else:
		card_data = cards.pop_front()
	
	var card_instance = card_scene.instantiate()
	call_deferred("add_child", card_instance)
	card_instance.set_card_data(card_data.duplicate_data())
	card_drawn.emit(card_instance)
	

	if cards.is_empty():
		deck_empty = true
		deck_animated_sprite.play("empty")
		print("empty")
	
	await get_tree().create_timer(draw_delay).timeout
	can_draw = true  # autoriser à tirer une nouvelle carte
	
	return card_instance


func add_card(scene: PackedScene, order: String = "") -> void:
	if scene == null:
		print("Tentative d'ajouter une carte nulle au deck.")
		return

	match order:
		"top":
			cards.insert(0, scene)  # sommet du deck
		"bottom":
			cards.append(scene)     # dessous du deck
		_:
			cards.append(scene)
			cards.shuffle()         # si position vide ou invalide
	
	card_added.emit(scene)
	deck_empty = false
	deck_animated_sprite.play("not_empty")
