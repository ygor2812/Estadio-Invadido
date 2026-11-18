extends Node2D

const BolaCena = preload("res://entities/bola.tscn")

const ARENA := Rect2(24, 24, 1104, 600) # parte caminhavel (dentro dos muros)
const TEMPO_META := 60.0
const ZONA_INTERVALO := 7.0
const BOLAS_INICIAIS := 3
const BOLAS_MAX := 10
const BOLA_INTERVALO := 7.0

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


# Responde uma pergunta: cabe um circulo desse tamanho nessa posicao sem encostar em nada?
func _livre(pos: Vector2, raio: float) -> bool:
	var forma := CircleShape2D.new()              # circulo imaginario: nao entra na cena
	forma.radius = raio
	var q := PhysicsShapeQueryParameters2D.new()  # a "pergunta" que vai pra fisica
	q.shape = forma                               # com qual forma
	q.transform = Transform2D(0.0, pos)           # em qual posicao (sem rotacao)
	q.collision_mask = 1                          # so olha a camada mundo: muros e blocos
	q.exclude = [jogador.get_rid()]               # ignora o jogador, senao ele bloquearia tudo
	# intersect_shape devolve o que seria atingido; o 1 e "pare no primeiro que achar".
	# Lista vazia = nada no caminho = o lugar esta livre.
	return get_world_2d().direct_space_state.intersect_shape(q, 1).is_empty()


# Sorteia um lugar novo pra zona: livre de obstaculo e longe de onde ela estava.
func _ponto_livre_zona(evitar: Vector2) -> Vector2:
	var raio_zona: float = zona.raio()        # le o tamanho real da colisao em zona.tscn
	# Encolhe a arena na medida do raio. O que se sorteia e o CENTRO do circulo,
	# entao sem isso metade da zona poderia nascer enterrada na parede.
	var area := ARENA.grow(-raio_zona)
	for i in 80:                              # tentativa e erro, ate 80 chutes
		var p := Vector2(                     # sorteia um ponto dentro da area encolhida
			randf_range(area.position.x, area.end.x),
			randf_range(area.position.y, area.end.y))
		if p.distance_to(evitar) < 280.0:
			continue                          # perto demais do lugar antigo: chuta outro
		if _livre(p, raio_zona * 0.8):        # 0.8 da uma folga: encostar de leve tudo bem
			return p                          # achou um bom: encerra aqui
	return evitar                             # nenhum serviu: deixa a zona onde esta


# Cria uma bola nova e solta em campo, longe do jogador.
func _nova_bola() -> void:
	var raio := randf_range(10.0, 16.0)       # cada bola nasce com um tamanho diferente
	var area := ARENA.grow(-(raio + 4.0))     # encolhe a arena pro raio caber, com 4 de folga
	var pos := area.get_center()              # plano B: se nenhum sorteio servir, nasce no meio
	for i in 60:                              # tentativa e erro, até 60 chutes
		var p := Vector2(
			randf_range(area.position.x, area.end.x),
			randf_range(area.position.y, area.end.y))
		# Tem que ser longe do jogador (pra não nascer na cara dele) e em lugar livre.
		if p.distance_to(jogador.position) > 200.0 and _livre(p, raio + 2.0):
			pos = p
			break                             # achou: para de procurar

	# A dificuldade que cresce: começa em 170 e sobe 0,6 por segundo de partida, até o teto
	# de 210. O randf_range dá 10% de variação pras bolas não ficarem idênticas.
	# O teto importa: a bola caçando anda 1,15x, ou seja 241, que é 80% dos 300 do jogador.
	# Assim dá sempre pra fugir dela.
	var v := minf(170.0 + decorrido * 0.6, 210.0) * randf_range(0.9, 1.15)

	var b = BolaCena.instantiate()            # cria a bola a partir de entities/bola.tscn
	b.raio = raio
	b.velocidade = v
	b.vel = Vector2.from_angle(randf() * TAU) * v   # TAU = volta inteira: direção sorteada
	b.position = pos
	bolas.add_child(b)
