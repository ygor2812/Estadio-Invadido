extends CharacterBody2D
## Jogador visto de cima. Anda com WASD ou setas e e' bloqueado pelos muros.
## (Colisao, grupo "jogador", modo flutuante e o visual estao na cena jogador.tscn.)
## Aula 09: ganhou vida. Tomar bolada tira 1 de vida, com 1 s de invencibilidade.

const VELOCIDADE := 300.0

@export var vida: int = 3
var invencivel := false

@onready var hurtbox: Area2D = $Hurtbox


func _process(_delta: float) -> void:
	# Tem bola encostando em mim? (so' conta se nao estiver invencivel)
	if not invencivel and hurtbox.has_overlapping_bodies():
		levar_dano()


func _physics_process(_delta: float) -> void:
	var direcao := Vector2(
		float(Input.is_key_pressed(KEY_D) or Input.is_key_pressed(KEY_RIGHT))
			- float(Input.is_key_pressed(KEY_A) or Input.is_key_pressed(KEY_LEFT)),
		float(Input.is_key_pressed(KEY_S) or Input.is_key_pressed(KEY_DOWN))
			- float(Input.is_key_pressed(KEY_W) or Input.is_key_pressed(KEY_UP)))
	velocity = direcao.limit_length(1.0) * VELOCIDADE
	move_and_slide()


func levar_dano() -> void:
	vida -= 1
	if vida <= 0:
		invencivel = true
		get_tree().current_scene.perder()
		return
	# Um segundo de invencibilidade, meio transparente.
	invencivel = true
	modulate.a = 0.4
	await get_tree().create_timer(1.0).timeout
	modulate.a = 1.0
	invencivel = false
