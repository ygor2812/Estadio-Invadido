extends RigidBody2D
## Bola quicante. A física (bounce 1, sem atrito, sem gravidade) e o visual
## (Polygon2D branco) estão na cena bola.tscn. Aqui fica só a lógica.

const RAIO_BASE := 12.0 # raio do desenho e da colisão em bola.tscn

var raio: float = 12.0
var velocidade: float = 200.0
var vel: Vector2 = Vector2.ZERO # velocidade inicial (direção * velocidade)
var protecao: float = 1.0       # fica parada e piscando antes de começar a se mover

@onready var forma: CollisionShape2D = $CollisionShape2D
@onready var corpo: Polygon2D = $Corpo


func _ready() -> void:
	# cada bola tem o seu próprio tamanho (duplica o shape para não afetar as outras)
	var circulo := forma.shape.duplicate() as CircleShape2D
	circulo.radius = raio
	forma.shape = circulo
	corpo.scale = Vector2.ONE * (raio / RAIO_BASE)

	# começa congelada e piscando durante o tempo de proteção
	freeze = true
	corpo.modulate.a = 0.3


func _physics_process(delta: float) -> void:
	if protecao > 0.0:
		protecao -= delta
		corpo.modulate.a = 0.3 if int(protecao * 10.0) % 2 == 0 else 0.8
		if protecao <= 0.0:
			freeze = false
			linear_velocity = vel
			corpo.modulate.a = 1.0


func _integrate_forces(state: PhysicsDirectBodyState2D) -> void:
	# mantém a velocidade constante nos quiques
	var v := state.linear_velocity
	if v.length() < 1.0:
		v = vel if vel != Vector2.ZERO else Vector2.RIGHT
	state.linear_velocity = v.normalized() * velocidade
