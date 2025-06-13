extends Label

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	ScoreManager.connect("score_changed",_on_score_change)
	text = "Highscore : %s\nScore : %s" % [ScoreManager.highscore, 0]


func _on_score_change():
	text = "Highscore : %s\nScore : %s" % [ScoreManager.highscore, ScoreManager.score]
	
