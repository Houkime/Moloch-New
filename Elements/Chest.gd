extends RigidBody2D

enum TYPES {
	ITEM,
	WAND,
	SPELL,
}

var type :int = TYPES.ITEM

var open := false
var Player :KinematicBody2D
var Map :TileMap

func _ready():
	Player = get_tree().get_nodes_in_group("Player")[0]
	Map = get_tree().get_nodes_in_group("World")[0]
	type = Items.LootRNG.randi()%TYPES.size()
	match type:
		TYPES.ITEM:
			$Sprite.modulate = "#96ff9a"
		TYPES.WAND:
			$Sprite.modulate = "#ff4da9"
		TYPES.SPELL:
			$Sprite.modulate = "#188add"

func _process(_delta):
	if not open:
		if Player.position.distance_to(position) < 16:
			if Input.is_action_just_pressed("down"):
				open = true
				$Sprite.play("open")
				match type:
					TYPES.ITEM:
						var item := Items.pick_random_item()
						Map.summon_item(item, position, Vector2(-120 + randf()*240, -100))
					TYPES.WAND:
						var wand:= Wand.new()
						Map.summon_wand(wand, position, Vector2(-120 + randf()*240, -100))
					TYPES.SPELL:
						var spell := Items.pick_random_spell()
						if Items.LootRNG.randf() < 0.2:
							spell = Items.pick_random_modifier()
						Map.summon_spell(spell, position, Vector2(-120 + randf()*240, -100))
