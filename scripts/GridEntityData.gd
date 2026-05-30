extends RefCounted
class_name GridEntityData

var type: GridState.CellType
var visual_node: Node2D # Referência de volta para o nó visual correspondente

func _init(p_type: GridState.CellType, p_node: Node2D):
	type = p_type
	visual_node = p_node
