extends RigidBody2D
#Foi usado a Assistencia de IA na correção de erros das maquinas de estado e na criacao de bolas com tamanhos de diferentes
const RAIO_BASE := 12.0

const DISTANCIA_CACA := 200.0
const DISTANCIA_DESISTE := 340.0
const TEMPO_MINIMO_CACA := 0.8
const FORCA_CACA := 2.5
const TEMPO_CACANDO := 3.0
const TEMPO_CANSADA := 1.5
const MAX_CACANDO := 3

enum Estado { SURGINDO, QUICANDO, CACANDO, CANSADA }

static var cacando_agora := 0

var raio: float = 12.0
var velocidade: float = 200.0
var vel: Vector2 = Vector2.ZERO

var estado: Estado = Estado.SURGINDO
var tempo := 0.0

@onready var forma: CollisionShape2D = $CollisionShape2D
@onready var corpo: Polygon2D = $Corpo


func _ready() -> void:
	var circulo := forma.shape.duplicate() as CircleShape2D
	circulo.radius = raio
	forma.shape = circulo
	corpo.scale = Vector2.ONE * (raio / RAIO_BASE)
	trocar_estado(Estado.SURGINDO)


func _exit_tree() -> void:
	if estado == Estado.CACANDO:
		cacando_agora = maxi(cacando_agora - 1, 0)


func _physics_process(delta: float) -> void:
	tempo += delta

	match estado:
		Estado.SURGINDO:
			corpo.modulate.a = 0.3 if int(tempo * 10.0) % 2 == 0 else 0.8
			if tempo >= 1.0:
				trocar_estado(Estado.QUICANDO)

		Estado.QUICANDO:
			if cacando_agora < MAX_CACANDO and jogador_perto():
				trocar_estado(Estado.CACANDO)

		Estado.CACANDO:
			if tempo >= TEMPO_CACANDO:
				trocar_estado(Estado.CANSADA)
			elif tempo >= TEMPO_MINIMO_CACA and not jogador_perto(DISTANCIA_DESISTE):
				trocar_estado(Estado.CANSADA)

		Estado.CANSADA:
			if tempo >= TEMPO_CANSADA:
				trocar_estado(Estado.QUICANDO)


func trocar_estado(novo: Estado) -> void:
	if estado == Estado.CACANDO and novo != Estado.CACANDO:
		cacando_agora = maxi(cacando_agora - 1, 0)

	estado = novo
	tempo = 0.0

	match estado:
		Estado.SURGINDO:
			freeze = true
			corpo.modulate = Color(1, 1, 1, 0.3)
		Estado.QUICANDO:
			freeze = false
			linear_velocity = vel if vel != Vector2.ZERO else Vector2.RIGHT * velocidade
			corpo.modulate = Color(1, 1, 1, 1)
		Estado.CACANDO:
			cacando_agora += 1
			corpo.modulate = Color(1, 0.45, 0.35, 1)
		Estado.CANSADA:
			corpo.modulate = Color(0.7, 0.8, 1, 1)


func _integrate_forces(state: PhysicsDirectBodyState2D) -> void:
	if estado == Estado.SURGINDO:
		return

	var v := state.linear_velocity
	if v.length() < 1.0:
		v = vel if vel != Vector2.ZERO else Vector2.RIGHT

	var direcao := v.normalized()
	var ritmo := velocidade

	match estado:
		Estado.CACANDO:
			var alvo := direcao_do_jogador()
			if alvo != Vector2.ZERO:
				direcao = direcao.lerp(alvo, FORCA_CACA * state.step).normalized()
			ritmo = velocidade * 1.15
		Estado.CANSADA:
			ritmo = velocidade * 0.55

	state.linear_velocity = direcao * ritmo


func jogador() -> Node2D:
	return get_tree().get_first_node_in_group("jogador") as Node2D


func jogador_perto(limite: float = DISTANCIA_CACA) -> bool:
	var j := jogador()
	return j != null and global_position.distance_to(j.global_position) < limite


func direcao_do_jogador() -> Vector2:
	var j := jogador()
	if j == null:
		return Vector2.ZERO
	return (j.global_position - global_position).normalized()
