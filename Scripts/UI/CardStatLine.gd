extends HBoxContainer

@onready var card_icon: TextureRect = $CardIcon
@onready var draw_chance_label: Label = $DrawChance

var texture: Texture2D
var chance

func _on_ready() -> void:
	card_icon.texture = texture
	
	draw_chance_label.text = "%s%%" % chance


func setup(new_texture: Texture2D, new_chance: int):	
	texture = new_texture
	chance = new_chance
