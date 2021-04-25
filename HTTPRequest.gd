extends HTTPRequest


signal leaderboard_updated(leaderboard)


enum State { IDLE, FETCH_WAIT, UPDATE_WAIT_READ, UPDATE_WAIT_MODIFY }


var state: int = State.IDLE
var new_name := ""
var new_score := 0.0


func fetch_leaderboard():
    if state == State.IDLE:
        # print("Requesting")
        request("https://jsonstorage.net/api/items/a5a51234")
        state = State.FETCH_WAIT


func update_leaderboard(name: String, score: float) -> void:
    if state == State.IDLE:
        # print("Updating: ", name, "=", score)
        request("https://jsonstorage.net/api/items/a5a51234")
        new_name = name
        new_score = score
        state = State.UPDATE_WAIT_READ


func _ready():
    connect("request_completed", self, "on_request_completed")


func check_valid(lb) -> bool:
    if !(lb is Dictionary):
        return false

    for name in lb:
        if !(name is String):
            return false
        if !(lb[name] is float):
            return false

    return true


func on_request_completed(result, response_code, headers, body):
    # print("Request complted result=", result, " response_code=", response_code, " headers=", headers, " body=", body, " state=", state)
    match state:
        State.FETCH_WAIT:
            state = State.IDLE

            var json := JSON.parse(body.get_string_from_utf8())
            if json.error == OK:
                if check_valid(json.result):
                    emit_signal("leaderboard_updated", json.result)

        State.UPDATE_WAIT_READ:
            state = State.IDLE

            var json := JSON.parse(body.get_string_from_utf8())
            if json.error == OK:
                # print("Doing put")
                var lb = json.result
                if check_valid(lb):
                    if !new_name in lb || lb[new_name] < new_score:
                        lb[new_name] = new_score
                        request("https://jsonstorage.net/api/items/a5a51234", ["Content-Type: application/json"], true, HTTPClient.METHOD_PUT, JSON.print(lb))
                        state = State.UPDATE_WAIT_MODIFY
                    emit_signal("leaderboard_updated", lb)

        State.UPDATE_WAIT_MODIFY:
            state = State.IDLE
