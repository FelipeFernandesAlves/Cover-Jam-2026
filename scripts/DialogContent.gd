extends Resource
class_name DialogContent

enum ImageDirection { LEFT, RIGHT }
@export_multiline var texto: String = ""
@export var imagem: Texture2D
@export var image_direction : ImageDirection = ImageDirection.LEFT
