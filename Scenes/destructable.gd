extends RigidBody

func _ready():
    pass

func bullet_hit(damage, bullet_hit_pos):
    var direction_vect = self.global_transform.origin - bullet_hit_pos
    direction_vect = direction_vect.normalized()

    self.apply_impulse(bullet_hit_pos, direction_vect * damage)