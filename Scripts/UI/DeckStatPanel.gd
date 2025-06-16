extends Control

@onready var stats_list: VBoxContainer = $StatsList
var card_stat_line_scene: PackedScene = preload("res://Scenes/Utilities/CardStatLine.tscn")

var sprite_frames_cache: Dictionary = {}  # pour éviter de recharger tout le temps

func show_stats():
	# Nettoie les anciennes stats
	if stats_list:
		stats_list.clear()
	
	# Récupère les stats actuelles depuis GameData
	var stats = GameData.get_stats()  # Renvoie des dictionnaires : initial_deck_card_count, deck_card_count
	var deck_card_count = stats.get("deck_card_count")


	for card_name in deck_card_count.keys():
		if card_name == "TOTAL":
			continue

		var count = stats.deck_card_count[card_name]
		var total = stats.deck_card_count["TOTAL"]
		var percentage = float(count) / float(total) if total > 0 else 0.0

		var texture = _get_card_icon_texture(card_name)
		
		var card_line = card_stat_line_scene.instantiate()
		card_line.set_card_data(card_name, percentage, texture)
		stats_list.add_child(card_line)

func _get_card_icon_texture(card_name: String) -> Texture2D:
	if sprite_frames_cache.has(card_name):
		return sprite_frames_cache[card_name]

	for card in GameData.deck.deck_data.cards:
		if CardNames.CardName.keys()[card.name] == card_name:
			var sprite_frames: SpriteFrames = load(card.sprite_frames_path)
			var animation = "front"
			if sprite_frames.has_animation(animation):
				var texture = sprite_frames.get_frame_texture(animation, 0)
				sprite_frames_cache[card_name] = texture
				return texture
	return null
