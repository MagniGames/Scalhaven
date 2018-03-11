extends Spatial

const BULLET_SPEED = 10
const BULLET_DAMAGE = 15

const KILL_TIMER = 4
var timer = 0

var hit_something = false

func _ready():
    get_node("Area").connect("body_entered", self, "collided")
    set_physics_process(true)


func _physics_process(delta):
    var forward_dir = global_transform.basis.z.normalized()
    global_translate(forward_dir * BULLET_SPEED * delta)

    timer += delta;
    if timer >= KILL_TIMER:
        queue_free()


func collided(body):
    if hit_something == false:
        if body.has_method("bullet_hit"):
            body.bullet_hit(BULLET_DAMAGE, self.global_transform.origin)

    hit_something = true
    queue_free()