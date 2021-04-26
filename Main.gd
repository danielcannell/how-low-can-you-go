extends Node


const Player = preload("res://Player/Player.tscn")
const DeadPlayer = preload("res://Player/DeadPlayer.tscn")
const Harpoon = preload("res://Harpoon/Harpoon.tscn")


onready var camera := $Camera2D
onready var background := $Camera2D/Background
onready var depth_label := $UICanvas/DepthLabel
onready var canvas_modulate := $Camera2D/CanvasModulate
onready var game_over_ui := $UICanvas/GameOverUI
onready var leaderboard_ui := $UICanvas/LeaderboardUI
onready var restart_button1 := $UICanvas/GameOverUI/VBoxContainer/RestartButton
onready var restart_button2 := $UICanvas/LeaderboardUI/VBoxContainer/RestartButton
onready var leaderboard_button := $UICanvas/GameOverUI/VBoxContainer/LeaderboardButton
onready var leaderboard_container := $UICanvas/LeaderboardUI/VBoxContainer/GridContainer
onready var submit_button := $UICanvas/LeaderboardUI/VBoxContainer/HBoxContainer/SubmitButton
onready var name_text_edit := $UICanvas/LeaderboardUI/VBoxContainer/HBoxContainer/NameTextEdit
onready var http_request := $HTTPRequest
onready var label_font := load("res://Art/SmallFont.tres")

var fall_rate := 50.0
var prev_rounded_depth := 0.0
var score := 0.0

var dead_players = []
var next_dead_player = 0


class DepthSorter:
    static func sort(a, b):
        if a["depth"] < b["depth"]:
            return true
        return false


func _ready() -> void:
    Globals.depth = 0.0

    spawn_player()

    restart_button1.connect("button_up", self, "restart_game")
    restart_button2.connect("button_up", self, "restart_game")
    leaderboard_button.connect("button_up", self, "show_leaderboard")
    submit_button.connect("button_up", self, "submit_score")
    http_request.connect("leaderboard_updated", self, "on_leaderboard_updated")
    http_request.fetch_leaderboard()
    



func on_leaderboard_updated(leaderboard):
    dead_players = []
    for name in leaderboard:
        dead_players.append({"name": name, "depth": leaderboard[name]})
    dead_players.sort_custom(DepthSorter, "sort")
    
    for n in leaderboard_container.get_children():
        leaderboard_container.remove_child(n)
        n.queue_free()

    var top := []
    for name in leaderboard:
        # print("Inserting ", name, "=", leaderboard[name])
        var score: float = leaderboard[name]
        for i in range(top.size() + 1):
            if i == top.size() || score > top[i][1]:
                top.insert(i, [name, score])
                break

    # Only keep top 5
    if top.size() > 5:
        top.resize(5)

    for record in top:
        var name_label = Label.new()
        var score_label = Label.new()

        name_label.text = record[0]
        score_label.text = str(record[1])

        name_label.set("custom_fonts/font", label_font)
        score_label.set("custom_fonts/font", label_font)

        leaderboard_container.add_child(name_label)
        leaderboard_container.add_child(score_label)


func submit_score():
    var name = name_text_edit.text

    var regex := RegEx.new()
    regex.compile("[^a-zA-Z0-9 ]")
    name = regex.sub(name, "", true)

    name = name.substr(0, 7)
    name = name.strip_edges()

    # Default value of the text edit
    if name == "Name":
        return

    http_request.update_leaderboard(name, score)


func restart_game() -> void:
    get_tree().reload_current_scene()


func show_leaderboard() -> void:
    game_over_ui.visible = false
    leaderboard_ui.visible = true


func spawn_player() -> void:
    var player := Player.instance()
    var harpoon := Harpoon.instance()
    add_child(player)
    add_child(harpoon)
    player.set_harpoon(harpoon)
    harpoon.set_player(player)
    harpoon.connect("bool_splatter", self, "_on_blood_splatter")

    player.connect("died", self, "on_player_died")
    
    
func spawn_dead_player(depth: float, name) -> void:
    var p = DeadPlayer.instance()
    p.position = Vector2(rand_range(-Globals.screen_width/2, Globals.screen_width/2), depth)
    p.rotation = rand_range(0, 2*PI)
    p.set_name(name)
    add_child(p)
    


func on_player_died():
    score = 10 * round(Globals.depth / 320)
    game_over_ui.visible = true
    http_request.fetch_leaderboard()


func depth_scale(depth: float) -> float:
    # Depth at which we reach 50% brightness
    var mid_point := 40.0 * fall_rate

    # Time scale for the change from light to dark
    var scale := 40.0 * fall_rate

    # Logistic function
    return 1.0 - 1.0 / (1.0 + exp(-(depth - mid_point) / scale))


func _depth_to_m(d):
    return Globals.depth / 32

func _process(delta: float) -> void:
    var vp := camera.get_viewport()
    Globals.screen_height = vp.size.y
    Globals.screen_width = vp.size.x

    # Bubbles at the bottom
    var bubbles: Particles2D = $Camera2D/Particles2D
    var shader: ParticlesMaterial = bubbles.process_material
    shader.emission_box_extents.x = vp.size.x
    bubbles.position = Vector2(0, vp.size.y / 2.0)

    Globals.depth += delta * fall_rate
    camera.position.y = Globals.depth

    Globals.color_scale = depth_scale(Globals.depth) / depth_scale(0.0)
    background.color = color_from_hsl(0.64, 0.4 + 0.6 * Globals.color_scale, 0.25 + (0.6 * Globals.color_scale))
    canvas_modulate.color = Color.from_hsv(0, 0, min(0.8, Globals.color_scale))

    var rounded_depth := 10 * round(Globals.depth / 320)
    if prev_rounded_depth != rounded_depth:
        depth_label.text = "Depth: " + str(rounded_depth) + " m"
        prev_rounded_depth = rounded_depth
        
        
    while dead_players.size() > next_dead_player and dead_players[next_dead_player]['depth'] < _depth_to_m(Globals.depth) + 100:
        spawn_dead_player(dead_players[next_dead_player]['depth'] * 32, dead_players[next_dead_player]['name'])
        next_dead_player += 1


func color_from_hsl(hue: float, sat: float, light: float) -> Color:
    sat *= light if light < 0.5 else 1.0 - light
    return Color.from_hsv(hue, 2 * sat / (light + sat), light + sat)


func _on_blood_splatter(cls, location, direction, params):
    var b = cls.instance()
    add_child(b)
    b.rotation = direction
    b.position = location
    b.set_params(params)
    b.run()
