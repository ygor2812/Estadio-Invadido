extends Control
## Tela de fim (vitoria ou derrota). As duas cenas usam este mesmo script.
## Enter (ui_accept) recomeca a partida, voltando para a arena.

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("ui_accept"):
		get_tree().change_scene_to_file("res://scenes/main.tscn")
