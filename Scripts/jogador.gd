extends CharacterBody2D
## Jogador visto de cima. Anda com WASD ou setas e é bloqueado pelos muros.
## (Colisão, grupo "jogador", modo flutuante e o visual estão na cena jogador.tscn.)

const VELOCIDADE := 300.0


func _physics_process(_delta: float) -> void:
	var direcao := Vector2(
		float(Input.is_key_pressed(KEY_D) or Input.is_key_pressed(KEY_RIGHT))
			- float(Input.is_key_pressed(KEY_A) or Input.is_key_pressed(KEY_LEFT)),
		float(Input.is_key_pressed(KEY_S) or Input.is_key_pressed(KEY_DOWN))
			- float(Input.is_key_pressed(KEY_W) or Input.is_key_pressed(KEY_UP)))
	velocity = direcao.limit_length(1.0) * VELOCIDADE
	move_and_slide()
