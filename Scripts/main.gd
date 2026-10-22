extends Node2D
## Estadio Invadido. O cenario (chao, muros, jogador, zona e HUD)
## e' montado na cena main.tscn. Este script cuida das bolas, da zona e do tempo.
## Objetivo (Territorio): somar 60 s dentro da zona amarela.
## Aula 09: fim da partida -- vence aos 60 s na zona, perde quando a vida acaba.

const BolaCena = preload("res://scenes/bola.tscn")

const ARENA := Rect2(24, 24, 1104, 600) # parte caminhavel (dentro dos muros)
const TEMPO_META := 60.0
const ZONA_INTERVALO := 7.0
const BOLAS_INICIAIS := 3
const BOLAS_MAX := 14
const BOLA_INTERVALO := 5.0

@onready var jogador: CharacterBody2D = $Jogador
@onready var zona: Area2D = $Zona
@onready var bolas: Node2D = $Bolas
@onready var contador: Label = $HUD/Contador
@onready var texto_vida: Label = $HUD/Vida

var progresso := 0.0
var decorrido := 0.0
var timer_zona := ZONA_INTERVALO
var timer_bola := BOLA_INTERVALO
var iniciado := false


func _ready() -> void:
	randomize()
	zona.visible = false

	# espera a fisica registrar os muros antes de consultar espaco livre
	await get_tree().physics_frame
	await get_tree().physics_frame

	zona.position = _ponto_livre_zona(jogador.position)
	zona.visible = true
	for i in BOLAS_INICIAIS:
		_nova_bola()
	iniciado = true


func _physics_process(delta: float) -> void:
	if not iniciado:
		return

	decorrido += delta

	# zona muda de lugar
	timer_zona -= delta
	if timer_zona <= 0.0:
		zona.position = _ponto_livre_zona(zona.position)
		timer_zona = ZONA_INTERVALO

	# soma tempo dentro da zona
	var dentro: bool = zona.jogador_dentro()
	zona.dentro = dentro
	if dentro:
		progresso = minf(progresso + delta, TEMPO_META)
		if progresso >= TEMPO_META:
			vencer()
			return

	# novas bolas invadem o campo
	timer_bola -= delta
	if timer_bola <= 0.0:
		timer_bola = BOLA_INTERVALO
		if bolas.get_child_count() < BOLAS_MAX:
			_nova_bola()


func _process(_delta: float) -> void:
	contador.text = "%.1f / %d s" % [progresso, int(TEMPO_META)]
	texto_vida.text = "Vida: %d" % jogador.vida


func vencer() -> void:
	iniciado = false
	# call_deferred: troca de cena so' no fim do quadro, quando a fisica terminou.
	get_tree().change_scene_to_file.call_deferred("res://scenes/vitoria.tscn")


func perder() -> void:
	iniciado = false
	get_tree().change_scene_to_file.call_deferred("res://scenes/derrota.tscn")


func _livre(pos: Vector2, raio: float) -> bool:
	var forma := CircleShape2D.new()
	forma.radius = raio
	var q := PhysicsShapeQueryParameters2D.new()
	q.shape = forma
	q.transform = Transform2D(0.0, pos)
	q.collision_mask = 1
	q.exclude = [jogador.get_rid()]
	return get_world_2d().direct_space_state.intersect_shape(q, 1).is_empty()


func _ponto_livre_zona(evitar: Vector2) -> Vector2:
	var raio_zona: float = zona.raio()
	var area := ARENA.grow(-raio_zona)
	for i in 80:
		var p := Vector2(
			randf_range(area.position.x, area.end.x),
			randf_range(area.position.y, area.end.y))
		if p.distance_to(evitar) < 280.0:
			continue
		if _livre(p, raio_zona * 0.8):
			return p
	return evitar


func _nova_bola() -> void:
	var raio := randf_range(10.0, 16.0)
	var area := ARENA.grow(-(raio + 4.0))
	var pos := area.get_center()
	for i in 60:
		var p := Vector2(
			randf_range(area.position.x, area.end.x),
			randf_range(area.position.y, area.end.y))
		if p.distance_to(jogador.position) > 200.0 and _livre(p, raio + 2.0):
			pos = p
			break

	var v := minf(170.0 + decorrido * 1.5, 340.0) * randf_range(0.9, 1.15)
	var b = BolaCena.instantiate()
	b.raio = raio
	b.velocidade = v
	b.vel = Vector2.from_angle(randf() * TAU) * v
	b.position = pos
	bolas.add_child(b)
