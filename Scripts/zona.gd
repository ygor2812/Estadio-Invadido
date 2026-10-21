extends Area2D
## Zona amarela. O tamanho vem do CollisionShape2D (círculo) em zona.tscn
## e o visual (Preenchimento + Borda) acompanha esse tamanho.

const RAIO_BASE := 90.0 # raio do desenho em zona.tscn

var dentro: bool = false:
	set(valor):
		dentro = valor
		if is_node_ready():
			preenchimento.color.a = 0.40 if dentro else 0.22

@onready var forma: CollisionShape2D = $CollisionShape2D
@onready var visual: Node2D = $Visual
@onready var preenchimento: Polygon2D = $Visual/Preenchimento


func _ready() -> void:
	visual.scale = Vector2.ONE * (raio() / RAIO_BASE)


func raio() -> float:
	return (forma.shape as CircleShape2D).radius


func jogador_dentro() -> bool:
	for corpo in get_overlapping_bodies():
		if corpo.is_in_group("jogador"):
			return true
	return false
