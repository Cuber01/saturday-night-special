extends Area2D

export var worth: int = 1

var match_manager: Object
signal sig_round_end

func _ready():
	match_manager = get_parent().get_parent()
	match_manager.connect("sig_round_end", self, "_on_round_end")

func _on_round_end() -> void:
	queue_free()

func _on_Coin_body_entered(body: Node) -> void:
	if body is Player:
		match_manager._on_collected_coin(body.player_index, worth)
		queue_free()
