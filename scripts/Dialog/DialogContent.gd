extends Resource
class_name DialogContent

enum ImageDirection { LEFT, RIGHT }
enum Emotion {IDLE, IMPRESSED, HAPPY, ALERT, SAD, ANGRY, FACELESS}
enum Personagem {APRENDIZ, MESTRE}

@export_multiline var texto: String = ""
@export var image_direction : ImageDirection = ImageDirection.LEFT
@export var personagem : Personagem = Personagem.APRENDIZ
@export var emotion : Emotion = Emotion.IDLE
