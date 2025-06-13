extends Node

var score = 0
var highscore = 0

signal score_changed()

func _ready() -> void:
	WinManager.score_changed.connect(_on_score_change)
	score_changed.emit()


func _on_score_change(points_scored):
	score += points_scored
	score_changed.emit()

#reste à afficher le score et le highscore en UI

func cleanup():
	highscore = score if score > highscore else highscore
	score = 0
