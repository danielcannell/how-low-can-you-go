extends KinematicBody2D


signal died();


onready var HealthBar := preload("res://Enemies/HealthBar.tscn")


enum SwimState { IDLE, LEFT, RIGHT }
enum AttackState { IDLE, AIM, FIRE }


onready var sprite := $Sprite
onready var spotlight := $Spotlight
onready var arealight := $AreaLight
onready var gun := $Gun
onready var gunblast := $GunBlast
onready var damage_zone := $DamageZone
onready var bubbles := $Bubbles


const HARPOON_KICK = 400


var harpoon = null
var velocity := Vector2(0, 100)
var swim_state: int = SwimState.IDLE
var attack_state: int = AttackState.IDLE
var gun_idle_transform = Transform2D()
var gun_right_transform = Transform2D(-PI / 3.0, Vector2(25, -7))
var gun_left_transform = Transform2D(PI / 3.0, Vector2(-25, -7))
var health := 100.0
var healthbar = null
var alive := true
var aim_dir := Vector2(0.0, 0.0)


func _ready() -> void:
    gun_idle_transform = gun.transform

    healthbar = HealthBar.instance()
    healthbar.position = Vector2(0, -20)
    add_child(healthbar)


func set_harpoon(h) -> void:
    harpoon = h


func harpoon_retreived() -> void:
    attack_state = AttackState.IDLE
    gun.set_animation("loaded")


func update_swim_state(a: Vector2) -> void:
    var new_swim_state = SwimState.IDLE
    if a.x > 100:
        new_swim_state = SwimState.RIGHT
    elif a.x < -100:
        new_swim_state = SwimState.LEFT

    if new_swim_state != swim_state:
        swim_state = new_swim_state

        match swim_state:
            SwimState.IDLE:
                sprite.set_animation("idle")
                gun.set_flip_h(false)
                gun.transform = gun_idle_transform
            SwimState.LEFT:
                sprite.set_animation("swim")
                sprite.set_flip_h(false)
                gun.set_flip_h(true)
                gun.transform = gun_left_transform
            SwimState.RIGHT:
                sprite.set_animation("swim")
                sprite.set_flip_h(true)
                gun.set_flip_h(false)
                gun.transform = gun_right_transform


func _gun_blast(direction: Vector2, offset: float) -> void:
    gunblast.restart()
    var mouse_dir := get_global_mouse_position() - position
    var mouse_vec = Vector2(cos(mouse_dir.angle()), sin(mouse_dir.angle()))
    gunblast.process_material.direction = Vector3(direction.x, direction.y, 0)
    gunblast.transform = Transform2D(0, mouse_vec  * offset)
    gunblast.emitting = true


func update_attack_state() -> void:
    match attack_state:
        AttackState.IDLE:
            if Input.is_action_pressed("attack"):
                attack_state = AttackState.AIM

        AttackState.AIM:
            if !Input.is_action_pressed("attack"):
                attack_state = AttackState.FIRE

                if harpoon != null:
                    harpoon.fire(position, velocity, aim_dir.angle())
                    velocity -= HARPOON_KICK * aim_dir
                    gun.set_animation("unloaded")
                    _gun_blast(aim_dir, 20)


        AttackState.FIRE:
            pass


func update_light() -> void:
    spotlight.rotation = aim_dir.angle()
    arealight.energy = 1 - Globals.color_scale
    spotlight.energy = 1 - Globals.color_scale


func update_health(delta: float) -> void:
    for b in damage_zone.get_overlapping_bodies():
        if b.has_method("dps"):
            if b.alive:
                health -= delta * b.dps()

    healthbar.set_percent(health / 100.0)

    if alive && health < 0:
        alive = false
        bubbles.emitting = false
        emit_signal("died")


func _process(_delta: float) -> void:
    if alive:
        aim_dir = (get_global_mouse_position() - position).normalized()
        update_attack_state()
        update_light()


func _physics_process(delta: float) -> void:
    var a := Vector2.ZERO

    if alive:
        if Input.is_action_pressed("up"):
            a.y -= 1000
        if Input.is_action_pressed("down"):
            a.y += 1000
        if Input.is_action_pressed("left"):
            a.x -= 1000
        if Input.is_action_pressed("right"):
            a.x += 1000

    # Get viewport rect in canvas coordinates
    var visible = get_viewport_transform().xform_inv(get_viewport_rect())
    var allowed = visible.grow(-100)

    if !allowed.has_point(position):
        var left_dist = position.x - allowed.position.x
        var right_dist = allowed.end.x - position.x
        var top_dist = position.y - allowed.position.y
        var bottom_dist = allowed.end.y - position.y

        if left_dist < 0:
            a.x += 10 * -left_dist
            if velocity.x < 0:
                a.x -= 5 * velocity.x

        if right_dist < 0:
            a.x -= 10 * -right_dist
            if velocity.x > 0:
                a.x -= 5 * velocity.x

        if top_dist < 0:
            a.y += 10 * -top_dist
            if velocity.y < 100:
                a.y -= 5 * (velocity.y - 100)

        if bottom_dist < 0:
            a.y -= 10 * -bottom_dist
            if velocity.y > 100:
                a.y -= 5 * (velocity.y - 100)

    update_swim_state(a)

    # Damping
    a -= velocity - Vector2(0, 200)

    velocity += delta * a

    var result := move_and_collide(velocity * delta, false)
    if result != null:
        if result.collider is RigidBody2D:
            result.collider.apply_central_impulse(-result.normal * 100)
        velocity = velocity.slide(result.normal) * 0.2

    Globals.player_position = position

    update_health(delta)
