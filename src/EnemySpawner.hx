import luxe.Vector;
import luxe.Sprite;
import luxe.Entity;

import luxe.collision.shapes.Polygon;
import luxe.collision.shapes.Circle;
import luxe.components.sprite.SpriteAnimation;

import physics2d.PhysicsEngine2D;
import physics2d.components.Physics2DBody;

import behavior.DamageReceiver;

import phoenix.Texture;

class EnemySpawner
{
    public var base_movespeed : Float = 50.0;
    public var base_size : Float = 16;
    public var enemy_layer : Int = PhysicsEngine2D.LAYER_DEFAULT;
    public var bullet_layer : Int = PhysicsEngine2D.LAYER_DEFAULT;
    public var spawn_interval : Float = 5;

    var spawn_interval_cnt : Float = 0;

    var physics2d : PhysicsEngine2D;
    var player : Entity;


    public function new(_physics2d: PhysicsEngine2D, _player: Entity)
    {
        physics2d = _physics2d;
        player = _player;
    }

    public function update(dt: Float)
    {
        if (spawn_interval_cnt > 0)
        {
            spawn_interval_cnt -= dt;

            if (spawn_interval_cnt <= 0)
            {
                spawn_mark();
            }
        }
    }

    public function spawn_mark()
    {
        for (i in 0...6)
        {
            spawn_enemy(new Vector(10 + i*(base_size + 8),-base_size));
        }

        spawn_interval_cnt = spawn_interval;
    }

    public function spawn_enemy(spos: Vector) : Sprite
    {
        var image = Luxe.resources.texture('assets/gfx/enemies.png');
            image.filter_min = image.filter_mag = FilterType.nearest;

        var sprite = new Sprite({
            name: 'enemy',
            name_unique: true,
            size: new Vector(base_size, base_size),
            texture: image
        });

        var phys = sprite.add(new Physics2DBody(
            physics2d,
            Polygon.square(spos.x, spos.y, base_size)
        ));

        phys.set_topdown_configuration(base_movespeed, 1);
        phys.body.layer = enemy_layer;
        phys.body.collision_response = false;

        var dmg_recv = new DamageReceiver({ name: 'DamageReceiver' });
        dmg_recv.hitpoints = 2;
        sprite.add(dmg_recv);

        var weapon = sprite.add(new Weapon(physics2d, phys, { name: 'Weapon' }));
        weapon.bullet_layer = bullet_layer;
        weapon.fire_rate = 2;
        weapon.bullet_speed = 100;

        var cap = new ShapeCapabilities(weapon, phys, dmg_recv, { name: 'ShapeCapabilities' });
        sprite.add(cap);

        var be = new BasicEnemy(player, phys, cap, { name: 'BasicEnemy' });
        be.cap_type = Luxe.utils.random.int(0, 3);

        var animation = sprite.add(new SpriteAnimation({ name: 'anim' }));
        animation.add_from_json_object(Luxe.resources.json('assets/enemies_anim.json').asset.json);
        if (be.cap_type == 0) {
            animation.animation = 'enemy_attack';
        } else if (be.cap_type == 1) {
            animation.animation = 'enemy_defense';
        } else {
            animation.animation = 'enemy_speed';
        }

        animation.play();

        sprite.add(be);

        return sprite;
    }
}
