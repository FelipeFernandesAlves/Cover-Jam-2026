extends Resource
class_name DialogContent

enum ImageDirection { LEFT, RIGHT }

@export_multiline var texto: String = ""
@export var title: String
@export var imagem: Texture2D
@export var image_direction : ImageDirection = ImageDirection.LEFT

func _init(_title: String, _texto: String, _imagem: Texture2D, _image_direction: ImageDirection) -> void:
	self.title = _title
	self.texto = _texto
	self.imagem = _imagem
	self.image_direction = _image_direction
