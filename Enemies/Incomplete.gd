extends KinematicBody2D


enum STATES {
	NORMAL,
	SEARCHING,
}

var state :int = STATES.NORMAL
var Player :KinematicBody2D
var speed := Vector2(0, 0)
var noise := OpenSimplexNoise.new()
var first_check := false
var last_seen := Vector2(0, 0)
var search_time := 0.0
var health := Flesh.new()
var wand := Wand.new()


func _ready():
	noise.seed = hash(self)
	health.connect("died", self, "health_died")
	Player = get_tree().get_nodes_in_group("Player")[0]
	wand.full_recharge = max(wand.full_recharge, 1.5)
	if Player.position.distance_to(position) < 500:
		queue_free()


func _physics_process(delta):
	$WandRenderSprite.render_wand(wand)
	health.process_health()
	for i in min(health.poked_holes, 12):
		if randf()>0.9:
			var n :RigidBody2D = preload("res://Particles/Blood.tscn").instance()
			n.position = position + Vector2(0, 6)
			n.linear_velocity = Vector2(-200 + randf()*400, -80 + randf()*120)
			n.modulate = ColorN("red")
			get_parent().add_child(n)
	var frames := Engine.get_frames_drawn()
	$Senses.cast_to = speed
	$Eye.cast_to = (Player.position-position).normalized()*500
	if not first_check:
		if Player.position.distance_to(position) < 500:
			queue_free()
		var tcol :KinematicCollision2D = move_and_collide(Vector2(0, 0), true, true, true)
		if tcol != null:
			if tcol.collider != self:
				queue_free()
		first_check = true
	
	var primordial_tremor := Vector2(noise.get_noise_2d(position.x, frames), noise.get_noise_2d(position.y, frames))*5
	match state:
		STATES.NORMAL:
			if $Eye.is_colliding() and $Eye.get_collider() == Player:
				var goal := (position - Player.position).normalized()*130 + Player.position
				speed = lerp(speed, primordial_tremor*30 + (goal - position), 0.2)
				last_seen = Player.position
				$WandRenderSprite.position = lerp($WandRenderSprite.position, (Player.position - position).normalized()*30, 0.2)
				$WandRenderSprite.rotation = lerp_angle($WandRenderSprite.rotation, Player.position.angle_to_point(position) + PI/4.0, 0.3)
				wand.run(self)
			else:
				speed = lerp(speed, primordial_tremor*60, 0.2)
				if last_seen != Vector2(0, 0):
					state = STATES.SEARCHING
					search_time = 0.0
			speed = move_and_slide(speed)
		
		STATES.SEARCHING:
			search_time += delta
			if $Eye.is_colliding() and $Eye.get_collider() == Player:
				state = STATES.NORMAL
			else:
				speed = lerp(speed, primordial_tremor*20 + (last_seen - position), 0.2)
			
			if search_time > 12.0:
				state = STATES.NORMAL
				last_seen = Vector2(0, 0)
			speed = move_and_slide(speed)


func health_object() -> Flesh:
	return health


func health_died():
	queue_free()


func cast_from():
	return $WandRenderSprite.position + position

func looking_at():
	return Player.position
