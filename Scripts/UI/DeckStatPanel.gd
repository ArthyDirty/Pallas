extends Control


@onready var stats_list: VBoxContainer = $StatList

var card_stat_line_scene: PackedScene = preload("res://Scenes/Utilities/CardStatLine.tscn")

var sprite_frames_cache: Dictionary = {}  # pour éviter de recharger tout le temps


func show_stats():	
	for n in stats_list.get_child_count():
		stats_list.get_child(n).queue_free()
	
	# Récupère les stats actuelles depuis GameData
	var stats = GameData.get_stats()  # Renvoie des dictionnaires : initial, drawn, remaining
	var initial = stats.get("initial")
	var remaining = stats.get("remaining")
	
	var card_names = initial.keys()

	for card_name in card_names:
		if card_name == "TOTAL":
			continue

		var count = remaining[card_name]
		var total = remaining["TOTAL"]
		var percentage = int(float(count) / float(total) * 100) if total > 0 else 0

		var texture = _get_card_icon_texture(card_name)
		
		var card_line = card_stat_line_scene.instantiate()
		card_line.setup(texture, percentage)
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
